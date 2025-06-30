interface ContractsConfig {
    [chainId: number]: {
        ethRelay: string
        componentNft: string
        installationNft: string
    }
}

export const chainsToContracts: ContractsConfig = {
    31337: {
        ethRelay: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
        componentNft: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
        installationNft: "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
    },
}

export const erc20Abi = [{

}]
