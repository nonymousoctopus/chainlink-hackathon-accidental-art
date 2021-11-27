# Using this frontend template

1. Ensure you have already deployed your contract (and have the contract address and abi available), and created a server on your Moralis admin page.

2. Update the index.js file with your:
    serverUrl - obtain from Moralis admin page
    appId - obtain from Moralis admin page
    CONTRACT_ADDRESS - this is your deployed contract address
    CHAINLINK_ADDRESS - this is the chainlink token address of the network you deployed your contract on

3. Update the abi.js file with your code's abi. 

4. Deploy your front end to your moralis server:

    open terminal in your front end directory

    cd front-end

    install the Moralis CLI - you may need to run this command as an administrator

    npm install -g moralis-admin-cli

    Deploy your front end code

    moralis-admin-cli deploy

    When prompted, enter your Moralis Api key and Api Secret (obtain both from your server on the Moralis admin page)

    Then select the moralis server where you wish to deploy this front end code

    The front end will be deployed and you can grab the URL to test it out