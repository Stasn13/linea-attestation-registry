import { ethers } from "hardhat";
import dotenv from "dotenv";
import { getChainPrefix } from "./utils";

dotenv.config({ path: "../.env" });

async function main() {
  console.log("Updating AttestationRegistry with the chain prefix...");

  const attestationProxyAddress = process.env.ATTESTATION_REGISTRY_ADDRESS;
  if (!attestationProxyAddress) {
    throw new Error("Attestation proxy address not found");
  }

  const attestationRegistry = await ethers.getContractAt("AttestationRegistry", attestationProxyAddress);

  const network = await ethers.provider.getNetwork();
  const chainPrefix = getChainPrefix(network.chainId);
  console.log(`Chain prefix for chain ID ${network.chainId} is ${chainPrefix}`);

  await attestationRegistry.updateChainPrefix(chainPrefix);

  console.log("AttestationRegistry updated!");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
