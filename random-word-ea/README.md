# Chainlink NodeJS Random Word External Adapter

Created using this template: https://github.com/thodges-gh/CL-EA-NodeJS-Template.git

To deploy on your own chainlink node:

1. From the main project - enter into this directory

```bash
cd random-word-ea
```

2. Install locally

```bash
yarn
```

3. Test

```bash
yarn test
```

Natively run the application (defaults to port 8080):

4. Run

```bash
yarn start
```

5. call the external adapter/API server (run this from a seperate terminal window)

```bash
curl -X POST -H "content-type:application/json" "http://localhost:8080/" --data '{ "id": 0, "data": { } }'
```
The above command does not pass on any data as the api doesn't require it.

You should see a result like this:

{"jobRunID":0,"data":["involvement"],"result":null,"statusCode":200}%   

In this case, the random word is "involvement"

6. Prepare for deployment on your Chainlink node using the instructions below:

## Docker

If you wish to use Docker to run the adapter, you can build the image by running the following command:

```bash
docker build . -t external-adapter
```

Then run it with:

```bash
docker run -p 8080:8080 -it external-adapter:latest
```

## Serverless hosts

After [installing locally](#install-locally):

### Create the zip

```bash
zip -r random-word-ea.zip .
```

### Install to AWS Lambda

- In Lambda Functions, create function
- On the Create function page:
  - Give the function a name
  - Use Node.js 12.x for the runtime
  - Choose an existing role or create a new one
  - Click Create Function
- Under Function code, select "Upload a .zip file" from the Code entry type drop-down
- Click Upload and select the `external-adapter.zip` file
- Handler:
    - index.handler for REST API Gateways
    - index.handlerv2 for HTTP API Gateways
- Add the environment variable (repeat for all environment variables):
  - Key: API_KEY
  - Value: Your_API_key
- Save

#### To Set Up an API Gateway (HTTP API)

If using a HTTP API Gateway, Lambda's built-in Test will fail, but you will be able to externally call the function successfully.

- Click Add Trigger
- Select API Gateway in Trigger configuration
- Under API, click Create an API
- Choose HTTP API
- Select the security for the API
- Click Add

#### To Set Up an API Gateway (REST API)

If using a REST API Gateway, you will need to disable the Lambda proxy integration for Lambda-based adapter to function.

- Click Add Trigger
- Select API Gateway in Trigger configuration
- Under API, click Create an API
- Choose REST API
- Select the security for the API
- Click Add
- Click the API Gateway trigger
- Click the name of the trigger (this is a link, a new window opens)
- Click Integration Request
- Uncheck Use Lamba Proxy integration
- Click OK on the two dialogs
- Return to your function
- Remove the API Gateway and Save
- Click Add Trigger and use the same API Gateway
- Select the deployment stage and security
- Click Add

### Install to GCP

- In Functions, create a new function, choose to ZIP upload
- Click Browse and select the `random-word-ea.zip` file
- Select a Storage Bucket to keep the zip in
- Function to execute: gcpservice

7. Add a bridge on your node

Create a new Bridge as follows:

Bridge Name	$REPLACE_WITH_BRIDGE_NAME
Bridge URL $REPLACE_WITH_YOUR_URL
Confirmations	0
Minimum Contract Payment	0

8. Add a job on your node

Create a new job - modify this template TOML code:

type = "directrequest"
schemaVersion = 1
name = "YOUR_JOB_NAME"
contractAddress = "REPLACE_WITH_YOUR_ORACLE_CONTRACT_ADDRESS"
maxTaskDuration = "0s"
observationSource = """
    decode_log   [type=ethabidecodelog
                  abi="OracleRequest(bytes32 indexed specId, address requester, bytes32 requestId, uint256 payment, address callbackAddr, bytes4 callbackFunctionId, uint256 cancelExpiration, uint256 dataVersion, bytes data)"
                  data="$(jobRun.logData)"
                  topics="$(jobRun.logTopics)"]

    decode_cbor  [type=cborparse data="$(decode_log.data)"]
    fetch        [type=bridge name="$REPLACE_WITH_BRIDGE_NAME" requestData="{\\"id\\": \\"0\\"}"]
    parse        [type="jsonparse" path="data,0" data="$(fetch)"]
    encode_data  [type=ethabiencode abi="(bytes32 value)" data="{ \\"value\\": $(parse) }"]
    encode_tx    [type=ethabiencode
                  abi="fulfillOracleRequest(bytes32 requestId, uint256 payment, address callbackAddress, bytes4 callbackFunctionId, uint256 expiration, bytes32 data)"
                  data="{\\"requestId\\": $(decode_log.requestId), \\"payment\\": $(decode_log.payment), \\"callbackAddress\\": $(decode_log.callbackAddr), \\"callbackFunctionId\\": $(decode_log.callbackFunctionId), \\"expiration\\": $(decode_log.cancelExpiration), \\"data\\": $(encode_data)}"
                 ]
    submit_tx    [type=ethtx to="REPLACE_WITH_YOUR_ORACLE_CONTRACT_ADDRESS" data="$(encode_tx)"]

    decode_log -> decode_cbor -> fetch -> parse -> encode_data -> encode_tx -> submit_tx
"""

Once created, go to the job's definition and copy the externalJobID. It should look this "61b2b923-7311-42ae-9d1c-a7b93c091f35"

You will need to delete the dashes and add "0x" at the begining of the job ID when adding it to the helper-hardhat-config.js file

it shoudl look like this: 0x61b2b923731142ae9d1ca7b93c091f35

9. troubleshooting

The above instructions were based on Node version 1.0.0, if your node doesn't respond correctly, you may need to edit the node's .env file to add webhook v2

edit the .env and add this line

FEATURE_WEBHOOK_V2=true