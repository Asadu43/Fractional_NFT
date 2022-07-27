import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract, BigNumber, Signer } from "ethers";
import { parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import { FractionToken,FractionToken__factory } from "../../typechain";

describe("Asad Token", function async() {

  let signers: Signer[];

  let nftTokenInstance: Contract;
  let mainContract:any;
  let f :FractionToken;
  let owner:SignerWithAddress;
  let user:SignerWithAddress;
  let user2:SignerWithAddress;


  before(async () => {
     [owner, user,user2] = await ethers.getSigners();

    hre.tracer.nameTags[owner.address] = "ADMIN";
    hre.tracer.nameTags[user.address] = "USER1";
    hre.tracer.nameTags[user2.address] = "USER2";

    const MyToken = await ethers.getContractFactory("MyToken", owner);

    nftTokenInstance = await MyToken.deploy();

    const MainContract = await ethers.getContractFactory("MainContract")

    mainContract = await MainContract.deploy();

    hre.tracer.nameTags[nftTokenInstance.address] = "NFT-TOKEN";
    hre.tracer.nameTags[mainContract.address] = "MAIN-TOKEN";
  });


  it("should return TokenName", async function () {
    expect(await nftTokenInstance.callStatic.name()).to.be.equal("MyToken")
  });

  it("All Methods", async function () {

    console.log(nftTokenInstance.functions);
    console.log(mainContract.functions);

    await nftTokenInstance.safeMint();
    await nftTokenInstance.safeMint();
    await nftTokenInstance.safeMint();

    await nftTokenInstance.setApprovalForAll(mainContract.address,true);
    await mainContract.depositNft(nftTokenInstance.address,0)
    await mainContract.depositNft(nftTokenInstance.address,1)
  });
  it("Create Fractions", async function () {

    await mainContract.createFraction(nftTokenInstance.address,0,10,parseEther("100"),"Asad-Token","ASD")
    await mainContract.createFraction(nftTokenInstance.address,1,100,parseEther("100"),"Asad-ULLAH","ASD")
  
  });

  it("Get Fraction Address", async function () {
    console.log(await mainContract.getFractionContractAddress(owner.address,0))
    f = FractionToken__factory.connect(await mainContract.getFractionContractAddress(owner.address,1),owner)
    console.log(f.functions);
    console.log(await f);
    console.log(await f.callStatic.name());
    console.log(await f.callStatic.symbol());
    });

    it("Withdraw NFT", async function () {
      await mainContract.withdrawNft(nftTokenInstance.address,0,f.address)
    });

    it("Token Owner", async function () {
     await f.transfer(user.address,parseEther("10"))
     await f.transfer(user2.address,parseEther("15"))
     console.log( await f.returnTokenOwners())
    });

    it("Search Fraction NFT", async function () {
      console.log(await mainContract.searchForFractionToken(nftTokenInstance.address,1))
    });



});