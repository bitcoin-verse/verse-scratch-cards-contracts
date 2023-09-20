<script>
import { getAccount, waitForTransaction, readContract, writeContract, watchAccount, watchNetwork } from '@wagmi/core'
import { useWeb3Modal, createWeb3Modal, defaultWagmiConfig } from '@web3modal/wagmi/vue'
import { polygon } from '@wagmi/core/chains'
import { ref } from 'vue';
import ERC20ABI from '../abi/ERC20.json'
import ContractABI from '../abi/contract.json'

  const projectId = 'b30bc40c0cdef6000cd5066be1febf74'
  const chains = [polygon]
  const wagmiConfig = defaultWagmiConfig({ chains, projectId, appName: 'Verse Labs',  })
  const contractAddress = "0xa38a1a7e437ef9c27077a62e0e9796be171e164d"
  createWeb3Modal({ 
    tokens: {
        137:{
            address:"0xc708d6f2153933daa50b2d0758955be0a93a8fec",
            image:"https://assets.coingecko.com/coins/images/28424/small/verselogo.png?1670461811" 
        },
    
    },
    includeWalletIds: ['107bb20463699c4e614d3a2fb7b961e66f48774cb8f6d6c1aee789853280972c','c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', '19177a98252e07ddfc9af2083ba8e07ef627cb6103467ffebb3f8f4205fd7927'], wagmiConfig, projectId, chains})
  

  export default {
  setup() {
    let account = getAccount()
    let modal = useWeb3Modal()
    let accountActive = ref(false)
    let correctNetwork = ref(true)
    let modalActive = ref(false)
    let verseBalance = ref(0);
    let verseAllowance = ref(0)
    let modalLoading = ref(false)
    let loadingMessage = ref("")
    let buyStep = ref(0)
    let giftTicket = ref(false);


    function toggleModal() {
        modalActive.value = !modalActive.value;
    }

    async function approve(infiniteApproval) {
        let approvalAmount = 3000000000000000000000
        if(infiniteApproval) {
            approvalAmount = 30000000000000000000000000000
        } 
        loadingMessage.value = "waiting for wallet approval.."
        modalLoading.value = true;
        const { hash } = await writeContract({
        address: '0xc708d6f2153933daa50b2d0758955be0a93a8fec',
        abi: ERC20ABI,
        functionName: 'approve',
        chainId: 137,
        args: [contractAddress, approvalAmount]
        })

        loadingMessage.value = "waiting for transaction to finish.."
        await waitForTransaction({ hash })
        getAllowance()
    }    

    async function purchaseTicket(giftAddress) {
        try {
            loadingMessage.value = "waiting for wallet approval.."
            modalLoading.value = true
            let receiver = getAccount().address
            if(giftAddress && giftAddress.length > 0) {
                receiver = giftAddress
            }
            const { hash } = await writeContract({
            address: contractAddress,
            abi: ContractABI,
            functionName: 'buyScratchTicket',
            chainId: 137,
            args: [receiver]
            })
            loadingMessage.value = "waiting for tx confirmation"
            await waitForTransaction({ hash })
            let timer = 20; 
            // Create an interval to decrement the timer every second
            const countdown = setInterval(() => {
                timer--; // Decrement the timer
                loadingMessage.value = `payment success! issuing ticket to your wallet and awaiting final confirmation. Expected arrival in ${timer} seconds!`;

                if (timer <= 0) {
                    clearInterval(countdown);
                    modalLoading.value = false;
                    buyStep.value = 4;
                }
            }, 1000);

        } catch (e) {
            modalLoading.value = false
            console.log(e)
        }
    }
    async function getAllowance() {
        try {
            // step 1, check balance
            modalLoading.value = true;
            const data = await readContract({
            address: '0xc708d6f2153933daa50b2d0758955be0a93a8fec',
            abi: ERC20ABI,
            functionName: 'allowance',
            args: [getAccount().address, contractAddress]
            })
            modalLoading.value = false;

            /// step 2, check allowance 
      
            if(data) {
                 let dataString = data.toString()
                 verseAllowance.value= parseFloat(dataString) / Math.pow(10, 18);
                 if(verseBalance.value >= 3000 && buyStep.value < 3) {
                    buyStep.value = 3;
                }
            }
            } catch (e) {
                console.log(e)
                modalLoading.value = false;
            }
    }
    async function getBalance() {
        try {
            // step 1, check balance of Verse token
            modalLoading.value = true;
            const data = await readContract({
            address: '0xc708d6f2153933daa50b2d0758955be0a93a8fec',
            abi: ERC20ABI,
            functionName: 'balanceOf',
            args: [getAccount().address]
            })
            modalLoading.value = false;


            if(data) {
                 let dataString = data.toString()
                 verseBalance.value= parseFloat(dataString) / Math.pow(10, 18);
                 if(verseBalance.value >= 3000 && buyStep.value < 2) {
                    buyStep.value = 2;
                    /// step 2, check allowance       
                    getAllowance()
                 }
            }
            } catch (e) {
                console.log(e)
                modalLoading.value = false;
            }
    }
    watchNetwork((network) => {
        if(network.chain && network.chain.id != 137) {
            correctNetwork.value = false
        } else {
            correctNetwork.value = true
        }
    })
    watchAccount(async () => {
        if(getAccount().address &&  getAccount().address.length != undefined) {
            accountActive.value = true;
            if(buyStep.value < 1) {
                buyStep.value = 1;
            }

            getBalance();
        } else {
            console.log("disable account")
            accountActive.value = false
            buyStep.value = 0;
        }
    })

    function connectAndClose() {
        modal.open()
        toggleModal()
    }

    function toggleGift()  {
        giftTicket.value = !giftTicket.value
    }

    return {
        getBalance,
        connectAndClose,
        account,
        buyStep,
        modal,
        accountActive,
        correctNetwork,
        approve,
        modalActive,
        toggleModal,
        modalLoading,
        verseBalance,
        verseAllowance,
        loadingMessage,
        purchaseTicket,
        giftTicket,
        toggleGift
    }
  }
}
</script>

