"use client"

import { getDefaultConfig } from "@rainbow-me/rainbowkit"
import { anvil } from "wagmi/chains"

export default getDefaultConfig({
    appName: "Energy NFT Factory",
    projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID!,
    chains: [anvil],
    ssr: true,
})
