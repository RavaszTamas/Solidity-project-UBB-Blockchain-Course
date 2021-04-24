// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./SafeMath.sol";

contract CryptoDogFactory is Ownable {
    
    using SafeMath for uint;
    
    event NewDog(uint dogId, string name, uint dna);
    
    uint dnaDigits = 8;
    
    struct Dog {
        
        string name;
        uint dna;
        uint32 readyTime;
        uint16 generation;
    }
    
    mapping(uint => address) public dogToOwner;
    mapping(address => uint) ownerDogCount;
    uint cooldownTime = 1 seconds;

    Dog[] public dogs;
    
    function _generateRandomDna(string memory _str) internal pure returns (uint) {
      uint rand = uint(keccak256(abi.encodePacked(_str)));
      return rand;
    }

    function _createDog(string memory _name, uint _dna) internal {
     uint id;
     dogs.push(Dog(_name, _dna,uint32(block.timestamp+cooldownTime),0));
     id = dogs.length - 1;
     dogToOwner[id] = msg.sender;
     ownerDogCount[msg.sender] = ownerDogCount[msg.sender].add(1);
     emit NewDog(id, _name, _dna);
    }

    function createRandomDog(string memory _name) public {
        require(ownerDogCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createDog(_name,randDna);
    }

}