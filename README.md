## Water Quality Management 

In this project we implement a **Water Quality Management System** using Hyperledger Fabric to ensure a secure , decentralized and private data sharing. The project structure includes the following key components:

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
   Required for compiling and running chaincode.
   - [Go Installation Guide](https://golang.org/doc/install)

4. **Hyperledger Fabric Binaries and Docker Images**  
   Download the Hyperledger Fabric binaries and Docker images using the `fabric-samples` repository.
   ```bash

   A. We clone the Hyperledger Fabric Repository:
   git clone https://github.com/hyperledger/fabric-samples.git
   cd fabric-samples

   B. After that , we download the Hyperledger Fabric binaries and Docker images
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
   A lightweight command-line JSON processor for handling chaincode interactions.
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
### Network Setup/ Configuration

"D:\ecef298bf65b705df387eb0fe79942ca.mp4"
