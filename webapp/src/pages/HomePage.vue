<script>
    import { createWeb3Modal, defaultWagmiConfig } from '@web3modal/wagmi/vue'
    import { polygon } from '@wagmi/core/chains'
    import { ref } from 'vue';

    const projectId = 'b30bc40c0cdef6000cd5066be1febf74'
    const chains = [polygon]
    const wagmiConfig = defaultWagmiConfig({ chains, projectId, appName: 'Verse Labs',  })

    createWeb3Modal({ 
        tokens: {
            137:{
                address:"0xc708d6f2153933daa50b2d0758955be0a93a8fec",
                image:"https://assets.coingecko.com/coins/images/28424/small/verselogo.png?1670461811" 
            },
        
        },
        includeWalletIds: ['107bb20463699c4e614d3a2fb7b961e66f48774cb8f6d6c1aee789853280972c','c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', '19177a98252e07ddfc9af2083ba8e07ef627cb6103467ffebb3f8f4205fd7927'], wagmiConfig, projectId, chains})
    
    </script>


<template>
    <div>
        <h2>Home</h2>
    </div>
</template>

<style lang="scss">
body{
    background-color: black;
    color: white;
}

</style>