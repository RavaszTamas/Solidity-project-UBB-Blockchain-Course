
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

    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(msg.sender == owner() || msg.sender == nftAddress );

        // We are using this boolean method to make sure that even if one fails it will still work
        bool res = payable(nftAddress).send(address(this).balance);
    }

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

    function cancelAuction(uint256 _tokenId) external {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    function cancelAuctionWhenPaused(uint256 _tokenId) whenPaused onlyOwner external {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        _cancelAuction(_tokenId, auction.seller);
    }

    function getAuction(uint256 _tokenId) external view returns(address seller,uint256 startingPrice,uint256 endingPrice,uint256 duration,uint256 startedAt) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (auction.seller,auction.startingPrice,auction.endingPrice,auction.duration,auction.startedAt);
    }
    function getCurrentPrice(uint256 _tokenId) external view returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }

}
