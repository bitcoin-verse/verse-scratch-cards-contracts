<script>
import { getAccount, waitForTransaction, readContract, writeContract, watchAccount, watchNetwork } from '@wagmi/core'
import { useWeb3Modal, createWeb3Modal } from '@web3modal/wagmi/vue'
import { ref } from 'vue';
import ERC20ABI from '../abi/ERC20.json'
import ContractABI from '../abi/contract.json'
import axios from 'axios'
import Web3 from 'web3'

const web3 = new Web3(new Web3.providers.HttpProvider('https://eth-mainnet.g.alchemy.com/v2/jOIyWO860V1Ekgvo9-WGdjDgNr2nYxlh'));

  const contractAddress = "0xfe5d5C480C575C313f46FFC23df5fbd414D4813e"

  export default {
  setup() {
    let account = getAccount()
    let currentAccountAddress = ref("")
    let modal = useWeb3Modal()
    let reopenAfterConnection = ref(false)
    let accountActive = ref(false)
    let correctNetwork = ref(true)
    let modalActive = ref(false) // false
    let ensLoaded = ref("")
    let verseBalance = ref(0);
    let verseAllowance = ref(0)
    let giftInputLoad = ref(false)
    let giftAddress = ref("");
    let modalLoading = ref(false)
    let loadingMessage = ref("")
    let buyStep = ref(0) // 0
    let giftTicket = ref(false); // false
    
    let ticketInputAddress = ref("")
    let ticketInputValid = ref(true)

    let timeoutId;

    async function onTicketInputChange() {
        ticketInputValid.value = true
        if (timeoutId) {
            clearTimeout(timeoutId);
        }

        timeoutId = setTimeout(async () => {
            ensLoaded.value = ""
            giftInputLoad.value = true
            if(ticketInputAddress.value.length != 42) {
   
                // address is invalid unless its ENS
                try {
                    const address = await web3.eth.ens.getAddress(ticketInputAddress.value);
                    if(address.length > 0) {
                        ensLoaded.value = "ens name: " + ticketInputAddress.value
                        ticketInputAddress.value = address
                        ticketInputValid.value = true
                        giftInputLoad.value = false
                    } else {
                        ticketInputValid.value = false
                        giftInputLoad.value = false
                    }
            
                } catch (e) {
                    let addr = await verseLookup(ticketInputAddress.value)
                    if(addr.length > 0) {
                        ticketInputValid.value = true
                        ensLoaded.value = "verse name: " + ticketInputAddress.value
                        ticketInputAddress.value = addr
                        giftInputLoad.value = false

                    } else {
                        ticketInputValid.value = false
                        giftInputLoad.value = false
                    }
                }
            } else {
                console.log("PROB REAL")
                // address is probably valid
                ticketInputValid.value = true
            }
        }, 500); 

    }

    async function verseLookup(name) {
        try {
            name = name.split("@verse")[0]
            let res = await axios.get(`https://verse-resolver-l6c2rma45q-uc.a.run.app/username/MATIC/${name}`)
            if(res.data) {
                return res.data
            } 
            return ""
        }
        catch(e) {
            console.log(e)
            return ""
        }
    }

    function toggleModal() {
        if(buyStep.value == 4 && modalActive.value == true) {
            // cleanup
            loadingMessage.value = ""
            buyStep.value = 0;
            giftTicket.value = false;
            giftAddress.value == ""
            getBalance()
        }
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

    async function purchaseTicket(_giftAddress) {
        try {
            if(_giftAddress) {
                giftAddress.value = _giftAddress
            }
            loadingMessage.value = "waiting for wallet approval.."
            modalLoading.value = true
            let receiver = getAccount().address
            if(_giftAddress && _giftAddress.length > 0) {
                receiver = _giftAddress
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
                if(giftTicket.value == true) {
                    loadingMessage.value = `payment success! issuing gift ticket to chosen wallet and awaiting final confirmation. Expected arrival in ${timer} seconds!`;
                } else {
                    loadingMessage.value = `payment success! issuing ticket to your wallet and awaiting final confirmation. Expected arrival in ${timer} seconds!`;
                }

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
        
        if(!currentAccountAddress.value) {
            currentAccountAddress.value = getAccount().address
        }
        else {
            if(currentAccountAddress.value != getAccount().address) {
                // new account detected, reload page
                console.log("new acc")
                location.reload()
            }
        }


        if(getAccount().address &&  getAccount().address.length != undefined) {
            accountActive.value = true;
            if(buyStep.value < 1) {
                buyStep.value = 1;
            }

            if(reopenAfterConnection.value == true) {
                reopenAfterConnection.value = false;
                toggleModal()
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
        // reopen after user is connect
        reopenAfterConnection.value = true
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
        giftAddress,
        verseBalance,
        verseAllowance,
        loadingMessage,
        purchaseTicket,
        giftTicket,
        ticketInputAddress,
        toggleGift,
        verseLookup,
        onTicketInputChange,
        ticketInputValid,
        ensLoaded,
        giftInputLoad
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

            <p style="color: white;"><small style="color: white;">Need more help or want to purchase Verse by Credit Card? Learn more about getting Verse at our <a target="blank" style="text-decoration: none; color: #ffaa00; font-weight: 500;" href="https://www.bitcoin.com/get-started/how-to-buy-verse/">Verse Buying Guide</a></small></p>
            <p><small>Bought Verse? click <a @click="getBalance()" style="font-weight: 500; cursor: pointer; text-decoration: none; color: #ffaa01;">here</a> to refresh your balance</small></p>
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
                <hr v-if="giftTicket" style="margin-top: 20px; border-color: black;"/>
                <div v-if="!giftTicket"><br/></div>
                <p class="p-gift" style="font-size: 17px; font-weight: 600" v-if="giftTicket">Send ticket as a gift</p>
                <p v-if="giftTicket" style="font-size: 16px; font-weight: 400;">We will give you a shareable link that you can share with your friend</p>
                <input placeholder="Polygon Address" class="giftInput" @input="onTicketInputChange" style="color: white;" v-model="ticketInputAddress" type="text" v-if="giftTicket == true">
                <p v-if="ensLoaded.length > 0" style="color: white; margin-top: 2px;  font-weight: 500"><small>({{ ensLoaded }})</small></p>
                <p  v-if="!ticketInputValid && ticketInputAddress.length > 0" style="margin-top: 2px; color: rgb(255, 68, 0); font-weight: 500"><small>address is not valid</small></p>

                <div v-if="giftInputLoad == false && giftTicket">
                    <a class="" target="_blank" @click="purchaseTicket(ticketInputAddress)"><button class="btn btn-modal uniswap" v-if="giftTicket && ticketInputValid && ticketInputAddress.length > 0">Gift ticket</button></a>
                    <a class="" target="_blank"><button class="btn btn-modal uniswap" style="background-color: #272631!important; color: white" v-if="ticketInputAddress.length == 0 && giftTicket">Submit an Address</button></a>
                    <a class="" target="_blank" ><button class="btn btn-modal uniswap" style="background-color: #e7e7e7!important;" v-if="giftTicket && !ticketInputValid && ticketInputAddress.length > 0">Input valid address</button></a>
                </div>

                <div v-if="giftInputLoad == true && giftTicket">

                        <div style="text-align: left;">
                            <div class="lds-ring">
                        <div style="height: 20px!important; width: 20px!important;"></div>
                        <div style="height: 20px!important; width: 20px!important;"></div>
                        <div style="height: 20px!important; width: 20px!important;"></div>
                        <div style="height: 20px!important; width: 20px!important;"></div>
                    </div>
                        </div>                    

                </div>

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
                <div v-if="giftTicket">
                    <h3>Gift Purchase Completed</h3>
                     <p>We have sent the ticket to your specified wallet! Share this link with the recipient to let them know:

                        <input class="ticketlink" type="text" :value="`https://main--chipper-hotteok-85cbb2.netlify.app/tickets?gift=1&address=${giftAddress}`">
                     </p>
                     <!-- change this text for gifted tickets -->
                     <a class="" href="/"><button class="btn btn-modal verse">Buy more tickets</button></a>
                     <a class="" href="/tickets"><button class="btn btn-modal uniswap">View your tickets</button></a>

                </div>
                <div v-if="!giftTicket">
                    <h3>Purchase Completed</h3>
                     <p>Time to scratch your ticket!</p>
                     <!-- change this text for gifted tickets -->
                     <a class="" href="/tickets"><button class="btn btn-modal verse">View your tickets!</button></a>
                </div>
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
            <img class="animate__animated animate__fadeInDownBig" src="../assets/scratch_ad4.png">
        </div>
        </div>
    </div>
</template>


<style lang="scss" scoped>
.ticketlink {
    height: 35px; 
    padding-left: 10px;
    width: 80%;
    font-size: 16px;
    font-weight: 500;
    background-color: #464451;
    border: 1px solid #E7E7E7;
    color: white;
    margin-top: 10px;
}
.tit {
    @media(max-width: 880px) {
        max-width: 85%!important;
    }
}
.subtitle {
    @media(max-width: 880px) {
        width: 85%!important;
        margin-top: 0;
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
    width: 375px;
    border: none;
    padding-left: 7px;
    border-radius: 5px;
    height: 33px;
    padding-bottom: 2px;
    margin-top: 10px;
    color: #555;
    background-color: #423f52;
    border: 1px solid white;
    margin-bottom: 9px;
    font-size: 16px;
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
        background: radial-gradient(circle farthest-corner at 10% 20%, rgb(249, 232, 51) 0%, rgb(250, 196, 59) 100.2%);

        font-weight: 600;
    }
    &.uniswap {
        background-color: white!important;
        color: #1c1b22;
    }
}

.wrongNetworkWarning {
    @media(max-width: 880px) {
        font-size: 12px;
        width: calc(100% - 10px);
        padding-left: 10px;
        height: 42px;
        color: white;
        font-weight: 600;
        padding-top: 12px;
    }
    width: 100%;
    height: 38px;
    padding-top: 15px;
    padding-left: 30px;
    font-weight: 600;
    background-color: #ff0085a8;
    color: white;
}
.instant {
    @media(max-width: 880px) {
        display: none;
    }
    width: 200px;
    text-align: center;
    font-size: 12px;
    color: #E7E7E7;
}
.clearfix {
    overflow: auto;
    max-width: 1600px;
    width: 100%;
    @media(max-width: 880px) {
        width: 100%!important;
        position: unset;
    }
}
.bubble {

    @media(max-width: 880px) {
        width: 41%!important;
        margin-right: 2%!important;
    }
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
        @media(max-width: 880px) {
            font-size: 11px;
        }
        color: white;
        font-size: 13px;
        margin: 0;
    }
}
.float-holder{
    margin: 0 auto;
    min-height: 100vh; // remove this after
}
.btn-buy {
    @media(max-width: 880px) {
        width: 100%;
    }
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
    background: radial-gradient(circle farthest-corner at 10% 20%, rgb(249, 232, 51) 0%, rgb(250, 196, 59) 100.2%);


}

.btn-view {
    @media(max-width: 880px) {
        width: 100%;
    }
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
    float: left;
    padding-left: 7%;
    width: 47%;
    color: white;
    @media(max-width: 880px) {
        width: calc(100% - 30px)!important;
        padding: 15px;
        padding-bottom: 200px;
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
    left: 60%;
    float: right;
    width: 21%;
    min-width: 240px;
    margin-right: 8%;
    margin-top: 5px;
    border-radius: 6px;
    padding-left: 100px;
    background-color: transparent;


    img {
        border-radius: 8px;
        width: 100%;
             box-shadow: 5px 6px 5px 1px rgba(255,255,255,0.1);
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
    @media(max-width: 880px) {
        width: 100%;
        padding-top: 0;
    }
    width: 100%;
    padding-top: 50px;
}

h2 {
    text-align: left;
    color: white;
}


.fa-check {
    color: rgb(35, 226, 35);
}

</style>