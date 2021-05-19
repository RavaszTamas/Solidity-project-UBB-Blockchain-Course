// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CryptoDogAccessories.sol";

contract CryptoDogBreeding is CryptoDogAccessories {
    
    
  /**
	 * @dev puts the entity `_dog` into a waiting state for a period specified by `cooldownTime`
	 */
  function _triggerCooldown(Dog storage _dog) internal {
    _dog.readyTime = uint32(block.timestamp + cooldownTime);
  }

  /**
	 * @dev returns true, if the cooldown period has passed for the entity `_dog_`
	 */
  function _isReady(Dog storage _dog) internal view returns (bool) {
      return (_dog.readyTime <= block.timestamp);
  }

  /**
     * @dev combines the dna of the two dogs, 
     *
     * Requirements:
     *
     * - `_dogId` must be a valid id.
	 * - `_partnerid` must be a valid id.
	 * = entity with id `_dogId` is required to have served the cooldown period
     */
  function breed(uint _dogId, uint _targetDogId, string memory newDogName) external onlyOwnerOf(_dogId) {
      Dog storage myDog = dogs[_dogId];
      Dog storage targetDog = dogs[_targetDogId];
      require(_isReady(myDog), "Dog with id is not ready to breed");
      require(_isReady(targetDog), "Target dog with id is not ready to breed");
      //uint newDna = (myDog.dna + targetDog.dna)/2;
      uint newDna = combineToNewDna(myDog.dna,targetDog.dna);
      _createDog(newDogName,newDna);
      _triggerCooldown(myDog);
  }
  
  
    function uint32Tostr(uint32 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint32 j = _i;
        uint32 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }


  function combineToNewDna(uint _firstParentDna, uint _secondParentDna) private view returns(uint) {
      string memory parentOne = uint32Tostr(uint32(_firstParentDna));
      string memory parentTwo = uint32Tostr(uint32(_secondParentDna));
      string memory newDnaString = string(abi.encodePacked(parentOne,parentTwo));
      
      return _generateRandomDna(newDnaString);
  }
}