let {networkConfig} = require('../helper-hardhat-config')

module.exports = async({
    getNamedAccounts,
    deployments,
    getChainId
}) => {
    const { deploy, get, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = await getChainId()

    let linkTokenAddress, vrfCoordinatorAddress

    if(chainId == 31337) {
        //means we are on a local chanin and need to mock the chainlink stuff up - getting from the mock deployment in 00
        let linkToken = await get('LinkToken')
        linkTokenAddress = linkToken.address
        let vrfCoordinatorMock = await get('VRFCoordinatorMock')
        vrfCoordinatorAddress = vrfCoordinatorMock.address
    } else {
        linkTokenAddress = networkConfig[chainId]['linkToken']
        vrfCoordinatorAddress = networkConfig[chainId]['vrfCoordinator']
    }
    const keyHash = networkConfig[chainId]['keyHash']
    const fee = networkConfig[chainId]['fee']
    let args = [vrfCoordinatorAddress, linkTokenAddress, keyHash, fee]

    log("-----------------------------------------")
    const RandomSVG = await deploy('RandomSVG', { /* NEED to update */
        from: deployer, 
        args: args, 
        log: true
    })
    log("You have deployed your NFT contract!")
    const networkName = networkConfig[chainId]["name"]
    log(`Verify with: \n npx hardhat verify --network ${networkName} ${RandomSVG.address} ${args.toString().replace(/,/g, " ")
    }`)

    //fund with link fo rthe vrf generation part
    const linkTokenContract = await ethers.getContractFactory("LinkToken")
    const accounts = await hre.ethers.getSigners()
    const signer = accounts[0]
    const linkToken = new ethers.Contract(linkTokenAddress, linkTokenContract.interface, signer)
    let fund_tx = await linkToken.transfer(RandomSVG.address, fee)
    await fund_tx.wait(1)

    //create an NFT! By calling a random number
    const RandomSVGContract = await ethers.getContractFactory("RandomSVG") /* NEED to update */
    const randomSVG = new ethers.Contract(RandomSVG.address, RandomSVGContract.interface, signer)
    //will likely need to up the gass for more complex SVG
    let creation_tx = await randomSVG.create({ gasLimit: 300000})
    let receipt = await creation_tx.wait(1)
    //start at event 3 because chainlink will empit a few events beforehand as other contracts are used first, then event 3 is the first event of the RandomSVG contract - i.e. event requestedRandomSVG(bytes32 indexed requestId, uint256 indexed tokenId);, and topic is the part in brackets - we want the second one for tokenId
    let tokenId = receipt.events[3].topics[2]
    log(`You've made your NFT! this is token number ${tokenId.toString()}`)
    log(`Let's wait for the Chainlink node to respond...`)

    //split into wether we are testing on local chain or not...

    if (chainId != 31337) {
        //this is going to need to be updated as right now we are just waiting for 180 seconds instead of listening to an event from the chainlink node - needs a long time on rinkeby
        await new Promise(r => setTimeout(r, 180000))
        log(`Now let's finish the mint...`)
        let finish_tx = await randomSVG.finishMint(tokenId, {gasLimit: 5000000 })
        await finish_tx.wait(1)
        log(`You can view the tokenURI here ${await randomSVG.tokenURI(tokenId)}`)
    } else {
        const VRFCoordinatorMock = await deployments.get("VRFCoordinatorMock")
        vrfCoordinator = await ethers.getContractAt("VRFCoordinatorMock", VRFCoordinatorMock.address, signer)
        let vrf_tx = await vrfCoordinator.callBackWithRandomness(receipt.logs[3].topics[1], 9999, RandomSVG.address)
        await vrf_tx.wait(1)
        log("Now let's finish the mint!")
        //this is actually where we need a larger gas limit
        let finish_tx = await randomSVG.finishMint(tokenId, { gasLimit: 5000000 })
        await finish_tx.wait(1)
        log(`You can view the tokenURI here: ${await randomSVG.tokenURI(tokenId)}`)
    }
}

module.exports.tags = ['all', 'rsvg'] /* NEED to update */