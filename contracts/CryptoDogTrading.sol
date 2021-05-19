
pragma solidity ^0.8.0;

import "./Pausable.sol";
import "./CryptoDogTradingBase.sol";
import "../github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract CryptoDogTrading is Pausable, CryptoDogTradingBase {


    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);

    constructor(address _nftAddress, uint256 _cut){
        require(_cut <= 10000);
        ownerCut = _cut;

        IERC721 candidateContract = IERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        nonFungibleContract = candidateContract;

    }



    /// @dev Updates lastSalePrice if seller is the nft contract
    function bid(uint256 _tokenId)
        external
        payable
    {
        require(msg.sender == address(nonFungibleContract));
        address seller = tokenIdToAuction[_tokenId].seller;
        // _bid checks that token ID is valid and will throw if bid fails
        _bid(_tokenId, msg.value);
        // Transfer back to the seller
        _transfer(seller, _tokenId);
    }

    /// @dev Remove all Ether from the contract, which is the owner's cuts
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(msg.sender == owner() || msg.sender == nftAddress );

        // We are using this boolean method to make sure that even if one fails it will still work
        bool res = payable(nftAddress).send(address(this).balance);
    }
	
	/// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender

    function createAuction(uint256 _tokenId,uint256 _startingPrice,uint256 _endingPrice,uint256 _duration,address _seller) external whenNotPaused {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.sender, _tokenId));
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction( _seller, uint128(_startingPrice), uint128(_endingPrice), uint64(_duration), uint64(block.timestamp));
        _addAuction(_tokenId, auction);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
	
    function cancelAuction(uint256 _tokenId) external {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function cancelAuctionWhenPaused(uint256 _tokenId) whenPaused onlyOwner external {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        _cancelAuction(_tokenId, auction.seller);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function getAuction(uint256 _tokenId) external view returns(address seller,uint256 startingPrice,uint256 endingPrice,uint256 duration,uint256 startedAt) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (auction.seller,auction.startingPrice,auction.endingPrice,auction.duration,auction.startedAt);
    }
	
	/// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function getCurrentPrice(uint256 _tokenId) external view returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }
	
	    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }


}
