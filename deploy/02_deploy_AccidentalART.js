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
        let SVGShapes = await get('SVGShapes')
        SVGShapesAddress = SVGShapes.address
    } else {
        linkTokenAddress = networkConfig[chainId]['linkToken']
        vrfCoordinatorAddress = networkConfig[chainId]['vrfCoordinator']
        
    }
    const keyHash = networkConfig[chainId]['keyHash']
    const fee = networkConfig[chainId]['fee']
    const oracle = networkConfig[chainId]['oracle']
    const jobId = networkConfig[chainId]['jobId']

    let args = [vrfCoordinatorAddress, linkTokenAddress, keyHash, fee, oracle, jobId]

    log("-----------------------------------------")
    const AccidentalART = await deploy('AccidentalArt', {
        from: deployer, 
        args: args, 
        log: true
    })
    log("You have deployed your NFT contract!")
    const networkName = networkConfig[chainId]["name"]
    log(jobId)
    log(`Verify with: \n npx hardhat verify --network ${networkName} ${AccidentalArt.address} ${args.toString().replace(/,/g, " ")
    }`)    
}

module.exports.tags = ['all', 'aart']