# Using this frontend template

**Ensure you have already deployed your contract (and have the contract address and abi available), and created a server on your Moralis admin page.**

## Update the following in the index.js file:

```javascript
const serverUrl = "YOUR_MORALIS_SERVER_URL"; //obtain from Moralis admin page
const appId = "YOUR_MORALIS_APP_ID"; //obtain from Moralis admin page
const CONTRACT_ADDRESS = "YOUR_CONTRACT_ADDRESS"; //this is your deployed contract address
const CHAINLINK_ADDRESS = "LINK_TOKEN_CONTRACT_ADDRESS_ON_YOUR_CHOSEN_CHAIN"; //this is the chainlink token address of the network you deployed your contract on
```

## Update the abi.js file with your code's abi. it should look like this:

```javascript
const contractAbi = INSERT_YOUR_ABI_INCLUDING_[]_HERE
```

## Deploy your front end to your moralis server:

1. Open terminal in your front end directory

```
cd front-end
```
    
2. Install the Moralis CLI - you may need to run this command as an administrator

```
npm install -g moralis-admin-cli
```

3. Deploy your front end code

```
moralis-admin-cli deploy
```

4. When prompted, enter your Moralis Api key and Api Secret (obtain both from your server on the Moralis admin page)

5. Select the moralis server where you wish to deploy this front end code

6. The front end will be deployed and you can grab the URL to test it out
