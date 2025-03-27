#Generate Crypto artifactes for organizations
cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/

# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="mychannel"

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block

# Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./mychannel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for ClinicMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./ClinicMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ClinicMSP

echo "#######    Generating anchor peer update for ClinicManagementMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./ClinicManagementMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ClinicManagementMSP

echo "#######    Generating anchor peer update for MedicalStoreMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./MedicalStoreMSPanchors.tx -channelID $CHANNEL_NAME -asOrg MedicalStoreMSP
