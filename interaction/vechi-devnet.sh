ALICE="/Users/Sebi/Licenta/Sc-NftStaking/walletTest.pem" #main
BOB="/Users/Sebi/Licenta/Sc-NftStaking/walletBob.pem"

ADDRESS=00000000000000000500a78c4f1526940d0b93aa177381fe4831a6f4db9593dc #$(erdpy data load --key=address-devnet)
DEPLOY_TRANSACTION=$(erdpy data load --key=deployTransaction-devnet)
PROXY=https://devnet-gateway.elrond.com

DEPLOY_GAS="80000000"
TARGET=10

DEADLINE_UNIX_TIMESTAMP=1609452000 # Fri Jan 01 2021 00:00:00 GMT+0200 (Eastern European Standard Time)
EGLD_TOKEN_ID=0x45474c44 # "EGLD"

TPC_TOKEN_ID=0x5450432d623165353562
NFT_NONCE=0x03
# args: —metadata-payable
deploy() {
    erdpy --verbose contract deploy --project=${PROJECT} --recall-nonce --pem=${ALICE} \
          --gas-limit=${DEPLOY_GAS} \
          --outfile="/Users/Sebi/Licenta/Sc-NftStaking/mycrowdfunding/deploy-testnet.interaction.json" --send --proxy=${PROXY} --chain=D || return

    TRANSACTION=$(erdpy data parse --file="deploy-testnet.interaction.json" --expression="data['emittedTransactionHash']")
    ADDRESS=$(erdpy data parse --file="deploy-testnet.interaction.json" --expression="data['contractAddress']")

    erdpy data store --key=address-testnet --value=${ADDRESS}
    erdpy data store --key=deployTransaction-testnet --value=${TRANSACTION}

    echo ""
    echo "Smart contract address: ${ADDRESS}"
}

deploySimulate() {
    erdpy --verbose contract deploy --project=${PROJECT} --recall-nonce --pem=${ALICE} \
          --gas-limit=${DEPLOY_GAS} \
          --arguments ${TARGET} ${DEADLINE_UNIX_TIMESTAMP} ${EGLD_TOKEN_ID} \
          --outfile="simulate-devnet.interaction.json" --simulate || return

    TRANSACTION=$(erdpy data parse --file="simulate-devnet.interaction.json" --expression="data['result']['hash']")
    ADDRESS=$(erdpy data parse --file="simulate-devnet.interaction.json" --expression="data['contractAddress']")
    RETCODE=$(erdpy data parse --file="simulate-devnet.interaction.json" --expression="data['result']['returnCode']")
    RETMSG=$(erdpy data parse --file="simulate-devnet.interaction.json" --expression="data['result']['returnMessage']")

    echo ""
    echo "Simulated transaction: ${TRANSACTION}"
    echo "Smart contract address: ${ADDRESS}"
    echo "Deployment return code: ${RETCODE}"
    echo "Deployment return message: ${RETMSG}"
}

checkDeployment() {
    erdpy tx get --hash=$DEPLOY_TRANSACTION --omit-fields="['data', 'signature']"
    erdpy account get --address=$ADDRESS --omit-fields="['code']"
}

# BOB sends funds
calimNFT() {
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=30000000 \
        --function="claim_nfts" --value=0 \
        --proxy=${PROXY} --chain=D \
        --send
}

sendNFT_2() {
    local ALICE_ADDRESS_BECH32=erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96
    local ALICE_ADDRESS_HEX=0x$(erdpy wallet bech32 --decode ${ALICE_ADDRESS_BECH32})

    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=${ALICE_ADDRESS_HEX} \
        --gas-limit=550000 --proxy=$PROXY --chain D  \
        --data ESDTNFTTransfer 5450432d623165353562 2c444e 01 $ADDRESS 7374616b655f6e6674

}

# ALICE claims
claimFunds() {
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="claim" \
        --send
}

# 0 - Funding Period
# 1 - Successful
# 2 - Failed
getNonce() {
    erdpy --verbose contract query ${ADDRESS} --function="getNonce"
}

getWallet() {
    erdpy --verbose contract query ${ADDRESS} --function="getWallet" --proxy=${PROXY} 

}

getIdentifier() {
    erdpy --verbose contract query 00000000000000000500a78c4f1526940d0b93aa177381fe4831a6f4db9593dc --function="getIdentifier"
}

getDeadline() {
    erdpy --verbose contract query ${ADDRESS} --function="getDeadline"
}

# BOB's deposit
getRewardStatus() {
    local ALICE_ADDRESS_BECH32=erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96
    local ALICE_ADDRESS_HEX=0x$(erdpy wallet bech32 --decode ${ALICE_ADDRESS_BECH32})

    erdpy --verbose contract query ${ADDRESS} --function="getRewardStatus" --arguments ${ALICE_ADDRESS_HEX}
}

getNftInfo() {
    local ALICE_ADDRESS_BECH32=erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96
    local ALICE_ADDRESS_HEX=0x$(erdpy wallet bech32 --decode ${ALICE_ADDRESS_BECH32})

    erdpy --verbose contract query ${ADDRESS} --function="getNftInfo" --arguments ${ALICE_ADDRESS_HEX}
}


{
    "scAddress": "erd1qqqqqqqqqqqqqpgq57xy79fxjsxshya2zaecrljgxxn0fku4j0wq0z20tv",
    "funcName": "getNftInfo",
    "args": ["e9e5d24305ef5bded3d3dab5320ab9e48a5aa61bd8ed208542452289c7bf93dc"],
    "caller": "erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96",
    "value": "0"
}