<template>
    <!-- modals -->
    <div class="backdrop" v-if="modalActive">
        <!-- modal for connecting account -->
        <div class="modal" v-if="buyStep == 0">
            <div v-if="modalLoading">
                <p style="text-align: center">{{ loadingMessage }}</p>
                <div style="text-align: center;">
                    <div class="lds-ring"><div></div><div></div><div></div><div></div></div>
                </div>
            </div>
            <div v-if="!modalLoading">
            <p class="iholder"><i @click="toggleModal()" class="fa fa-times"></i></p>
            <h3>Connect Wallet</h3>
            <p>Connect your wallet to get started</p>

            <a @click="connectAndClose()"><button class="btn btn-modal verse" >Connect Wallet</button></a>

            </div>
        </div>
        <!-- // modal for purchasing verse -->
        <div class="modal" v-if="buyStep == 1">
            <div v-if="modalLoading">
                <p style="text-align: center">{{ loadingMessage }}</p>
                <div style="text-align: center;">
                    <div class="lds-ring"><div></div><div></div><div></div><div></div></div>
                </div>
            </div>
            <div v-if="!modalLoading">
            <p class="iholder"><i @click="toggleModal()" class="fa fa-times"></i></p>
            <h3>Purchase Ticket</h3>
            <p>You need 3000 Verse on Polygon in order to purchase a lottery ticket</p>
            <p>Wallet Balance<br> <strong>{{ verseBalance ? verseBalance.toFixed(2) : 0 }} Verse</strong></p>

            <a class="" target="_blank" href="https://verse.bitcoin.com/"><button class="btn btn-modal verse">Buy on Verse Dex</button></a>
            <a class="" target="_blank" href="https://wallet.polygon.technology/polygon/bridge"><button class="btn btn-modal uniswap">Bridge Verse from Ethereum</button></a>

            <p style="color: white;"><small style="color: white;">Need more help or want to purchase Verse by Credit Card? Learn more about getting Verse at our <a target="blank" style="text-decoration: none; color: #ffaa00;" href="https://www.bitcoin.com/get-started/how-to-buy-verse/">Verse Buying Guide</a></small></p>
            <p><small>Bought Verse? click <a @click="getBalance()" style="font-weight: 500; cursor: pointer; text-decoration: none; color: #fac63b;">here</a> to refresh your balance</small></p>
            </div>
        </div>
        <!-- allowance modal -->
        <div class="modal" v-if="buyStep == 2">
            <p class="iholder"><i @click="toggleModal()" class="fa fa-times"></i></p>
            <div v-if="modalLoading">
                <p style="text-align: center">{{ loadingMessage }}</p>
                <div style="text-align: center;">
                    <div class="lds-ring"><div></div><div></div><div></div><div></div></div>
                </div>
            </div>
            <div v-if="!modalLoading">
                <h3>Purchase Step 1/2</h3>
                <p>You need to set approval for 3000 verse from your wallet, this approval is used to purchase your ticket. <br><br>Alternatively you can choose to set an unlimited allowance, this way you can skip this step on your next purchase.</p>
                <a class="" target="_blank" @click="approve()"><button class="btn btn-modal verse">Approve 3000 Verse</button></a>
                <a class="" target="_blank" @click="approve(true)"><button class="btn btn-modal uniswap">Set infinite approval</button></a>

                <p style="color: white;"><small style="color: white;">Approvals are part of the default contract that Polygon tokens use. Learn more at <a target="blank" style="text-decoration: none; color: #ffaa00;" href="https://revoke.cash/learn/approvals/what-are-token-approvals">the token approval faq</a></small></p>
            </div>
        </div>
        <!-- purchase modal -->
        <div class="modal" v-if="buyStep == 3">
            <p class="iholder"><i @click="toggleModal()" class="fa fa-times"></i></p>
            <div v-if="modalLoading">
                <p style="text-align: center">{{ loadingMessage }}</p>
                <div style="text-align: center;">
                    <div class="lds-ring"><div></div><div></div><div></div><div></div></div>
                </div>
            </div>
            <div v-if="!modalLoading">
                <h3>Purchase Step 2/2</h3>
                <p>It seems that you have 3000 Verse in your wallet and the contract approval has been set! <br><br>Choose if you want to buy a ticket for yourself or a friend.</p>
                <a class="" target="_blank" @click="purchaseTicket()"><button class="btn btn-modal verse">Purchase Ticket for myself</button></a>
                <a class="" target="_blank"><button class="btn btn-modal uniswap" @click="toggleGift()" v-if="!giftTicket">Gift a ticket</button></a>
                <hr style="margin-top: 20px; border-color: black;"/>
                <p class="p-gift" v-if="giftTicket">Polygon address to send gift to</p>
                <input class="giftInput" v-model="ticketInputAddress" type="text" v-if="giftTicket == true">
                <a class="" target="_blank" @click="purchaseTicket(ticketInputAddress)"><button class="btn btn-modal uniswap" v-if="giftTicket">Gift ticket</button></a>
                <p style="color: white;"><small style="color: white;">Approvals are part of the default contract that Polygon tokens use. Learn more at <a target="blank" style="text-decoration: none; color: #ffaa00;" href="https://revoke.cash/learn/approvals/what-are-token-approvals">the token approval faq</a></small></p>
            </div>
        </div>
        <!-- normal finish -->
        <div class="modal" v-if="buyStep == 4">
            <p class="iholder"><i @click="toggleModal()" class="fa fa-times"></i></p>
            <div v-if="modalLoading">
                <p style="text-align: center">{{ loadingMessage }}</p>
                <div style="text-align: center;">
                    <div class="lds-ring"><div></div><div></div><div></div><div></div></div>
                </div>
            </div>
            <div v-if="!modalLoading">
                <h3>Purchase Completed</h3>
                <p>Time to scratch your ticket!</p>
                <!-- change this text for gifted tickets -->
                <a class="" href="/tickets"><button class="btn btn-modal verse">View your tickets!</button></a>
            </div>
        </div>
    </div>
    <div class="wrongNetworkWarning" v-if="correctNetwork == false">Wrong network selected, please switch network to Polygon</div>
    <div class="page">
        <div class="float-holder clearfix">
            <div class="card-info">
                <h2>Scratch & Win</h2>
                <h3 class="tit" style="margin-top: 10px; margin-bottom: 20px; ">On-Chain Scratch Tickets Powered by Verse</h3>
                <div class="clearfix">
                <div class="bubble"><p>Scratch Tickets</p></div>
                <div class="bubble"><p>Entry: 3000 Verse</p></div>
                <div class="bubble"><p>Jackpot 100.000 Verse</p></div>
                <div class="bubble"><p>100 tickets available</p></div>
            </div>

            <p class="subtitle" style="font-weight: 300; margin-bottom: 20px; padding-left: 0;">Enjoy the thrill of instant wins and discover your fate with our scratch tickets. Instant payouts, secured by the Polygon blockchain.</p>


            <!-- <div class="blocks">
                <div class="block">
                    <h5>Instant Delivery</h5>
                    <h3><i class="fa-solid fa-bolt-lightning"></i></h3>
                    <p>Scratch tickets in browser and claim prize immediately</p>
                </div>
                <div class="block">
                    <h5>Gift to friends</h5>
                    <h3><i class="fa-solid fa-gift"></i></h3>
                    <p>Tickets are stored in your wallet as an NFT and can be gifted to other users</p>
                </div>
                <div class="block">
                    <h5>Provably Random</h5>
                    <h3><i class="fa-solid fa-check-circle"></i></h3>
                    <p>Prize distribution is provably random using Chainlink VRF service</p>
                </div>
            </div> -->

            <!-- <p><i class="fa-solid fa-check"></i>  Scratch tickets in browser and claim prize immediately</p>

            <p><i class="fa-solid fa-check"></i>  Tickets are ERC721 compatible NFT and can be gifted to other users.</p>

            <p><i class="fa-solid fa-check"></i> Prize distribution is provably random using Chainlink VRF service.</p> -->

            <button class="btn-buy" @click="toggleModal()"><i class="fa-solid fa-gift"></i> Get Ticket</button>
            <a href="/tickets"><button class="btn-view" ><i class="fa-solid fa-list"></i> View My Tickets</button></a>

            <p class="instant"><i class="fa fa-solid fa-bolt-lightning"></i> Instant Delivery</p>

        </div>

        <div class="card-holder">
            <img class="animate__animated animate__fadeInDownBig" src="../assets/scratch_advertisement.png">
        </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.tit {
    @media(max-width: 880px) {
        max-width: 85%!important;
    }
}
.subtitle {
    @media(max-width: 880px) {
        width: 85%!important;
    }
}
.p-gift {
    margin-bottom: 2px;
    font-size: 14px;
    margin-top: 20px;
    font-weight: 500;
}
.giftInput {
    outline: none;
    padding-left: 5px;
    width: 375px;
    border: none;
    border-radius: 5px;
    height: 30px;
    margin-top: 10px;
    color: #555;
}
.btn-modal {
    cursor: pointer;
    margin-top: 10px;
    border-radius: 5px;
    background-color: white;
    color: black;
    border: none;
    margin-right: 5px;
    font-weight: 500;
    font-size: 15px;
    padding: 13px 25px;
    font-weight: 600;

    &.verse {
        background-image: radial-gradient(circle farthest-corner at 10% 20%, rgb(51 249 238) 0%, rgb(19 255 179) 100.2%);
        color: #333;
        font-weight: 600;
    }
    &.uniswap {
        background-color: white!important;
        color: #1c1b22;
    }
}

