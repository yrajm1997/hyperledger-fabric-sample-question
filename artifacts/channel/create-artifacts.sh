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

echo "#######    Generating anchor peer update for HospitalMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./HospitalMSPanchors.tx -channelID $CHANNEL_NAME -asOrg HospitalMSP

echo "#######    Generating anchor peer update for InsuranceCompanyMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./InsuranceCompanyMSPanchors.tx -channelID $CHANNEL_NAME -asOrg InsuranceCompanyMSP

echo "#######    Generating anchor peer update for PharmacyMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./PharmacyMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PharmacyMSP
