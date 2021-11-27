# chainlink-hackathon-accidental-art

**This DApp consists of three parts that should be deployed in the following order**

Deploying the external adapter to get random words
Deploying the smart contract for the DApp
Deploying the front end of the DApp

To get started, clone this repository:

```git
git clone https://github.com/nonymousoctopus/chainlink-hackathon-accidental-art.git
```

Navigate to the folder

```bash
cd chainlink-hackathon-accidental-art
```

## 1 - Deploying the external adapter to get random words

The external adapter code and instructions are included in the [random-word-ea](https://github.com/nonymousoctopus/chainlink-hackathon-accidental-art/tree/main/random-word-ea) folder. 

## 2 - Deploying the smart contract for the DApp

1. Create a .env file using the .env.example provided, and fill in your details. You will need an RPC URL, Private Key or Mnemonic, and the API Key for etherscan/polygonscan etc...

2. Update the helper-hardhat-config.js file with your Oracle contract address, and job ID (as per your external adapter set up).

3. Install hardhat and hardhat-deploy

* Install hardhat:

```bash
npm install --save-dev hardhat
```

* Install hardhat-deploy

```bash
yarn add hardhat-deploy
```

4. Deploy your contract 

* To a localhost

```bash
npx hardhat deploy
```

* To a testnet

```bash
npx hardhat deploy --network NETWOR_NAME --tags aart
```

5. Verify your contract using the verification code provided at deployment (it will look similar to the below code)

```bash
npx hardhat verify --network NETWORK_NAME CONTRACT_ADDRESS VRF_COORDINATOR_ADDRESS LINK_TOKEN_ADDRESS KEY_HASH FEE ORACLE_ADDRESS JOB_ID
```

6. Copy your contract address and ABI for the next step

## 3 - Deploying the front end of the DApp

The front end DApp code and instructions are included in the [front-end](https://github.com/nonymousoctopus/chainlink-hackathon-accidental-art/tree/main/front-end) folder.