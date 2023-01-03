ALICE="/Users/Sebi/ElrondSC/Sc-CrowdFunding/walletTest.pem"
BOB="/Users/Sebi/ElrondSC/Sc-CrowdFunding/walletBob.pem"
WASM_PATH="/Users/Sebi/Licenta/Sc-NftStaking/mycrowdfunding/output/mycrowdfunding.wasm"

#erd1qqqqqqqqqqqqqpgq46x07dae3w8rr4hawgd7cyk7glt99nd3j0wqhh2mqz
ADDRESS=erd1qqqqqqqqqqqqqpgq74ct0n8kpzgmrlcg9xa3es7gr3lzp5vaj0wqe0yce4 #erd1qqqqqqqqqqqqqpgql0hxhuxkuxme6x8leyjy4a86vhq8as6lj0wqrgxvpf #$(erdpy data load --key=address-devnet)
DEPLOY_TRANSACTION=$(erdpy data load --key=deployTransaction-devnet)
PROXY=https://devnet-api.elrond.com

DEPLOY_GAS="80000000"
TARGET=500000000000000000
DEADLINE_UNIX_TIMESTAMP=1651066120  # Fri Jan 01 2021 00:00:00 GMT+0200 (Eastern European Standard Time)
EGLD_TOKEN_ID=0x45474c44 # "EGLD"

#withdraw_request@554c42532d633232643332@02
deploy() {
    erdpy --verbose contract deploy --project=${PROJECT} --recall-nonce --pem=${ALICE} \
          --gas-limit=${DEPLOY_GAS} --metadata-payable \
          --outfile="/Users/Sebi/ElrondSC/Sc-CrowdFunding/mycrowdfunding/deploy-devnet.interaction.json" --send --proxy=${PROXY} --chain=D || return

    TRANSACTION=$(erdpy data parse --file="deploy-devnet.interaction.json" --expression="data['emittedTransactionHash']")
    ADDRESS=$(erdpy data parse --file="deploy-devnet.interaction.json" --expression="data['contractAddress']")

    erdpy data store --key=address-devnet --value=${ADDRESS}
    erdpy data store --key=deployTransaction-devnet --value=${TRANSACTION}

    echo ""
    echo "Smart contract address: ${ADDRESS}"
}

upgradeSC() {
    erdpy --verbose contract upgrade ${ADDRESS} --recall-nonce \
        --bytecode=${WASM_PATH} \
        --pem=${ALICE} \
        --gas-limit=60000000 \
        --proxy=${PROXY} --chain=D \
        --send || return
}

checkDeployment() {
    erdpy tx get --hash=$DEPLOY_TRANSACTION --omit-fields="['data', 'signature']" --proxy=${PROXY}
    erdpy account get --address=$ADDRESS --omit-fields="['code']" --proxy=${PROXY}
}

ClaimNFT() {
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="claim_funds" \
        --proxy=${PROXY} --chain=D \
        --send
}

freeze_time() {
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="set_freeze_time" \
        --proxy=${PROXY} --chain=D \
        --arguments 360 \
        --send
}

set_max_reward_per_month_per_nft(){
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="set_max_reward_per_month_per_nft" \
        --proxy=${PROXY} --chain=D \
        --arguments 1000000000000000000000 \
        --send    
}

set_reward_identifier(){
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="set_reward_identifier" \
        --proxy=${PROXY} --chain=D \
        --arguments ART-cec52d \
        --send    
        #set_reward_identifier@4152542d636563353264
}

calculate_reward(){
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="calculate_reward" \
        --proxy=${PROXY} --chain=D \
        --arguments 5450432d623165353562 \
        --send
}

withdraw_request() {
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="withdraw_request" \
        --proxy=${PROXY} --chain=D \
        --arguments 5450432d623165353562 4\
        --send
} #  withdraw_request@5450432d623165353562@04

getNftInfo() {
    local BOB_ADDRESS_BECH32=erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96
    local BOB_ADDRESS_HEX=0x$(erdpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})
    erdpy --verbose contract query ${ADDRESS} --function="getNftInfo" --proxy=${PROXY} --arguments ${BOB_ADDRESS_HEX} \
}

getFreezeTime() {
    erdpy --verbose contract query ${ADDRESS} --function="getFreezeTime" --proxy=${PROXY} 
}

getNftFreeze_NEW() {
    erdpy --verbose contract query ${ADDRESS} --function="getNftFreeze" --proxy=${PROXY} 
}

getNonce() {
    erdpy --verbose contract query ${ADDRESS} --function="getNonce" --proxy=${PROXY} 
}

getIdentifier() {
    erdpy --verbose contract query ${ADDRESS} --function="getTicketPrice" --proxy=${PROXY} 
}

getRewardStatus() {
    erdpy --verbose contract query ${ADDRESS} --function="getRewardStatus" --proxy=${PROXY} 
}

Reward_Status() {
    erdpy --verbose contract call $ADDRESS --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="reward_status" \
        --proxy=${PROXY} --chain=D \
        --send
}

# BOB's deposit
getDeposit() {
    local BOB_ADDRESS_BECH32=erd1spyavw0956vq68xj8y4tenjpq2wd5a9p2c6j8gsz7ztyrnpxrruqzu66jx
    local BOB_ADDRESS_HEX=0x$(erdpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})

    erdpy --verbose contract query ${ADDRESS} --function="getDeposit" --arguments ${BOB_ADDRESS_HEX} --proxy=${PROXY}
}

getRewardNFT() {
    erdpy --verbose contract query ${ADDRESS} --function="getRewardVariabila" --proxy=${PROXY} 
}
