// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "../github/OpenZeppelin/openzeppelin-contracts/contracts/utils/Address.sol";
import "./CryptoDogBreeding.sol";
contract CryptoDogs is IERC721,CryptoDogBreeding {
    
    
    using Address for address;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    mapping(uint => address) approvals;
    mapping(address => mapping( address => bool)) _operatorApprovals; 
    
    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

     function  balanceOf(address owner) external view override returns  (uint256 balance) {
        
        return ownerDogCount[owner];
        
    }


    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        _safeTransferFrom(from,to,tokenId,"");
//                require(dogToOwner[tokenId] == from, "Owner of the dog must be the from address");
//        _transfer(from,to,tokenId);

    }
    
    function transferFrom(address from, address to, uint256 tokenId) external override {
        require(_isApprovedOrOwner(msg.sender,tokenId), "Sender must be approved");
        _transfer(from,to,tokenId);
    }


    function ownerOf(uint256 tokenId) public view  override returns (address) {
        address owner = dogToOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }


    function _exists(uint256 tokenId) internal view returns (bool) {
        return dogToOwner[tokenId] != address(0);
    }


    function _isApprovedOrOwner(address sender, uint256 tokenId ) internal view returns (bool) {
        require(_exists(tokenId));
        address owner = ownerOf(tokenId);
        return  owner == sender || approvals[tokenId] == sender;  
    }
    
    function _approve(address to, uint256 tokenId) internal {
        approvals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }


    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "Transfer of token that is not own");
        require(to != address(0));
        
        _approve(address(0),tokenId);
        
        ownerDogCount[from] -= 1;
        ownerDogCount[to] += 1;
        dogToOwner[tokenId] = to;
        
        emit Transfer(from,to,tokenId);
    }
    
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        
        return _operatorApprovals[owner][operator];
        
    }

    
    function approve(address to, uint256 tokenId) external override {
        
        address owner = ownerOf(tokenId);
        
        require(to != owner, "Can't set approval for yourself");
        
        require(msg.sender == owner || isApprovedForAll(owner,msg.sender),"The dog is not approved for all or the message sender is not the owner of the dog");
        
        _approve(to,tokenId);
    }
    
    function getApproved(uint256 tokenId) external view override returns (address operator)  {
        require(_exists(tokenId),"Token must exist!");
        return approvals[tokenId];
    }


    function setApprovalForAll(address operator, bool _approved) external override {
        require(operator != msg.sender,"You can't approve yourself");
        
        _operatorApprovals[msg.sender][operator] = _approved;
    
        emit ApprovalForAll(msg.sender,operator,_approved);    
        
    }


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external override {
        require(from != address(0) && to != address(0) && _exists(tokenId) && _isApprovedOrOwner(msg.sender,tokenId));
        _safeTransferFrom(from,to,tokenId,data);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) private {
        _transfer(from,to,tokenId);
        _checkOnERC721Received(from,to,tokenId,data);

    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }


}