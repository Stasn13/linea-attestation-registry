export const getChainPrefix = (chainId: bigint): `0x${string}` => {
  switch (chainId) {
    case 59140n: // Linea testnet
      return "0x0000000000000000000000000000000000000000000000000000000000000000";
    case 59144n: // Linea mainnet
      return "0x0000000000000000000000000000000000000000000000000000000000000000";
    case 421613n: // Arbitrum testnet
      return "0x0001000000000000000000000000000000000000000000000000000000000000";
    case 42161n: // Arbitrum mainnet
      return "0x0001000000000000000000000000000000000000000000000000000000000000";
    default:
      throw new Error("Unknown network");
  }
};
