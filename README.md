# chainlink-hackathon-accidental-art

# TO DO

1. Spin up an external adapter
    a. set up a new testnet node on mumbai - mode contract address: 0x52189af8854482d8a9247E21615C3cc1b22C03BA
    b. deploy bridge
    c. deploy job - jobID: 61b2b923-7311-42ae-9d1c-a7b93c091f35
    d. test the node remain operational when not logged into gui - works - just launch the container the second time using: screen docker start -i containername
    e. copy down new oracle address and job ID and test with contract
    f. add oracle address and job ID to the env file in the deployment
    g. package up the external adapter files - before zipping into the project -tested

    DONE

2. Complete smart contract
    a. finish the updated code - test with an external adapter job ID going into the deployment as string and being cast as bytes32 in contract - DONE as bytes16
    b. test the updated code with multiple blockchains - rinkeby, hardhat and mumbai under the RSVG name or something like it - DONE
    c. rename all instances to Accidental art and save code - DONE
    d. test deployment localy
    e. save the code into project
    f. update all the env and javascript files for smooth deployment and placeholders

3. Finish front end
    a. finish the website
    b. add logo and artwork to the website
    c. finish the front end integration
    d. test website can work on one of the deployed contracts
    e. deploy ewbsite to the moralis server
    f. save the website code to the project

4. Test project can be deployed from the project source files loaded onto github
    a. git clone the project to the computer and write down all the comands and steps needed to deploy a new instance of the project
    b. add all the commands and instructions to the readme, and test again just following them

5. Write up the project on devpost

6. script the video

7. record video and upload to vimeo

8. wrap everything up and post final devpost submission




type = "directrequest"
schemaVersion = 1
name = "Simple-Random-Word-EA"
contractAddress = "0x52189af8854482d8a9247E21615C3cc1b22C03BA"
maxTaskDuration = "0s"
observationSource = """
    decode_log   [type=ethabidecodelog
                  abi="OracleRequest(bytes32 indexed specId, address requester, bytes32 requestId, uint256 payment, address callbackAddr, bytes4 callbackFunctionId, uint256 cancelExpiration, uint256 dataVersion, bytes data)"
                  data="$(jobRun.logData)"
                  topics="$(jobRun.logTopics)"]

    decode_cbor  [type=cborparse data="$(decode_log.data)"]
    fetch        [type=bridge name="simplerandomword" requestData="{\\"id\\": \\"0\\"}"]
    parse        [type="jsonparse" path="data,0" data="$(fetch)"]
    encode_data  [type=ethabiencode abi="(bytes32 value)" data="{ \\"value\\": $(parse) }"]
    encode_tx    [type=ethabiencode
                  abi="fulfillOracleRequest(bytes32 requestId, uint256 payment, address callbackAddress, bytes4 callbackFunctionId, uint256 expiration, bytes32 data)"
                  data="{\\"requestId\\": $(decode_log.requestId), \\"payment\\": $(decode_log.payment), \\"callbackAddress\\": $(decode_log.callbackAddr), \\"callbackFunctionId\\": $(decode_log.callbackFunctionId), \\"expiration\\": $(decode_log.cancelExpiration), \\"data\\": $(encode_data)}"
                 ]
    submit_tx    [type=ethtx to="0x52189af8854482d8a9247E21615C3cc1b22C03BA" data="$(encode_tx)"]

    decode_log -> decode_cbor -> fetch -> parse -> encode_data -> encode_tx -> submit_tx
"""

