// special version of ethers that hardhat provides, but what does that mean?
const { ethers } = require("hardhat");
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants");

const main = async () => {
  // Address of the whitelist contract that was written in whitelist-dapp
  const whitelistAddress = WHITELIST_CONTRACT_ADDRESS;

  // URL where we can go to and extract the metadata of a Rookie Bot NFT
  const metadataURL = METADATA_URL;

  // creating an instance of the RookieBots contract
  const rookieBotsContract = await ethers.getContractFactory("RookieBots");

  // deploying the contract
  const deployedRookieBotsContract = await rookieBotsContract.deploy(
    metadataURL,
    whitelistAddress
  );

  console.log(
    "deployedRookieBotsContract: ",
    deployedRookieBotsContract.address
  );
};

// run the main function
// when Node.js runs process.exit(), the program is immediately forced to terminate after main() is executed
// process.exit(0) = successful operation, process.exit(1) = failed operation
main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
