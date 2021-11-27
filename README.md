# chainlink-hackathon-accidental-art

**This DApp consists of three parts that should be deployed in the following order**

Deploying the external adapter to get random words
Deploying the smart contract for the DApp
Deploying the front end of the DApp

To get started, clone this repository:

```git
git clone https://github.com/nonymousoctopus/chainlink-hackathon-accidental-art.git
```

## Deploying the external adapter to get random words

The external adapter code and instructions are included in the [random-word-ea](https://github.com/nonymousoctopus/chainlink-hackathon-accidental-art/tree/main/random-word-ea) folder. 

## Deploying the smart contract for the DApp

1. Create a .env file using the .env.example provided, and fill in your details. You will need an RPC URL, Private Key or Mnemonic, and the API Key for etherscan/polygonscan etc...

2. Update the helper-hardhat-config.js file with your Oracle contract address, and job ID (as per your external adapter set up).

3. Install dependencies in the terminal

4. Deploy your contract

5. Verify your contract using the verification code provided at deployment

6. Copy your contract address and ABI for the next step

## Deploying the front end of the DApp

The front end DApp code and instructions are included in the [front-end](https://github.com/nonymousoctopus/chainlink-hackathon-accidental-art/tree/main/front-end) folder