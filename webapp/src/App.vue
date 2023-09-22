<script setup>

import { RouterView } from 'vue-router'
import { polygon } from '@wagmi/core/chains'
import NavBar from './components/NavBar.vue'

import { defaultWagmiConfig, createWeb3Modal } from '@web3modal/wagmi/vue'
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
  <body>
    <NavBar />
    <RouterView />
  </body>
</template>

<style lang="scss">
.backdrop {
    position: fixed; 
    top: 0;
    left: 0;
    width: 100%;
    min-height: 100vh;
    background-color: #4343438f;
    z-index: 2;

    .modal {
        @media(max-width: 880px) {
            position: absolute;
            width: 90%;
            left: 0;
            padding: 5%;
        }
        box-shadow: 0 0 20px rgba(17, 17, 29, 0.7);
        width: 450px;
        position: absolute;
        left: calc(50% - 225px);
        top: 150px;
        background-color: #1c1b21;
        border-radius: 5px;
        padding: 30px;
        h3 {
            margin-top: 0;
            color: white;
        }
        p {
            color: white;
        }
        p.iholder {
            text-align:right;
            margin-top: 0;
            margin-right: 5px;
            margin-bottom: 0;
            color: white;
            i {
                cursor: pointer;
            }
        }
    }
  }

body {
  position: fixed;
  width: 100%;
  background-image: url("./assets/bg3.png");
  background-size: 100%;
  margin: 0;
  font-family: 'Montserrat', sans-serif;
  background-color: #171c2b;
  @media(max-width: 1250px) {
    background-size: 130%!important;
    background-repeat: no-repeat;
    background-color: #1a1833;
  }
}

#app {
  width: 100%;
}

svg {
  display: none!important;
}

.lds-ring {
  display: inline-block;
  position: relative;
  width: 80px;
  height: 80px;
}
.lds-ring div {
  box-sizing: border-box;
  display: block;
  position: absolute;
  width: 64px;
  height: 64px;
  margin: 8px;
  border: 8px solid #fff;
  border-radius: 50%;
  animation: lds-ring 1.2s cubic-bezier(0.5, 0, 0.5, 1) infinite;
  border-color: #fff transparent transparent transparent;
}
.lds-ring div:nth-child(1) {
  animation-delay: -0.45s;
}
.lds-ring div:nth-child(2) {
  animation-delay: -0.3s;
}
.lds-ring div:nth-child(3) {
  animation-delay: -0.15s;
}
@keyframes lds-ring {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

</style>
