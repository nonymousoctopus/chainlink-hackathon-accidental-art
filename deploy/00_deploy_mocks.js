module.exports = async({
    getNamedAccounts,
    deployments,
    getChainId
}) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = await getChainId()

    if(chainId == 31337) {
        log("Local network detected! Deploying Mocks...")
        const LinkToken = await deploy('LinkToken', {from: deployer, log: true})
        const VRFCoordinatorMock = await deploy('VRFCoordinatorMock', {
            from: deployer, 
            log: true, 
            args: [LinkToken.address]
        })
        const SVGShapes = await deploy('SVGShapes', {from: deployer, log: true})
        log("Mocks deployed!")
    }
}
//this allows you to deploy just a deployment script tagged with the bellow tags by using something like this in terminal: npx hardhat deploy --tags aart
module.exports.tags = ['all', 'aart']