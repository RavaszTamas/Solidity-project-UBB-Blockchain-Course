// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract CryptoDogTradingBase {
    
    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);

    
    struct Auction{
        address seller;
        // Price (in wei) at beginning of auction
        uint128 startingPrice;
        // Price (in wei) at end of auction
        uint128 endingPrice;
        // Duration (in seconds) of auction
        uint64 duration;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 startedAt;
    }
    mapping (uint => Auction) tokenIdToAuction;
    IERC721 public nonFungibleContract;
    uint public ownerCut;

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    function _escrow(address _owner, uint256 _tokenId) internal {
        nonFungibleContract.transferFrom(_owner, address(this), _tokenId);
    }


    
    function _addAuction(uint _tokenId, Auction memory _auction) internal {
        require(_auction.duration >= 1 minutes, "Auction should be at least of 1 minute duration");
        tokenIdToAuction[_tokenId] = _auction;


    emit AuctionCreated(uint(_tokenId), uint(_auction.startingPrice),uint(_auction.endingPrice),uint(_auction.duration) );

    }
    
    function _cancelAuction(uint _tokenId, address _seller) internal{
        _removeAuction(_tokenId);
        _transfer(_seller,_tokenId);
        emit AuctionCancelled(_tokenId);
    }
    
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }
    
    function _bid(uint _tokenId, uint _bidAmount)  internal  returns(uint){
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        uint price = _currentPrice(auction);
        require(_bidAmount >= price);
        address seller = auction.seller;
        _removeAuction(_tokenId);
        if (price > 0) {
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;

            payable(seller).transfer(sellerProceeds);
        }

        uint256 bidExcess = _bidAmount - price;
        payable(msg.sender).transfer(bidExcess);
        AuctionSuccessful(_tokenId, price, msg.sender);
        return price;
    }
    
    
    function _currentPrice(Auction storage _auction) internal view returns(uint) {
        uint secondsPassed = 0;
        
        if(block.timestamp > _auction.startedAt){
            secondsPassed = block.timestamp - _auction.startedAt;
        }
        
        return _computeCurrentPrice(_auction.startingPrice,_auction.endingPrice,_auction.duration,secondsPassed);
        
    }
    
        function _computeCurrentPrice(uint256 _startingPrice,uint256 _endingPrice,uint256 _duration,uint256 _secondsPassed) internal pure returns (uint256){
        if (_secondsPassed >= _duration) {
            return _endingPrice;
        } else {
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;

            return uint256(currentPrice);
        }
    }

    function _computeCut(uint256 _price) internal view returns (uint256) {
        return _price * ownerCut / 10000;
    }

    
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }

    
    function _transfer(address _receiver,uint tokenId) internal {
        nonFungibleContract.transfer( _receiver,tokenId);
    }


}