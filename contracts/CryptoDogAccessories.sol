// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "./CryptoDogFactory.sol";
import "./SafeMath.sol";


contract CryptoDogAccessories is CryptoDogFactory {
    enum AccessoryType { PANTS, BOOTS, SHIRTS, HAT}
    uint bootUpgradeFee = 0.001 ether;
    uint pantsUpgradeFee = 0.002 ether;
    uint shirtUpgradeFee = 0.003 ether;
    uint hatUpgradeFee = 0.004 ether;
    using SafeMath8 for uint8;
    modifier onlyOwnerOf(uint _dogId) {
        require(msg.sender == dogToOwner[_dogId]);
        _;
      }
    function upgradeDogBoots(uint _dogId) external payable onlyOwnerOf(_dogId) {
        require(dogs[_dogId].boots < 255, "Maximum level for boots is reached");
        require(msg.value == bootUpgradeFee*(dogs[_dogId].boots.add(1)));
        dogs[_dogId].boots = dogs[_dogId].boots.add(1);
    }
    function upgradeDogPants(uint _dogId) external payable onlyOwnerOf(_dogId) {
        require(dogs[_dogId].pants < 255, "Maximum level for pants is reached");
        require(msg.value == pantsUpgradeFee*(dogs[_dogId].pants.add(1)));
        dogs[_dogId].pants = dogs[_dogId].pants.add(1);
    }
    function upgradeDogShirt(uint _dogId) external payable onlyOwnerOf(_dogId) {
        require(dogs[_dogId].shirt < 255, "Maximum level for shirt is reached");
        require(msg.value == shirtUpgradeFee*(dogs[_dogId].shirt.add(1)));
        dogs[_dogId].shirt = dogs[_dogId].shirt.add(1);
    }
    function upgradeDogHat(uint _dogId) external payable onlyOwnerOf(_dogId) {
        require(dogs[_dogId].hat < 255, "Maximum level for shirt is reached");
        require(msg.value == hatUpgradeFee*(dogs[_dogId].hat.add(1)));
        dogs[_dogId].hat = dogs[_dogId].hat.add(1);
    }
   function getDogsByOwner(address _owner) external view returns(uint[] memory) {
     uint[] memory result = new uint[](ownerDogCount[_owner]);
     uint counter = 0;
     for (uint i = 0; i < dogs.length; i++) {
       if (dogToOwner[i] == _owner) {
         result[counter] = i;
         counter++;
       }
     } 
     
     return result;
   }
   

   function setBasePriceForAccesory(uint _newFee, AccessoryType _accessory) external onlyOwner {
       require(_newFee >= 0, "The fee should be lager than 0");
       log("Setting new fee for acessory with id",uint(_accessory));
       if(_accessory == AccessoryType.PANTS){
           pantsUpgradeFee = _newFee;
           return;
       } else if(_accessory == AccessoryType.BOOTS) {
           bootUpgradeFee = _newFee;
           return;
       } else if(_accessory == AccessoryType.SHIRTS) {
           shirtUpgradeFee = _newFee;
           return;
       } else if(_accessory == AccessoryType.HAT) {
           hatUpgradeFee = _newFee;
           return;
       }
       require(false,"INVALID AccesoryType");
   }
   
    function withdraw() external  onlyOwner{
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }


}