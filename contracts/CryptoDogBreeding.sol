// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CryptoDogFactory.sol";

contract CryptoDogBreeding is CryptoDogFactory {
    
    
  modifier onlyOwnerOf(uint _dogId) {
    require(msg.sender == dogToOwner[_dogId]);
    _;
  }

  function _triggerCooldown(Dog storage _dog) internal {
    _dog.readyTime = uint32(block.timestamp + cooldownTime);
  }

  function _isReady(Dog storage _dog) internal view returns (bool) {
      return (_dog.readyTime <= block.timestamp);
  }

  function breed(uint _dogId, uint _targetDogId) external onlyOwnerOf(_dogId) {
      Dog storage myDog = dogs[_dogId];
      Dog storage targetDog = dogs[_targetDogId];
      require(_isReady(myDog), "Dog with id is not ready to breed");
      require(_isReady(targetDog), "Target dog with id is not ready to breed");
      uint newDna = (myDog.dna + targetDog.dna)/2;
      _createDog("Jeff",newDna);
      _triggerCooldown(myDog);
  }
  
  
    // function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    //     if (_i == 0) {
    //         return "0";
    //     }
    //     uint j = _i;
    //     uint len;
    //     while (j != 0) {
    //         len++;
    //         j /= 10;
    //     }
    //     bytes memory bstr = new bytes(len);
    //     uint k = len;
    //     while (_i != 0) {
    //         k = k-1;
    //         uint8 temp = (48 + uint8(_i - _i / 10 * 10));
    //         bytes1 b1 = bytes1(temp);
    //         bstr[k] = b1;
    //         _i /= 10;
    //     }
    //     return string(bstr);
    // }


//   function combineToNewDna(uint _firstParentDna, uint _secondParentDna) private pure returns(uint) {
//       string memory parentOne = uint2str(_firstParentDna);
//       string memory parentTwo = uint2str(_secondParentDna);
      
//       //string memory newDnaString = string(abi.encodePacked(parentOne,parentTwo));
      
//       return _generateRandomDna(parentOne);
//   }
}