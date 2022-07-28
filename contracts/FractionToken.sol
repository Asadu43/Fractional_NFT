// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

contract FractionToken is ERC20, ERC20Burnable {
    address NFTOwner;
    address VaultContractAddress;
    ERC721 NFT;
    uint256 public rate = 10;
    uint256 public minimumPrice = 0.5 ether;

    event Bought(uint256 amount);

    address[]  tokenOwners;
    mapping(address => bool) isHolding;

    constructor(
        address _NFTOwner,
        uint256 _supply,
        string memory _tokenName,
        string memory _tokenTicker,
        address _vaultContractAddress
    ) ERC20(_tokenName, _tokenTicker) {
        NFTOwner = _NFTOwner;
        _mint(_NFTOwner, _supply);
        VaultContractAddress = _vaultContractAddress;
    }

    function buy(address to) public payable returns (bool) {
        require(msg.value >= minimumPrice, "You need to send some ether");
        uint256 amountTobuy = (msg.value * rate);
        address owner = _msgSender();
        _transfer(owner, to, amountTobuy);
        addNewUser(to);
        emit Bought(amountTobuy);
        return true;
    }

    function burn(uint256 amount) public virtual override {
        _burn(_msgSender(), amount);
    }

    function addNewUser(address newUser) public {
        tokenOwners.push(newUser);
        isHolding[newUser] = true;
    }


        function removeOld(address oldUser,uint256 index) public {
            console.log("hhhhhhhhhhhhhh");
        if (isHolding[oldUser] == true && balanceOf(oldUser) == 0) {
            console.log("hhhhhhhhhhhhhh #333");
                if (tokenOwners[index] == oldUser) {
                    delete tokenOwners[index];
                    isHolding[oldUser] = false;
                }
            
        }
    }

    function updateNFTOwner(address _newOwner) public {
        require(
            msg.sender == VaultContractAddress,
            "Only vault contract can update this nft owner"
        );

        NFTOwner = _newOwner;
    }

    function returnTokenOwners() public view returns (address[] memory) {
        return tokenOwners;
    }

        function totalBalance() public view returns (uint256 bal) {
        return address(this).balance;
    }
}
