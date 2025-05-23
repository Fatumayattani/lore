const hre = require("hardhat");

async function main() {
  const LoreStory = await hre.ethers.getContractFactory("LoreStory");
  const fee = hre.ethers.utils.parseEther("0.01"); // 0.01 AVAX line fee
  const loreStory = await LoreStory.deploy(fee);

  await loreStory.deployed();

  console.log("LoreStory deployed to:", loreStory.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
