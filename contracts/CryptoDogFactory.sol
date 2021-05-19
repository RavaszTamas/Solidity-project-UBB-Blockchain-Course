// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./utils/Console.sol";

contract CryptoDogFactory is Ownable, Console{
    
    using SafeMath for uint;
    
    event NewDog(uint dogId, string name, uint dna);
    
    uint dnaDigits = 32;
    uint dnaModulus = 10 ** dnaDigits;

    struct Dog {
        
        string name;
        uint dna;
        uint32 readyTime;
        uint16 generation;
        uint8 boots;
        uint8 pants;
        uint8 shirt;
        uint8 hat;
    }
    
    mapping(uint => address) public dogToOwner;
    mapping(address => uint) ownerDogCount;
    uint cooldownTime = 1 seconds;

    Dog[] public dogs;
    
	/**
	 * @dev generates and returns a random integer from a seed string
	 */
    function _generateRandomDna(string memory _str) internal view returns (uint) {
      uint rand = uint(keccak256(abi.encodePacked(_str)));
      return rand % dnaModulus;
    }

	/**
	 * @dev creates and saves a new dog with name `_name` and dna `_dna` and increments the
	 * owner's counter.
	 * Emits a {NewDog} event
	 */
    function _createDog(string memory _name, uint _dna) internal {
     uint id;
     dogs.push(Dog(_name, _dna,uint32(block.timestamp+cooldownTime),0,0,0,0,0));
     id = dogs.length - 1;
     dogToOwner[id] = msg.sender;
     ownerDogCount[msg.sender] = ownerDogCount[msg.sender].add(1);
     emit NewDog(id, _name, _dna);
    }

	/**
	 * @dev creates and saves a new dog with name `_name` and dna `_dna` and increments the
	 * owner's counter.
	 * Emits a {NewDog} event
	 */
    function _createDog(string memory _name, uint _dna, uint16 generation) internal {
     uint id;
     dogs.push(Dog(_name, _dna,uint32(block.timestamp+cooldownTime),generation,0,0,0,0));
     id = dogs.length.sub(1);
     dogToOwner[id] = msg.sender;
     ownerDogCount[msg.sender] = ownerDogCount[msg.sender].add(1);
     emit NewDog(id, _name, _dna);
    }

	/**
	 * @dev Creates a new dog for the message sender, checking first that the sender doesn't
	 * posess any dogs yet.
	 * 
	 * Requirements:
	 * - the caller does not have any dogs in their posession
	 */
    function createRandomDog(string memory _name) public {
        require(ownerDogCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createDog(_name,randDna);
    }

}