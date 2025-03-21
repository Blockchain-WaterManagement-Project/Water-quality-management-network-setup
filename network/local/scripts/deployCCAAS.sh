#!/bin/bash
#
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

source scripts/utils.sh

CHANNEL_NAME=${1:-"gershom"}
CC_NAME=${2}
CC_SRC_PATH=${3}
CCAAS_DOCKER_RUN=${4:-"true"}
CC_VERSION=${5:-"1.0"}
CC_SEQUENCE=${6:-"1"}
CC_INIT_FCN=${7:-"NA"}
CC_END_POLICY=${8:-"NA"}
CC_COLL_CONFIG=${9:-"NA"}
DELAY=${10:-"3"}
MAX_RETRY=${11:-"5"}
VERBOSE=${12:-"false"}

CCAAS_SERVER_PORT=9999

: ${CONTAINER_CLI:="docker"}
: ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}
infoln "Using ${CONTAINER_CLI} and ${CONTAINER_CLI_COMPOSE}"

println "executing with the following"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_PATH: ${C_GREEN}${CC_SRC_PATH}${C_RESET}"
println "- CC_VERSION: ${C_GREEN}${CC_VERSION}${C_RESET}"
println "- CC_SEQUENCE: ${C_GREEN}${CC_SEQUENCE}${C_RESET}"
println "- CC_END_POLICY: ${C_GREEN}${CC_END_POLICY}${C_RESET}"
println "- CC_COLL_CONFIG: ${C_GREEN}${CC_COLL_CONFIG}${C_RESET}"
println "- CC_INIT_FCN: ${C_GREEN}${CC_INIT_FCN}${C_RESET}"
println "- CCAAS_DOCKER_RUN: ${C_GREEN}${CCAAS_DOCKER_RUN}${C_RESET}"
println "- DELAY: ${C_GREEN}${DELAY}${C_RESET}"
println "- MAX_RETRY: ${C_GREEN}${MAX_RETRY}${C_RESET}"
println "- VERBOSE: ${C_GREEN}${VERBOSE}${C_RESET}"

FABRIC_CFG_PATH=$PWD/../config/

#User has not provided a name
if [ -z "$CC_NAME" ] || [ "$CC_NAME" = "NA" ]; then
  fatalln "No chaincode name was provided. Valid call example: ./network.sh deployCCAS -ccn basic -ccp ../asset-transfer-basic/chaincode-go "

# User has not provided a path
elif [ -z "$CC_SRC_PATH" ] || [ "$CC_SRC_PATH" = "NA" ]; then
  fatalln "No chaincode path was provided. Valid call example: ./network.sh deployCCAS -ccn basic -ccp ../asset-transfer-basic/chaincode-go "

## Make sure that the path to the chaincode exists
elif [ ! -d "$CC_SRC_PATH" ]; then
  fatalln "Path to chaincode does not exist. Please provide different path."
fi

if [ "$CC_END_POLICY" = "NA" ]; then
  CC_END_POLICY=""
else
  CC_END_POLICY="--signature-policy $CC_END_POLICY"
fi

if [ "$CC_COLL_CONFIG" = "NA" ]; then
  CC_COLL_CONFIG=""
else
  CC_COLL_CONFIG="--collections-config $CC_COLL_CONFIG"
fi

# import utils
. scripts/envVar.sh
. scripts/ccutils.sh

packageChaincode() {

  address="{{.peername}}_${CC_NAME}_ccaas:${CCAAS_SERVER_PORT}"
  prefix=$(basename "$0")
  tempdir=$(mktemp -d -t "$prefix.XXXXXXXX") || error_exit "Error creating temporary directory"
  label=${CC_NAME}_${CC_VERSION}
  mkdir -p "$tempdir/src"

cat > "$tempdir/src/connection.json" <<CONN_EOF
{
  "address": "${address}",
  "dial_timeout": "10s",
  "tls_required": false
}
CONN_EOF

   mkdir -p "$tempdir/pkg"

cat << METADATA-EOF > "$tempdir/pkg/metadata.json"
{
    "type": "ccaas",
    "label": "$label"
}
METADATA-EOF

    tar -C "$tempdir/src" -czf "$tempdir/pkg/code.tar.gz" .
    tar -C "$tempdir/pkg" -czf "$CC_NAME.tar.gz" metadata.json code.tar.gz
    rm -Rf "$tempdir"

    PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CC_NAME}.tar.gz)
  
    successln "Chaincode is packaged  ${address}"
}

buildDockerImages() {
  # if set don't build - useful when you want to debug yourself
  if [ "$CCAAS_DOCKER_RUN" = "true" ]; then
    # build the docker container
    infoln "Building Chaincode-as-a-Service docker image '${CC_NAME}' '${CC_SRC_PATH}'"
    infoln "This may take several minutes..."
    set -x
    ${CONTAINER_CLI} build -f $CC_SRC_PATH/Dockerfile -t ${CC_NAME}_ccaas_image:latest --build-arg CC_SERVER_PORT=9999 $CC_SRC_PATH >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Docker build of chaincode-as-a-service container failed"
    successln "Docker image '${CC_NAME}_ccaas_image:latest' built succesfully"
  else
    infoln "Not building docker image; this the command we would have run"
    infoln "   ${CONTAINER_CLI} build -f $CC_SRC_PATH/Dockerfile -t ${CC_NAME}_ccaas_image:latest --build-arg CC_SERVER_PORT=9999 $CC_SRC_PATH"
  fi
}

