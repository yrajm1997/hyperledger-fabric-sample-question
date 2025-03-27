export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_CLINIC_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/clinic.example.com/peers/peer0.clinic.example.com/tls/ca.crt
export PEER0_CLINICMANAGEMENT_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/clinicmanagement.example.com/peers/peer0.clinicmanagement.example.com/tls/ca.crt
export PEER0_MEDICALSTORE_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/medicalstore.example.com/peers/peer0.medicalstore.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export PRIVATE_DATA_CONFIG=${PWD}/artifacts/private-data/collections_config.json

export CHANNEL_NAME=mychannel

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

}

setGlobalsForPeer0Clinic(){
    export CORE_PEER_LOCALMSPID="ClinicMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CLINIC_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/clinic.example.com/users/Admin@clinic.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Clinic(){
    export CORE_PEER_LOCALMSPID="ClinicMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CLINIC_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/clinic.example.com/users/Admin@clinic.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
    
}

setGlobalsForPeer0ClinicManagement(){
    export CORE_PEER_LOCALMSPID="ClinicManagementMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CLINICMANAGEMENT_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/clinicmanagement.example.com/users/Admin@clinicmanagement.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    
}

setGlobalsForPeer1ClinicManagement(){
    export CORE_PEER_LOCALMSPID="ClinicManagementMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CLINICMANAGEMENT_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/clinicmanagement.example.com/users/Admin@clinicmanagement.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
    
}

setGlobalsForPeer0MedicalStore() {
    export CORE_PEER_LOCALMSPID="MedicalStoreMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MEDICALSTORE_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/medicalstore.example.com/users/Admin@medicalstore.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051

}

presetup() {
    echo Vendoring Go dependencies ...
    pushd ./artifacts/chaincode/
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}

# presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./artifacts/chaincode"
CC_NAME="trade-network"

packageChaincode() {
    setGlobalsForPeer0Clinic
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.clinic ===================== "
}

# packageChaincode

installChaincode() {
    setGlobalsForPeer0Clinic
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.clinic ===================== "

    setGlobalsForPeer0ClinicManagement
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.clinicmanagement ===================== "
    
    setGlobalsForPeer0MedicalStore
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.medicalstore ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Clinic
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.clinic on channel ===================== "
}

# queryInstalled

approveForMyClinic() {
    setGlobalsForPeer0Clinic
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from Clinic ===================== "

}

# approveForMyClinic

checkCommitReadyness() {
    setGlobalsForPeer0Clinic
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Clinic ===================== "
}

# checkCommitReadyness

approveForMyClinicManagement() {
    setGlobalsForPeer0ClinicManagement

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from Clinic Management ===================== "
}

# approveForMyClinicManagement

checkCommitReadyness() {

    setGlobalsForPeer0Clinic
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_CLINIC_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Clinic ===================== "
}

# checkCommitReadyness

approveForMyMedicalStore() {
    setGlobalsForPeer0MedicalStore

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from Clearing House ===================== "
}

# approveForMyMedicalStore

checkCommitReadyness() {

    setGlobalsForPeer0Clinic
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_CLINIC_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Clinic ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0Clinic
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_CLINIC_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CLINICMANAGEMENT_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_MEDICALSTORE_CA \
        --version ${VERSION} --sequence ${VERSION} --init-required

}

# commitChaincodeDefination

queryCommitted() {
    setGlobalsForPeer0Clinic
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0Clinic
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_CLINIC_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CLINICMANAGEMENT_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_MEDICALSTORE_CA \
        --isInit -c '{"Args":[]}'

}

# chaincodeInvokeInit

chaincodeInvoke() {
    setGlobalsForPeer0Clinic

    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 \
        --tlsRootCertFiles $PEER0_CLINIC_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_CLINICMANAGEMENT_CA \
        -c '{"Args":["createTrade", "T2", "GOOGL", "50", "2800", "2024-12-20T12:00:00Z", "Pending"]}'
}

# chaincodeInvoke

chaincodeQuery() {
    setGlobalsForPeer0ClinicManagement
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryTrade", "T2"]}'

}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
presetup

packageChaincode
installChaincode

queryInstalled
approveForMyClinic
# checkCommitReadyness
approveForMyClinicManagement
# checkCommitReadyness
approveForMyMedicalStore
checkCommitReadyness

commitChaincodeDefination
queryCommitted
chaincodeInvokeInit

sleep 5
chaincodeInvoke
sleep 3
chaincodeQuery
