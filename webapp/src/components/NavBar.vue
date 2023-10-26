<script>
import { getAccount, watchAccount, disconnect } from '@wagmi/core'
import { useWeb3Modal } from '@web3modal/wagmi/vue'
import { ref } from 'vue';

export default {
    setup() {
        let account = getAccount()
        let modal = useWeb3Modal()
        let accountActive = ref(false)
        let connectedProvider = ref("")

        function openWalletModal(refresh) {
            if(refresh) disconnect()
            modal.open()
        }

        const truncateRegex = /^(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})$/;

        function truncateEthAddress(address) {
            const match = address.match(truncateRegex);
            if (!match) return address;
            return `${match[1]}…${match[2]}`;
        };

        watchAccount(async (account) => {
        connectedProvider.value = account.connector.name.toLowerCase()

         
        if(account.isConnected == true) {
            accountActive.value = true;
        } else {
            accountActive.value = false
        }
    })

        return { account, openWalletModal, accountActive, truncateEthAddress, getAccount, connectedProvider} 
    }
    
}
</script>

<template>
    <div class="navbar-mobile">
        <a href="verse.bitcoin.com" target="_blank">
            <div class="nav-chev"></div>
            <div class="nav-verse"></div>
        </a>
        <h3 class="title-nav">Verse Scratch Tickets</h3>
        
        <button class="btn verse-nav" v-if="!accountActive" @click="openWalletModal(true)">Connect</button>
        <button class="btn verse-nav mobile connected" v-if="accountActive" @click="openWalletModal(false)"><div :class="'provider-logo ' + connectedProvider"></div></button>
    </div>
    <div class="navbar">
        <a style="cursor: pointer;" href="/"><div class="logo">
            <h2>Verse Scratch</h2>
        </div></a>
        <!-- <div class="links">
            <ul>
                <li><a href="/" >Get Ticket</a></li>
                <li><a href="/tickets">View Tickets</a></li>
            </ul>
        </div> -->
        <div class="wallet">
            <button class="btn verse-nav" v-if="!accountActive" @click="openWalletModal(true)">Connect Wallet</button>
            <button class="btn verse-nav connected" v-if="accountActive" @click="openWalletModal(false)">{{truncateEthAddress(getAccount().address || "")}} <div :class="'provider-logo ' + connectedProvider"></div></button>
        </div>
    </div>
</template>

<style lang="scss">

.verse-nav {
    border: none;
    outline: none;
    display: flex;
    justify-content: center;
    align-items: center;
    text-decoration: none;
    cursor: pointer;
    text-wrap: nowrap;
    border-radius: 100px;
    font-family: Barlow, Helvetica, sans-serif;
    font-weight: 600;
    color: rgb(255, 255, 255);
    background: linear-gradient(rgb(14, 190, 240) 0%, rgb(0, 133, 255) 100%);
    font-size: 14px;
    height: 36px;
    padding: 0px 16px;
    position: relative;
    &.mobile {
        padding-right: 21px!important;
        background: #3f526e!important;
    }
    &.connected {
        padding-right: 40px;
    }

    .provider-logo {
        position: absolute; 
        width: 28px;
        height: 28px;
        border-radius: 50%;
        right: 5.2px;
        top: 4.5px;
        background-size: cover;

        &.walletconnect {
            background-image: url("./../assets/icons/wc-logo.png");
        }

        &.metamask {
            background-image: url("./../assets/icons/mm-logo.png");
        }
    }
    &:hover {
        background: linear-gradient(rgb(49, 201, 244) 0%, rgb(44, 150, 246) 100%);
    }
    &:active {
        background:linear-gradient(rgb(1, 137, 254) 0%, rgb(44, 150, 246) 100%)
    }
}
.btn-connect {
    @media(max-width: 880px) {
        width: 100%;
    position: fixed;
    bottom: 0;
    font-weight: 600;
    font-size: 15px;
    left: 0;
    height: 50px;
    background-color: #2f2b5d;
    border-radius: 0;
    color: white;
    border: none;
    }
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

    .navbar-mobile {
        background-color: black;
        width: 100%;
        height: 56px;
        position: relative;
        background: linear-gradient(0deg, #0F1823, #0F1823),linear-gradient(0deg, #1A2231, #1A2231);


        .verse-nav {
            position: absolute;
            right: 16px;
            top: 10px;
        }

        .title-nav {
            color:#FFFFFF;
            margin: 0;
            position: absolute;
            left: 80px;
            top: 17.5px;
            font-size:16px;
            font-family: Barlow, Helvetica, sans-serif;
            color: white;
            font-weight: 600;
        }

        a {
            .nav-chev {
                position: absolute;
                left: 8px;
                top: 18px;
                background-image: url("./../assets/icons/chev.png");
                background-size: cover;
                width: 20px;
                height: 20px;
            }

            .nav-verse {
                position: absolute;
                left: 28px;
                top: 10px;
                background-image: url("./../assets/icons/verse-mob.png");
                background-size: cover;
                width: 36px;
                height: 36px;
            }
        }

        @media(min-width: 880px) {
            display: none;
        }
       
    }

    .navbar {
        @media(max-width: 879px) {
            display: none;
        }
        display: block;
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
            padding-top: 0;
            }
            margin: 0;
            padding-top: 10px;
            float: left;
            width: 32%;
            text-align: center;
            ul {
            @media(max-width: 880px) {
                padding-left: 0;
                margin-top: 0;
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
                display: none;
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