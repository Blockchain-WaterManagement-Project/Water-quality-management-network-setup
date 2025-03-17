## Water Quality Management 

In this project, we implement a **Water Quality Management System** using Hyperledger Fabric to ensure a secure, decentralized ,and private data sharing. The project structure includes the following key components:

### Project Structure

```bash
├── chaincode         # Smart contract logic for water quality management
├── client-ui         # User interface for interacting with the system
├── helia-server      # Backend server for network communication
├── network           # Hyperledger Fabric network setup and configuration (configure Nodes)
├── server-api        # API for handling client-server communication (contains Fabric SDK)
```

### Prerequisites

Before setting up the Hyperledger Fabric network for the Water Quality Management System, we ensure that the following prerequisites are installed:

1. **Docker & Docker Compose**  
   Install Docker and Docker Compose to run Hyperledger Fabric components in containers.
   - [Docker Installation Guide](https://docs.docker.com/get-docker/)
   - [Docker Compose Installation](https://docs.docker.com/compose/install/)

2. **Node.js & npm**  
   Required for running the API server and client UI.
   - [Node.js Download](https://nodejs.org/en/download/)

3. **Go Language**  
   Required for compiling and running chain code.
   - [Go Installation Guide](https://golang.org/doc/install)

4. **Hyperledger Fabric Binaries and Docker Images**  
   Download the Hyperledger Fabric binaries and Docker images using the `fabric-samples` repository.
   ```bash

   A. We clone the Hyperledger Fabric Repository:
   git clone https://github.com/hyperledger/fabric-samples.git
   cd fabric-samples

   B. After that, we download the Hyperledger Fabric binaries and Docker images
   curl -sSL https://bit.ly/2ysbOFE | bash -s
   Python (optional) 
   Required if you plan to interact with the network using Python SDK.
   - [Python Download](https://www.python.org/downloads/)

   C. Again, we  Set Up the Environment :
   export PATH=${PWD}/bin:$PATH
   export FABRIC_CFG_PATH=${PWD}/configtx

   D. Then we do the **pre-testing of the network if everything is working fine**
   1. Navigate to the Sample Directory
   cd basic-network
   2. Start the Network
   ./start.sh
   3. Check the Network Status
   docker ps
    ```

 5. **Git**  
   Required for version control and cloning the project repository.
   - [Git Installation Guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

6. **jq (optional)**  
   A lightweight command-line JSON processor for handling chain code interactions.
   - [jq Installation Guide](https://stedolan.github.io/jq/download/)

---
## System Requirements

- **Operating System**: Linux, macOS, or Windows 11 (**with WSL2**)
- **Memory**: At least 8GB of RAM (**16-32GB recommended**)
- **Disk Space**: At least 50GB of free space

---
## Water-quality-management-network-setup

  We built the network using the `fabric-samples` repository, with the following key files contributing to the setup and operation of the Fabric network.

### Network Key Files for WQM

- **`configtx.yaml`**: Defines channel configurations and policies for the network.
- **`crypto-config.yaml`**: Generates cryptographic materials (certificates and keys) for organizations, peers, and orderers.
- **`docker-compose-cli.yaml`**: Defines the CLI container to interact with the network (e.g., chaincode installation).
- **`docker-compose-couch.yaml`**: Sets up CouchDB as an alternative state database.
- **`docker-compose.yaml`**: Core Docker Compose file for starting the network (peers, orderers, CA, etc.).
- **`connection.yaml`**: Configures client applications for connecting to the network.
- **Chaincode files** (located in `fabric-samples/chaincode/`): Define the business logic (smart contracts) executed on the network.
- **`byfn.sh` / `eyfn.sh`**: Automates network setup and configuration.
- **`genesis.block`**: Genesis block file for starting the ordering service.
- **`mychannel.tx`**: Channel transaction file for creating a channel.
- **Anchor peer update files**: Configurations for updating anchor peers in the network.
- **`.env` (optional)**: Contains environment variables for custom network configuration.

## Starting The Network

1. **Navigate to the network directory**:
   ```bash
   cd fabric-samples/test-network
   cd network
   ./network.sh up
   ./network.sh createChannel
   ./network.sh deployCC
 
### 1. Generate Channel Artifacts
Before starting the network, generate the necessary channel artifacts using the `configtxgen` tool.

```bash
# Generate the Genesis Block
configtxgen -profile <ProfileName> -channelID system-channel -outputBlock ./channel-artifacts/genesis.block

# Generate the Channel Creation Transaction
configtxgen -profile <ProfileName> -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID mychannel
```
### In the course of implementation we alternatively also use Docker Compose to bring up the Hyperledger Fabric network, including peers, orderers, and the Certificate Authority (CA).
 ### Navigate to the network directory

```bash
cd network
```

### Start the network

```bash
docker-compose -f docker-compose.yaml up -d
```
Once the network is up, we create a channel and have peers join the channel
### From the CLI container, create the channel

```bash
peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/mychannel.tx
```
### Join peer to the channel

```bash
peer channel join -b mychannel.block
```
Install the chaincode (smart contract) on all peers and instantiate it on the channel.
### Install chaincode on Peer0

```bash
peer chaincode install -n water-quality -v 1.0 -p github.com/chaincode/water_quality
```
### Instantiate the chaincode on the channel

```bash
peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n water-quality -v 1.0 -c '{"Args":["init"]}'
```
Invoke the chaincode to execute a transaction on the channel (e.g., updating water quality data)
### Invoke the chaincode function

```bash
peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n water-quality -c '{"Args":["updateWaterQuality","river1","75"]}'
```
Query the chaincode to retrieve water quality data.
### Query the water quality data for river1

```bash
peer chaincode query -C mychannel -n water-quality -c '{"Args":["queryWaterQuality","river1"]}'
```
## After all , we also run the application for user's real time operation
### Start the Backend (helia-server):
```bash
cd helia-server
npm install
npm start
```
### Start the Frontend (client-ui)
```bash
cd client-ui
npm install
npm start
```
### Start the API Server (server-api)
```bash
cd server-api
npm install
npm start
```
## A Dynamic Segmentation Mapping Framework for Efficient Smart Contracts in Water Quality Management
Experimental Results
The results are presented for both optimized and unoptimized smart contracts, demonstrating the efficiency improvements achieved through the Dynamic Segmentation Mapping (DSM) framework. The optimized smart contract was deployed on the Sepolia Testnet and can be accessed via Blockscout: https://eth-sepolia.blockscout.com/. The entire project, including an intuitive UI, was deployed on Surge for seamless user interaction.

### How to Use the Application
Visit the deployed project: Water Quality Resource Management.

The UI, built with HTML5 and React, provides an intuitive interface for interacting with the smart contract.

Use Remix IDE to load and interact with the smart contract for advanced testing and transactions.

## Key Features
Smart Contract Deployment: Deployed on the Sepolia Testnet for transparency and accessibility.

Dynamic Segmentation Mapping (DSM): Enhances efficiency in data processing and storage.

Chainlink Oracles: Integrated with external APIs for secure and reliable data fetching.

UI/UX: Built with HTML5 and React for a seamless and user-friendly experience.

Comparative Analysis: Evaluates gas consumption, execution time, and scalability between optimized and unoptimized contracts.

### Screenshots of the System
Below are screenshots showcasing the project's implementation and results:
#### Desktop View
![{635E8621-0242-4E20-A039-3A571FAEB04B}](https://github.com/user-attachments/assets/8368603e-68b4-4701-b98f-290294302bf1)

#### wallet connection page:
 ![{191D82E5-57B4-4891-8E2F-5E64E83BF476}](https://github.com/user-attachments/assets/8abff186-c538-462d-9918-ee99cf10b779)

### Mobile view:
![be943d108f9ccf10661ad50c02b6fb5](https://github.com/user-attachments/assets/8ff90e0d-36b1-4fb2-a732-12df84bfb512)

![e8136880a2a4750f3554fba362b060a](https://github.com/user-attachments/assets/cc4ee75b-f2e6-4708-9568-6cdf538cad06)

![d87af347f1641fdc6976bb86085d7b4](https://github.com/user-attachments/assets/e64faf37-532a-4b8f-ab4b-92236bd2e5e9)

![d1867176b6cf7f4907ee206cbc829c5](https://github.com/user-attachments/assets/79dce437-6003-480d-9f7d-984bb40e5561)

![cb8527720646901d168fc612b7b60cb](https://github.com/user-attachments/assets/49f6b2ef-feab-4cb5-a05b-3da87e5658f1)


### Smart Contract Deployment on Sepolia Testnet:
Deployment on Sepolia
The smart contract deployed on the Sepolia Testnet, accessible via Blockscout.

![{F05B6597-C0BE-4323-BF01-8ED1305BCB39}](https://github.com/user-attachments/assets/ac2fd3ce-4a20-407e-bb95-da067f842cc5)

### User Interface (UI) on Surge:
UI on Surge
The intuitive UI was built with HTML5 and React and deployed on Surge.
Link: https://surge.sh/
![{11F172E3-00F2-451E-8D25-30B8A4C62FD1}](https://github.com/user-attachments/assets/fac6eaed-e376-4ac4-8d20-2f09880be962)


### Gas Consumption Comparison:
### Gas Consumption on smart contracts technique using remix
Comparison of gas consumption between optimized and unoptimized contracts.
![{6D74BFCA-6646-4B20-8990-9487594FDA95}](https://github.com/user-attachments/assets/88264de0-71e1-4b8c-a5e0-a529dc9952b8)

### Impact on the UI with users/ final product
![{51EA771A-39C8-4C10-9217-4DDC40F4CF01}](https://github.com/user-attachments/assets/a85a3852-cce2-4e4a-bb66-63663c69a244)

### Execution Time Analysis:
Execution Time
Analysis of execution time for optimized vs. unoptimized contracts.
![{DF42FAB0-43A7-44A3-B896-4C0093937672}](https://github.com/user-attachments/assets/f97f0a08-468c-4440-866b-6658795451db)

### Chainlink Oracle Integration:
#### Chainlink Integration
Integration of Chainlink oracles for fetching external data.
![{C0F10435-288E-4F7B-89FF-9203DC0886DC}](https://github.com/user-attachments/assets/1381c31e-b9a2-4a66-86bf-a7e277452e4f)

#### How to integrate
1. The code below depicts the initial setup of a smart contract designed for water quality monitoring using Chain-link oracles. The contract, named Water Quality Monitoring, is written in Solidity and imports essential libraries from Chain-link, such as Chain-Link-Client and ConfirmedOwner. These libraries facilitate the integration of Chain-link's decentralized Oracle network, enabling the contract to fetch and verify external data securely. The contract inherits from ChainLinkClient and ConfirmedOwner, ensuring that only the contract owner can initiate certain actions. This setup is crucial for data migration, as it establishes the foundation for securely fetching and processing water quality data from external sources.
   
![image](https://github.com/user-attachments/assets/9eaa4e48-0c9c-428f-b695-0f1c59f35366)


3. The code below shows the constructor and event definitions within the WaterQualityMonitoring contract. The constructor initializes the contract by setting the Chainlink token and oracle addresses, which are essential for interacting with the Chainlink network. It also defines a job ID and a fee for Oracle requests, ensuring that the contract can pay for data retrieval services. The events WaterDataSubmitted, MessageSent, and RequestFulfilled are defined to log important actions, such as data submission and request fulfillment. These events play a critical role in data migration by providing a transparent and immutable record of data transactions, which is vital for auditing and verification purposes
   
![image](https://github.com/user-attachments/assets/0c0239fe-030f-4b9c-bfcd-8a693c5a45d4)


4. The code below illustrates the process of making a data request to an external API via Chainlink. The contract uses the req._add method to specify the API endpoint and the data path, in this case, an image stored on IPFS. The _sendChainLinkRequest function is then called to send the request to the Chainlink oracle network, along with the specified fee. This step is crucial for data migration, as it demonstrates how the contract can fetch and integrate external data into its operations. The ability to request and process data from decentralized storage solutions like IPFS enhances the contract's flexibility and scalability, making it suitable for handling large datasets in water quality monitoring systems
   
![image](https://github.com/user-attachments/assets/44ee74f0-375d-48e2-a66a-28acae222ff8)


 We welcome support and collaboration from researchers, developers, and organizations interested in advancing sustainable and efficient resource management solutions.Thanks!
