<script>
import { getAccount, watchAccount } from '@wagmi/core'
import { useWeb3Modal } from '@web3modal/wagmi/vue'
import { ref } from 'vue';

export default {
    setup() {
        let account = getAccount()
        let modal = useWeb3Modal()
        let accountActive = ref(false)

        function openWalletModal() {
            modal.open()
        }

        watchAccount(async (account) => {
        if(account.isConnected == true) {
            accountActive.value = true;
        } else {
            accountActive.value = false
        }
    })

        return { account, openWalletModal, accountActive} 
    }
    
}
</script>

<template>
    <div class="navbar">
        <a style="cursor: pointer;" href="/"><div class="logo">
            <h2>Verse Labs</h2>
        </div></a>
        <div class="links">
            <ul>
                <li><a href="/" >Get Ticket</a></li>
                <li><a href="/tickets">View Tickets</a></li>
            </ul>
        </div>
        <div class="wallet">
            <button class="btn btn-connect" v-if="!accountActive" @click="openWalletModal">Connect Wallet</button>
            <w3m-button v-if="accountActive"  />
        </div>
    </div>
</template>

<style lang="scss">

.btn-connect {
    margin-top: 2px;
    border: none;
    width: 140px;
    border-radius: 10px;
    font-weight: 600;
    padding: 5px 20px;
    height: 40px;
    background-color: transparent;
    border: 1px solid white;
    color: white;
    cursor: pointer;
}

    .navbar {
        width: 100%;
        height: 70px;
        div.logo {
            color: white;
            padding-left: 30px;
            width: 32%;
            margin: 0;
            float: left;
            @media(max-width: 880px) {
                width: 100%;
            }
 
        }
        div.links { 
            @media(max-width: 880px) {
            width: 100%!important;
            }
            margin: 0;
            padding-top: 10px;
            float: left;
            width: 32%;
            text-align: center;
            ul {
            @media(max-width: 880px) {
                padding-left: 0;
            }
            display: inline-block;
            margin-left: 0 auto;
            list-style-type: none;
                li {
                    
                    float: left;
                    margin-right: 20px;

                    a{
                        text-decoration: none;
                        color: #c6bfff;
                        font-weight: 500;
                    }
                }
            }
        }
        div.wallet {
            @media(max-width: 930px) {
                position: fixed;
                bottom: 16px;
                width: 400px;
                left: 10px;
            }
            margin: 0;
            margin-top: 10px;
            margin-right: 10px;
            float: right;
            padding-top: 5px;
            text-align: right;

            h5 {
                font-weight: 400;
                color: #c6bfff;
                margin-right: 20px;
            }
        }
    }
</style>