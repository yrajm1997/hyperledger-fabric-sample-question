export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_HOSPITAL_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/tls/ca.crt
export PEER0_INSURANCECOMPANY_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/insurancecompany.example.com/peers/peer0.insurancecompany.example.com/tls/ca.crt
export PEER0_PHARMACY_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pharmacy.example.com/peers/peer0.pharmacy.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForOrderer(){
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

createChannel(){
    setGlobalsForPeer0Hospital
    
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.example.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

# createChannel


joinChannel(){
    setGlobalsForPeer0Hospital
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer1Hospital
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer0InsuranceCompany
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer1InsuranceCompany
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer0Pharmacy
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
}

# joinChannel

updateAnchorPeers(){
    setGlobalsForPeer0Hospital
    peer channel update -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0InsuranceCompany
    peer channel update -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0Pharmacy
    peer channel update -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

# updateAnchorPeers

createChannel
sleep 3
joinChannel
sleep 2
updateAnchorPeers
