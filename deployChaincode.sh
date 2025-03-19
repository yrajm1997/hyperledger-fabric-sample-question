export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_HOSPITAL_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/tls/ca.crt
export PEER0_INSURANCECOMPANY_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/insurancecompany.example.com/peers/peer0.insurancecompany.example.com/tls/ca.crt
export PEER0_PHARMACY_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pharmacy.example.com/peers/peer0.pharmacy.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export PRIVATE_DATA_CONFIG=${PWD}/artifacts/private-data/collections_config.json

export CHANNEL_NAME=mychannel

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

}

setGlobalsForPeer0Hospital(){
    export CORE_PEER_LOCALMSPID="HospitalMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_HOSPITAL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hospital.example.com/users/Admin@hospital.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Hospital(){
    export CORE_PEER_LOCALMSPID="HospitalMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_HOSPITAL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hospital.example.com/users/Admin@hospital.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
    
}

setGlobalsForPeer0InsuranceCompany(){
    export CORE_PEER_LOCALMSPID="InsuranceCompanyMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_INSURANCECOMPANY_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/insurancecompany.example.com/users/Admin@insurancecompany.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    
}

setGlobalsForPeer1InsuranceCompany(){
    export CORE_PEER_LOCALMSPID="InsuranceCompanyMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_INSURANCECOMPANY_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/insurancecompany.example.com/users/Admin@insurancecompany.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
    
}

setGlobalsForPeer0Pharmacy() {
    export CORE_PEER_LOCALMSPID="PharmacyMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PHARMACY_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pharmacy.example.com/users/Admin@pharmacy.example.com/msp
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
    setGlobalsForPeer0Hospital
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.hospital ===================== "
}

# packageChaincode

installChaincode() {
    setGlobalsForPeer0Hospital
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.hospital ===================== "

    setGlobalsForPeer0InsuranceCompany
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.insurancecompany ===================== "
    
    setGlobalsForPeer0Pharmacy
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.pharmacy ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Hospital
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.hospital on channel ===================== "
}

# queryInstalled

approveForMyHospital() {
    setGlobalsForPeer0Hospital
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from Hospital ===================== "

}

# approveForMyHospital

checkCommitReadyness() {
    setGlobalsForPeer0Hospital
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Hospital ===================== "
}

# checkCommitReadyness

approveForMyInsuranceCompany() {
    setGlobalsForPeer0InsuranceCompany

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from Insurance Company ===================== "
}

# approveForMyInsuranceCompany

checkCommitReadyness() {

    setGlobalsForPeer0Hospital
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Hospital ===================== "
}

# checkCommitReadyness

approveForMyPharmacy() {
    setGlobalsForPeer0Pharmacy

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from Clearing House ===================== "
}

# approveForMyPharmacy

checkCommitReadyness() {

    setGlobalsForPeer0Hospital
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Hospital ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0Hospital
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_INSURANCECOMPANY_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_PHARMACY_CA \
        --version ${VERSION} --sequence ${VERSION} --init-required

}

# commitChaincodeDefination

queryCommitted() {
    setGlobalsForPeer0Hospital
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0Hospital
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_HOSPITAL_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_INSURANCECOMPANY_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_PHARMACY_CA \
        --isInit -c '{"Args":[]}'

}

# chaincodeInvokeInit

chaincodeInvoke() {
    setGlobalsForPeer0Hospital

    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 \
        --tlsRootCertFiles $PEER0_HOSPITAL_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_INSURANCECOMPANY_CA \
        -c '{"Args":["createTrade", "T2", "GOOGL", "50", "2800", "2024-12-20T12:00:00Z", "Pending"]}'
}

# chaincodeInvoke

chaincodeQuery() {
    setGlobalsForPeer0InsuranceCompany
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryTrade", "T2"]}'

}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
presetup

packageChaincode
installChaincode

queryInstalled
approveForMyHospital
# checkCommitReadyness
approveForMyInsuranceCompany
# checkCommitReadyness
approveForMyPharmacy
checkCommitReadyness

commitChaincodeDefination
queryCommitted
chaincodeInvokeInit

sleep 5
chaincodeInvoke
sleep 3
chaincodeQuery
