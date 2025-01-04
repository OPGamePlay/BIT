// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
    
    // don't need to define other functions, only using `transfer()` in this case
}

contract GameAsset is ERC721 {
    address owner;
    address payable ownerWallet;
    bool isList;
    ufixed price;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, ufixed indexed price);
    constructor() ERC721("BIT_GameAsset", "BIT_GA") {
        owner = msg.sender;
        isList = false;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the Asset owner can call this function");
        _;
    }

    modifier onlyAvailable() {
        require(isList == true, "The Asset is not available now");
        _;
    }



    function setPrice(ufixed newPrice) public onlyOwner{
        price = newPrice;
    }  

    function getPrice() public view onlyAvailable returns(ufixed){
        return price;
    }
    function getOwner() public onlyAvailable view returns(address){
        return owner;
    }
    function isAvailable() public view returns(bool){
        return isList;
    }


    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        emit OwnershipTransferred(owner, newOwner, price);
        owner = newOwner;
    }

    
    function sendUSDT(address _to, uint256 _amount) external {
         // This is the mainnet USDT contract address
         // Using on other networks (rinkeby, local, ...) would fail
         //  - there's no contract on this address on other networks
        IERC20 usdt = IERC20(address(0xdAC17F958D2ee523a2206206994597C13D831ec7));
        
        // transfers USDT that belong to your contract to the specified address
        usdt.transfer(_to, _amount);
    }


}