.wrongNetworkWarning {
    width: 100%;
    height: 38px;
    padding-top: 15px;
    padding-left: 30px;
    font-weight: 600;
    background-color: orange;
    color: white;
}
.instant {
    width: 200px;
    text-align: center;
    font-size: 12px;
    color: #E7E7E7;
}
.clearfix {
    overflow: auto;
    width: 150%;
    margin-top: 0!important;
    @media(max-width: 880px) {
        width: 100%!important;
        position: unset;
    }
}
.bubble {
    margin-bottom: 20px;
    width: 150px; 
    height: 18px;
    padding: 10px;
    text-align: center;
    background-color: #f2f0fe0f;;
    border-radius: 10px;
    float: left;
    margin-right: 10px;
    p {
        color: white;
        font-size: 13px;
        margin: 0;
    }
}
.float-holder{
    width: 100%;
    height: 100%;
    margin-top: 30px;
}
.btn-buy {
    margin-right: 10px;
    width: 200px;
    margin-top: 10px;
    height: 50px;
    background-color: #ffc700;
    color: #333;
    border-radius: 5px;
    font-weight: 600;
    font-size: 17px;
    border: none;
    cursor: pointer;
    background-image: radial-gradient(circle farthest-corner at 10% 20%, rgb(51 249 238) 0%, rgb(19 255 179) 100.2%);

}

