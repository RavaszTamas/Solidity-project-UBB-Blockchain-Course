// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "../github/OpenZeppelin/openzeppelin-contracts/contracts/utils/Address.sol";
import "./CryptoDogBreeding.sol";
contract CryptoDogs is IERC721,CryptoDogBreeding {
    
    
    using Address for address;
    using SafeMath for uint;


    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint256,string)'));

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    mapping(uint => address) private approvals;
    mapping(address => mapping( address => bool)) private _operatorApprovals; 
    
    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }


    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
     function  balanceOf(address owner) external view override returns  (uint256 balance) {
        
        return ownerDogCount[owner];
        
    }



    function transfer(address _to, uint256 _tokenId) external override onlyOwnerOf(_tokenId) {
        require(_to != address(0));
        require(_to != address(this));
        _transfer(msg.sender,_to,_tokenId);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        _safeTransferFrom(from,to,tokenId,"");
//                require(dogToOwner[tokenId] == from, "Owner of the dog must be the from address");
//        _transfer(from,to,tokenId);

    }
    
    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external override {
        require(_isApprovedOrOwner(msg.sender,tokenId), "Sender must be approved");
        _transfer(from,to,tokenId);
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
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
        
        ownerDogCount[from].sub(1);
        ownerDogCount[to].add(1);
        dogToOwner[tokenId] = to;
        
        emit Transfer(from,to,tokenId);
    }
    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        
        return _operatorApprovals[owner][operator];
        
    }

    
        /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external override {
        
        address owner = ownerOf(tokenId);
        
        require(to != owner, "Can't set approval for yourself");
        
        require(msg.sender == owner || isApprovedForAll(owner,msg.sender),"The dog is not approved for all or the message sender is not the owner of the dog");
        
        _approve(to,tokenId);
    }
    
    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view override returns (address operator)  {
        require(_exists(tokenId),"Token must exist!");
        return approvals[tokenId];
    }


    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external override {
        require(operator != msg.sender,"You can't approve yourself");
        
        _operatorApprovals[msg.sender][operator] = _approved;
    
        emit ApprovalForAll(msg.sender,operator,_approved);    
        
    }

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
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

    function supportsInterface(bytes4 _interfaceID) external view override returns (bool)
    {

        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

}