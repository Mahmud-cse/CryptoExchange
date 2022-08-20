const { ethers } =require("hardhat");
const { expect } = require("chai");

const tokens=(n)=>{
	return	ethers.utils.parseUnits(n.toString(),'ether')
}

describe('Token',()=>{
    let token,accounts,deployer;
    
	beforeEach(async()=>{
		// Fetch Token from BlockChain
		const Token = await ethers.getContractFactory('Token');
		token = await Token.deploy("My Token","MY",1000000);

		// Getting all the accounts from blockchain
		accounts = await ethers.getSigners();
		deployer= accounts[0];
	})

	describe('Deployment',()=>{
		// Tests go inside here.
		const name='My Token';
		const symbol='MY';
		const decimals='18';
		const totalSupply=tokens(1000000);

		it('has correct name',async()=>{
			// Read Token Name
			// const name = await token.name();
			// Check the name is correct
			expect(await token.name()).to.equal(name);
		})

		it('has correct symbol',async()=>{
			// Read Token Name
			// const symbol = await token.symbol();
			// Check the name is correct
			expect(await token.symbol()).to.equal(symbol);
		})

		it('has correct decimals',async()=>{
			expect(await token.decimals()).to.equal(decimals);
		})

		it('has correct decimals',async()=>{
			expect(await token.totalSupply()).to.equal(totalSupply);
		})

		it('assigns total supply to deployer',async()=>{
			expect(await token.balanceOf(deployer.address)).to.equal(totalSupply);
		})

	})
})