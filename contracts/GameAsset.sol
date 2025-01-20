// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IERC20 { // 用得到的Function, 不要更改
    function transfer(address _to, uint256 _value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract GameAsset is ERC721 {
    address owner;
    address payable ownerWallet;
    bool isList;
    uint price_in_Wei;
    uint usdt_holder;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, uint indexed price_in_Wei);
    constructor() ERC721("BIT_GameAsset", "BIT_GA") {
        owner = msg.sender;
        isList = false;
        price_in_Wei = 1;
    }


    event Received(address Sender, uint Value);
    receive() external payable{
        require(msg.value == price_in_Wei, "The amount is incorrect.");
        emit Received(msg.sender,msg.value);
        transferOwnership(msg.sender);
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Only the Asset owner can call this function");
        _;
    }

    modifier onlyAvailable() {
        require(isList == true, "The Asset is not available now");
        _;
    }



    function setPrice(uint newPrice) public onlyOwner{
        price_in_Wei = newPrice;
    }  

    function getPrice() public view onlyAvailable returns(uint){
        return price_in_Wei;
    }
    function getOwner() public onlyAvailable view returns(address){
        return owner;
    }
    function isAvailable() public view returns(bool){
        return isList;
    }


    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        emit OwnershipTransferred(owner, newOwner, price_in_Wei);
        owner = newOwner;
    }

    
    function sendUSDT(address _to) external {
         // This is the mainnet USDT contract address
         // Using on other networks (rinkeby, local, ...) would fail
         //  - there's no contract on this address on other networks
        IERC20 usdt = IERC20(address(0xdAC17F958D2ee523a2206206994597C13D831ec7)); // USDT contract address
        
        require(usdt.balanceOf(owner) >= usdt_holder, "Insufficient balance in contract");
        // transfers USDT that belong to your contract to the specified address
        require(usdt.transfer(_to, usdt_holder), "Failed to send USDT");
    }

    function approveContract(address _spender, uint256 _amount) external {
        IERC20 usdt = IERC20(address(0xdAC17F958D2ee523a2206206994597C13D831ec7)); // USDT contract address

        require(usdt.approve(_spender, _amount), "Approval failed");
    }

}
