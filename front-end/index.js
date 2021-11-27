/* UPDATE THESE */
const serverUrl = "YOUR_MORALIS_SERVER_URL";
const appId = "YOUR_MORALIS_APP_ID";
const CONTRACT_ADDRESS = "YOUR_CONTRACT_ADDRESS"; 
const CHAINLINK_ADDRESS = "LINK_TOKEN_CONTRACT_ADDRESS_ON_YOUR_CHOSEN_CHAIN";
// this is a counter that will allow to check if a refresh is in order
let counter = 0;

Moralis.start({ serverUrl, appId });
let web3;

// start the app and load the existing NFTs
async function initializeApp(){
    let currentUser = Moralis.User.current();3
    if(!currentUser){
        currentUser = await Moralis.Web3.authenticate();
    }
    const options = {address: CONTRACT_ADDRESS, chain: "mumbai"};
    let NFTs = await Moralis.Web3API.token.getAllTokenIds(options);
    let nftOwners = await Moralis.Web3API.token.getNFTOwners(options);
    renderInventory(NFTs, nftOwners);
    web3 = await Moralis.enableWeb3();
    let accounts = await web3.eth.getAccounts();
}

// Fund the creation of a new NFT - you will need 0.0001 link for the VRF job and 0.0001 link for the random word job
async function fundVRF(){
    const options = {type: "erc20", 
                 amount: Moralis.Units.Token("0.0002", "18"), 
                 receiver: CONTRACT_ADDRESS,
                 contractAddress: CHAINLINK_ADDRESS};
    let result = await Moralis.transfer(options);
    console.log("Metamask will ask to approve 3 transactions - 2 back to back, and the last one after a few minutes when the RNG is ready - be patient!");
    allInOne();
}

// this calls the create function in the smart contract, and after 30 seconds (time for the VRF and random word generation) calls the completeNFTMint function
async function allInOne(){
    const accounts = await web3.eth.getAccounts();
    const options = {
        contractAddress: CONTRACT_ADDRESS,
        functionName: "create",
        abi: contractAbi,
        msgValue: Moralis.Units.ETH("0"),
        awaitReceipt: false 
      };
      const tx = await Moralis.executeFunction(options);
      let tokenIdTemp;
      tx.on("confirmation", (confirmationNumber, receipt) => {   
        tokenIdTemp = confirmationNumber.events.requestedRandomSVG.returnValues.tokenId;
      });
      setTimeout(function () {
        console.log("30 sec delay triggered");
        completeNFTMint(tokenIdTemp);
    }, 30000);
}

// this calls the finishMint function of the smart contract, and on receipt confirms the process has completed in the console
async function completeNFTMint(index){
    const accounts = await web3.eth.getAccounts();
    const contract = new web3.eth.Contract(contractAbi, CONTRACT_ADDRESS);
    contract.methods.finishMint(index).send({from: accounts[0], value: 0}) 
    .on("receipt", function(receipt){
        console.log("submitted finish mint function - minting SVG");
    })
}

// function to render the NFTs on the page
function renderInventory(NFTs, nftOwners){
    const parent = document.getElementById("app");
    try {
        for (let i = 0; i < NFTs.result.length; i++){
            const nft = JSON.parse(NFTs.result[i].metadata);
            let htmlString = `
            <div class="gallery-card11-gallery-card">
              <img
                alt="image"
                src="${nft.image}"
                class="gallery-card11-image"
                />
            <h2 class="gallery-card11-text"><span>${nft.name}</span></h2>
            <span class="gallery-card11-text1"><span>${nft.description}</span></span>
            <span class="gallery-card11-text2"><span>Owned by: ${nftOwners.result[i].owner_of}</span></span>
            </div>
            `
            let item = document.createElement("div");
            item.innerHTML = htmlString;
            parent.appendChild(item);
            counter++;
        }
    } catch(error) {
        console.log("Oh-oh, the testnets is a little slow. You may be seeing some issues in rendering the NFTs, please give it a minutes and refresh the page")
    }
}

initializeApp();
document.getElementById("generate").onclick = fundVRF;
document.getElementById("refresh").onclick = testrefresh;

// this tests if the NFT has minted and propogated on the blockchain so that it's metadata is available to render, and if it has, the page will reload, otherwise a message will be displayed in the console
async function testrefresh(){
    const options = {address: CONTRACT_ADDRESS, chain: "mumbai"};
    let NFTs = await Moralis.Web3API.token.getAllTokenIds(options);
    if(NFTs.result.length > counter){
        window.location.reload(true);
    } else{
        console.log("no new NFTs to show yet");
    }
}

/** Template Moralis functions */
async function login() {
  let user = Moralis.User.current();
  if (!user) {
   try {
      user = await Moralis.authenticate({ signingMessage: "Hello World!" })
      console.log(user)
      console.log(user.get('ethAddress'))
   } catch(error) {
     console.log(error)
   }
  }
}


async function logOut() {
  await Moralis.User.logOut();
  console.log("logged out");
}

document.getElementById("btn-login").onclick = login;
document.getElementById("btn-logout").onclick = logOut;