.btn-view {
    margin-right: 10px;
    width: 200px;
    margin-top: 20px;
    height: 50px;
    font-weight: 600;
    border-radius: 5px;
    font-size: 17px;
    border: none;
    background-color: transparent;
    border: 1px solid white;
    color: white;
    cursor: pointer;
}

.blocks {
    height: 210px;
    width: 750px;
    .block {
        float: left;
        margin-right: 10px; 
        width: 205px;
        border-radius: 15px;
        height: 150px;
        background-color: #11111d;
        box-shadow: 0 0 20px rgba(17, 17, 29, 0.7);
        padding: 15px;

        h5 {
            margin-top: 0;
            text-align: center;
        }

        h3 {
            text-align: center;
            margin: 0;
            font-size: 30px;
            i {
                color: #c6bfff;
            }
        }

        p {
            text-align: center;
            font-size: 14px;
            color: #777;
            font-weight: 300;
            margin-bottom: 0;
        }
    }
}
.card-info {
    padding: 30px;
    padding-top: 50px;
    padding-left: 150px;
    width: 35%;
    position: absolute;
    left: 0;
    color: white;
    @media(max-width: 880px) {
            width: 100%!important;
            padding: 30px;
            position: unset;
    }

    h2 {
        margin: 0;
        font-size: 40px;

    }
    h3 {
        margin-bottom: 40px;
    }
    p {
        font-weight: 500;
    }
}


.card-holder {
    @media(max-width: 880px) {
        display: none;
    }
    position: absolute;
    left: 60%;
    
    width: 330px;
    margin-top: 10px;
    border-radius: 6px;
    padding-left: 100px;
    background-color: transparent;


    img {
        border-radius: 8px;
        width: 100%;
             box-shadow: 5px 8px 5px 1px rgba(255,255,255,0.2);
        // -webkit-box-shadow: 5px 8px 5px 1px rgba(255,255,255,0.2);
        // -moz-box-shadow: 5px 8px 5px 1px rgba(255,255,255,0.2);
        }
    
    h2 {
        text-align: center;
    }

    .info {
        color: white;
        text-align: center;
        font-size: 14px;
        width: 100%;
    }
}
.page {
    width: 100%;
    min-height: 100vh;
    background-color: #1d1d3acf;
}

h2 {
    text-align: left;
    color: white;
}


.fa-check {
    color: rgb(35, 226, 35);
}










</style>