startDockerContainer() {
  # start the docker container
  if [ "$CCAAS_DOCKER_RUN" = "true" ]; then
    infoln "Starting the Chaincode-as-a-Service docker container..."
    set -x
    ${CONTAINER_CLI} run --rm -d --name peer0water_quality_data , updating and retrievals,storage_${CC_NAME}_ccaas  \
                  --network Gershom \
                  -e CHAINCODE_SERVER_ADDRESS=0.0.0.0:${CCAAS_SERVER_PORT} \
                  -e CHAINCODE_ID=$PACKAGE_ID -e CORE_CHAINCODE_ID_NAME=$PACKAGE_ID \
                    ${CC_NAME}_ccaas_image:latest

    ${CONTAINER_CLI} run --rm -d --name peer0government_${CC_NAME}_ccaas  \
                  --network Gershom \
                  -e CHAINCODE_SERVER_ADDRESS=0.0.0.0:${CCAAS_SERVER_PORT} \
                  -e CHAINCODE_ID=$PACKAGE_ID -e CORE_CHAINCODE_ID_NAME=$PACKAGE_ID \
                    ${CC_NAME}_ccaas_image:latest

    ${CONTAINER_CLI} run --rm -d --name peer0incentives_contrants_${CC_NAME}_ccaas  \
                  --network Gershom \
                  -e CHAINCODE_SERVER_ADDRESS=0.0.0.0:${CCAAS_SERVER_PORT} \
                  -e CHAINCODE_ID=$PACKAGE_ID -e CORE_CHAINCODE_ID_NAME=$PACKAGE_ID \
                    ${CC_NAME}_ccaas_image:latest

    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Failed to start the container container '${CC_NAME}_ccaas_image:latest' "
    successln "Docker container started succesfully '${CC_NAME}_ccaas_image:latest'" 
  else

    infoln "Not starting docker containers; these are the commands we would have run"
    infoln "    ${CONTAINER_CLI} run --rm -d --name peer0water_quality_data , updating and retrievals,storage_${CC_NAME}_ccaas  \
                  --network Gershom \
                  -e CHAINCODE_SERVER_ADDRESS=0.0.0.0:${CCAAS_SERVER_PORT} \
                  -e CHAINCODE_ID=$PACKAGE_ID -e CORE_CHAINCODE_ID_NAME=$PACKAGE_ID \
                    ${CC_NAME}_ccaas_image:latest"
    infoln "    ${CONTAINER_CLI} run --rm -d --name peer0government_${CC_NAME}_ccaas  \
                  --network Gershom \
                  -e CHAINCODE_SERVER_ADDRESS=0.0.0.0:${CCAAS_SERVER_PORT} \
                  -e CHAINCODE_ID=$PACKAGE_ID -e CORE_CHAINCODE_ID_NAME=$PACKAGE_ID \
                    ${CC_NAME}_ccaas_image:latest"
    infoln "    ${CONTAINER_CLI} run --rm -d --name peer0incentives_contrants_${CC_NAME}_ccaas  \
                  --network Gershom \
                  -e CHAINCODE_SERVER_ADDRESS=0.0.0.0:${CCAAS_SERVER_PORT} \
                  -e CHAINCODE_ID=$PACKAGE_ID -e CORE_CHAINCODE_ID_NAME=$PACKAGE_ID \
                    ${CC_NAME}_ccaas_image:latest"


  fi
}

# Build the docker image 
buildDockerImages

## package the chaincode
packageChaincode

## Install chaincode on peer0 of all organizations
infoln "Installing chaincode on peer0.water_quality_data , updating and retrievals,storage..."
installChaincode water_quality_data , updating and retrievals,storage
infoln "Installing chaincode on peer0.government..."
installChaincode government
infoln "Installing chaincode on peer0.incentives_contrants..."
installChaincode incentives_contrants

## query whether the chaincode is installed
queryInstalled water_quality_data , updating and retrievals,storage

## approve the definition for water_quality_data , updating and retrievals,storage
approveForMyOrg water_quality_data , updating and retrievals,storage

## check whether the chaincode definition is ready to be committed
## expect , water_quality_data , updating and retrievals,storag to have approved and remaining not
checkCommitReadiness water_quality_data , updating and retrievals,storage
checkCommitReadiness government
checkCommitReadiness incentives_contrants

## approve the definition for government
approveForMyOrg government

## check whether the chaincode definition is ready to be committed
## expect , water_quality_data , updating and retrievals,storage, governmen to have approved and remaining not
checkCommitReadiness water_quality_data , updating and retrievals,storage
checkCommitReadiness government
checkCommitReadiness incentives_contrants

## approve the definition for incentives_contrants
approveForMyOrg incentives_contrants

## check whether the chaincode definition is ready to be committed
## expect , water_quality_data , updating and retrievals,storage, government, incentives_contrant to have approved and remaining not
checkCommitReadiness water_quality_data , updating and retrievals,storage
checkCommitReadiness government
checkCommitReadiness incentives_contrants

## now that we know for sure both orgs have approved, commit the definition
commitChaincodeDefinition water_quality_data , updating and retrievals,storage government incentives_contrants

## query on all orgs to see that the definition committed successfully
queryCommitted water_quality_data , updating and retrievals,storage
queryCommitted government
queryCommitted incentives_contrants

# start the container
startDockerContainer

## Invoke the chaincode - this does require that the chaincode have the 'initLedger'
## method defined
if [ "$CC_INIT_FCN" = "NA" ]; then
  infoln "Chaincode initialization is not required"
else
  chaincodeInvokeInit water_quality_data , updating and retrievals,storage government incentives_contrants
fi

exit 0

