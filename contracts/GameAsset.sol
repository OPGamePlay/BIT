// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
using SafeERC20 for IERC20;


// interface IERC20 { 
//     // function transfer(address _to, uint256 _value) external returns (bool);
//     function balanceOf(address account) external view returns (uint256);
//     function approve(address _spender, uint256 _value) external returns (bool);
//     function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
// }


contract GameAsset is ERC721 {
    address public owner;
    bool public isList;
    uint price_in_uUSDT;
    string AssetMetadata; //IPFS Hash
    IERC20 public usdt;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, uint indexed price_in_uUSDT);
    constructor(string memory MetadataIPFS) ERC721("BIT_GameAsset", "BIT_GA") {
        AssetMetadata = MetadataIPFS; // Bind to a IPFS Hash
        owner = msg.sender;
        isList = false;
        price_in_uUSDT = 1000000; // Defualt price| 1,000,000uUSDT = 1 USDT
        usdt = IERC20(address(0x647c048AB7757a981f7303AD0173750666309d52)); // USDT Address
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

    function getBalance(address _address) external view returns(uint256){
        return usdt.balanceOf(_address);
    }

    function getApprove() public returns(bool){
        usdt.forceApprove(address(this), price_in_uUSDT);
        // require(success, "Approval failed"); // when buyer use this function, give approval to this contract to transfer usdt.
        return true;
    }


    function Purchase() external onlyAvailable{
        // require(usdt.forceApprove(address(this), price_in_uUSDT), "Approval failed"); // when buyer use this function, give approval to this contract to transfer usdt.
        // require(usdt.safeTransferFrom(msg.sender , owner, price_in_uUSDT), "Failed to send USDT");// once the contract get approval, transfer the usdt to owner.
        
        usdt.forceApprove(address(this), price_in_uUSDT);
        usdt.safeTransferFrom(msg.sender , owner, price_in_uUSDT);
        
        // transferOwnership after payment
        address newOwner = address(msg.sender);
        emit OwnershipTransferred(owner, newOwner, price_in_uUSDT);
        owner = newOwner;
        isList = false;
    }

    function getAddress() view public returns(address){
        return address(this);
    }
}
