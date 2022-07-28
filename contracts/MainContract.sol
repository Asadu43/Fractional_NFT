pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./FractionToken.sol";

import "hardhat/console.sol";

contract MainContract is ERC721Holder, ReentrancyGuard {
    mapping(address => CurrentDepositedNFTs) nftDeposits;
    uint256 depositsMade;
    address contractDeployer;
    address lastAddress;

    constructor() {
        depositsMade = 0;
        contractDeployer = msg.sender;
    }

    struct NFTDeposit {
        address owner;
        address NFTContractAddress;
        ERC721 NFT;
        uint256 supply;
        uint256 tokenId;
        uint256 depositTimestamp;
        address fractionContractAddress;
        FractionToken fractionToken;
        bool hasFractionalised;
        bool canWithdraw;
        bool isChangingOwnership;
    }

    struct CurrentDepositedNFTs {
        NFTDeposit[] deposits;
    }

    modifier contractDeployerOnly() {
        require(
            msg.sender == contractDeployer,
            "Only contract deployer can call this function"
        );
        _;
    }

    function depositNft(address _NFTContractAddress, uint256 _tokenId)
        public
        nonReentrant
    {
        NFTDeposit memory newInfo;
        newInfo.NFT = ERC721(_NFTContractAddress);
        // require(
        //     newInfo.NFT.ownerOf(_tokenId) == msg.sender,
        //     "You do not own this NFT"
        // );
        //can this be reentrency
        newInfo.NFT.safeTransferFrom(msg.sender, address(this), _tokenId);
        newInfo.NFTContractAddress = _NFTContractAddress;
        newInfo.owner = msg.sender;
        newInfo.tokenId = _tokenId;
        newInfo.depositTimestamp = block.timestamp;
        newInfo.hasFractionalised = false;
        newInfo.canWithdraw = true;
        nftDeposits[msg.sender].deposits.push(newInfo);
        lastAddress = msg.sender;
    }

    function createFraction(
        address _NFTContractAddress,
        uint256 _tokenId,
        uint256 _supply,
        string memory _tokenName,
        string memory _tokenTicker
    ) public {
        for (uint256 i = 0; i < nftDeposits[msg.sender].deposits.length; i++) {
            if (
                nftDeposits[msg.sender].deposits[i].NFTContractAddress ==
                _NFTContractAddress &&
                nftDeposits[msg.sender].deposits[i].tokenId == _tokenId &&
                nftDeposits[msg.sender].deposits[i].owner == msg.sender
            ) {
                FractionToken fraction = new FractionToken(
                    msg.sender,
                    _supply,
                    _tokenName,
                    _tokenTicker,
                    address(this)
                );

                console.log("Hellllllllll0", address(fraction));

                nftDeposits[msg.sender].deposits[i].hasFractionalised = true;
                nftDeposits[msg.sender].deposits[i].fractionToken = fraction;
                nftDeposits[msg.sender]
                    .deposits[i]
                    .fractionContractAddress = address(fraction);
                break;
            }
        }
    }

    function withdrawNft(
        address _NFTContractAddress,
        uint256 _tokenId,
        address _TokenContractAddress
    ) public {
        CurrentDepositedNFTs memory userDeposits = nftDeposits[msg.sender];
        FractionToken fractionToken = FractionToken(_TokenContractAddress);

        for (uint256 i = 0; i < nftDeposits[msg.sender].deposits.length; i++) {
            if (
                nftDeposits[msg.sender].deposits[i].NFTContractAddress ==
                _NFTContractAddress &&
                nftDeposits[msg.sender].deposits[i].tokenId == _tokenId
            ) {
                uint256 totalSupply = fractionToken.totalSupply();

                if (
                    userDeposits.deposits[i].hasFractionalised == false ||
                    fractionToken.balanceOf(msg.sender) == totalSupply
                ) {
                    nftDeposits[msg.sender]
                        .deposits[_tokenId]
                        .NFT
                        .safeTransferFrom(address(this), msg.sender, _tokenId);
                    break;
                }
            }
        }
    }

    function getFractionContractAddress(address _address, uint256 _depositIndex)
        public
        view
        returns (address)
    {
        return
            nftDeposits[_address]
                .deposits[_depositIndex]
                .fractionContractAddress;
    }

    function getNftDeposit(address _address)
        public
        view
        returns (NFTDeposit[] memory)
    {
        return nftDeposits[_address].deposits;
    }

    function getLastFractionId(address _address) public view returns (uint256) {
        return nftDeposits[_address].deposits.length;
    }

    function searchForFractionToken(
        address _NFTContractAddress,
        uint256 _tokenId
    ) public view returns (FractionToken fraction) {
        for (uint256 i = 0; i < nftDeposits[msg.sender].deposits.length; i++) {
            if (
                nftDeposits[msg.sender].deposits[i].NFTContractAddress ==
                _NFTContractAddress &&
                nftDeposits[msg.sender].deposits[i].tokenId == _tokenId
            ) {
                return nftDeposits[msg.sender].deposits[i].fractionToken;
            }
        }
    }
}
