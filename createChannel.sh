export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_CLINIC_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/clinic.example.com/peers/peer0.clinic.example.com/tls/ca.crt
export PEER0_CLINICMANAGEMENT_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/clinicmanagement.example.com/peers/peer0.clinicmanagement.example.com/tls/ca.crt
export PEER0_MEDICALSTORE_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/medicalstore.example.com/peers/peer0.medicalstore.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForOrderer(){
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

createChannel(){
    setGlobalsForPeer0Clinic
    
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.example.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

# createChannel


joinChannel(){
    setGlobalsForPeer0Clinic
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer1Clinic
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer0ClinicManagement
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer1ClinicManagement
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer0MedicalStore
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
}

# joinChannel

updateAnchorPeers(){
    setGlobalsForPeer0Clinic
    peer channel update -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0ClinicManagement
    peer channel update -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0MedicalStore
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
