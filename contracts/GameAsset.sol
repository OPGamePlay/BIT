// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IERC20 { // 用得到的Function, 不要更改
    function transfer(address _to, uint256 _value) external returns (bool);
    // function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function _mint(address receiver, uint256 amount) external returns (bool);// sepolia usdt function, remove when deploy on mainnet

}

contract GameAsset is ERC721 {
    address public owner;
    bool public isList;
    uint price_in_uUSDT;
    string AssetMetadata; //IPFS Hash
    IERC20 usdt;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, uint indexed price_in_uUSDT);
    constructor(string memory MetadataIPFS) ERC721("BIT_GameAsset", "BIT_GA") {
        AssetMetadata = MetadataIPFS; // Bind to a IPFS Hash
        owner = msg.sender;
        isList = false;
        price_in_uUSDT = 1000000; // Defualt price| 1,000,000uUSDT = 1 USDT
        usdt = IERC20(address(0x32316fE3DDf621fdAa71437Df19b94F9830c1118)); // USDT Address
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Only the Asset owner can call this function");
        _;
    }

    modifier onlyAvailable() {
        require(isList == true, "The Asset is not available now");
        _;
    }

    function setAvailable(bool newIslist) public onlyOwner{
        isList = newIslist;
    }

    function setPrice(uint newPrice) public onlyOwner{
        price_in_uUSDT = newPrice;
    }  
    function getPrice() public view onlyAvailable returns(uint){
        return price_in_uUSDT;
    }

    // Not for trade. Just a gift funcion.
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        emit OwnershipTransferred(owner, newOwner, price_in_uUSDT);
        owner = newOwner;
    }


    function Purchase() public onlyAvailable{
        require(usdt.approve(address(this), price_in_uUSDT), "Approval failed"); // when buyer use this function, give approval to this contract to transfer usdt.
        require(usdt.transferFrom(msg.sender , owner, price_in_uUSDT), "Failed to send USDT");// once the contract get approval, transfer the usdt to owner.
        
        // transferOwnership after payment
        address newOwner = address(msg.sender);
        emit OwnershipTransferred(owner, newOwner, price_in_uUSDT);
        owner = newOwner;
        isList = false;
    }

    function getAddress() view public returns(address){
        return address(this);
    }
    
    // function sendUSDT(address _to) external {
    //     // IERC20 usdt = IERC20(address(0xdAC17F958D2ee523a2206206994597C13D831ec7)); // mainnet USDT
    //     IERC20 usdt = IERC20(address(0x7169D38820dfd117C3FA1f22a697dBA58d90BA06)); // Sepolia USDT
        
    //     require(usdt.balanceOf(owner) >= usdt_holder, "Insufficient balance in contract");
    //     // transfers USDT that belong to your contract to the specified address
    //     require(usdt.transfer(_to, usdt_holder), "Failed to send USDT");
    // }

}
