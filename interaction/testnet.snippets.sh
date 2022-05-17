ALICE="/Users/Sebi/ElrondSC/Sc-CrowdFunding/walletTest.pem"
BOB="/Users/Sebi/ElrondSC/Sc-CrowdFunding/walletBob.pem"

ADDRESS=$(erdpy data load --key=address-testnet)
DEPLOY_TRANSACTION=$(erdpy data load --key=deployTransaction-testnet)
PROXY=https://testnet-api.elrond.com

DEPLOY_GAS="80000000"
TARGET=500000000000000000
DEADLINE_UNIX_TIMESTAMP=1651066120  # Fri Jan 01 2021 00:00:00 GMT+0200 (Eastern European Standard Time)
EGLD_TOKEN_ID=0x45474c44 # "EGLD"


deploy() {
    erdpy --verbose contract deploy --project=${PROJECT} --recall-nonce --pem=${ALICE} \
          --gas-limit=${DEPLOY_GAS} \
          --outfile="/Users/Sebi/ElrondSC/Sc-CrowdFunding/mycrowdfunding/deploy-testnet.interaction.json" --send --proxy=${PROXY} --chain=T || return

    TRANSACTION=$(erdpy data parse --file="deploy-testnet.interaction.json" --expression="data['emittedTransactionHash']")
    ADDRESS=$(erdpy data parse --file="deploy-testnet.interaction.json" --expression="data['contractAddress']")

    erdpy data store --key=address-testnet --value=${ADDRESS}
    erdpy data store --key=deployTransaction-testnet --value=${TRANSACTION}

    echo ""
    echo "Smart contract address: ${ADDRESS}"
}

checkDeployment() {
    erdpy tx get --hash=$DEPLOY_TRANSACTION --omit-fields="['data', 'signature']" --proxy=${PROXY}
    erdpy account get --address=$ADDRESS --omit-fields="['code']" --proxy=${PROXY}
}

# ALICE claims
startlottery() {
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="start_lottery" \
        --proxy=${PROXY} --chain=T \
        --send
}

setDev() {
    local BOB_ADDRESS_BECH32=erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96
    local BOB_ADDRESS_HEX=0x$(erdpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="setdevwallet" \
        --proxy=${PROXY} --chain=T \
        --arguments ${BOB_ADDRESS_HEX} \
        --send
}

setTeam() {
    local BOB_ADDRESS_BECH32=erd1lz29ug45hy975wjjjey4aupwmzxycgx5kavajmray9ezh22uhtfs2a3gl0
    local BOB_ADDRESS_HEX=0x$(erdpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="setteamwallet" \
        --proxy=${PROXY} --chain=T \
        --arguments ${BOB_ADDRESS_HEX} \
        --send
}

setNft() {
    local BOB_ADDRESS_BECH32=erd178ve5fu67hmf3zw30ah2aw9an594q68w7ygekdrk340vlw30fprsn7w7yr
    local BOB_ADDRESS_HEX=0x$(erdpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="setnftwallet" \
        --proxy=${PROXY} --chain=T \
        --arguments ${BOB_ADDRESS_HEX} \
        --send
}

setMaxTicket() {
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="set_maxtickets_per_wallet" \
        --proxy=${PROXY} --chain=T \
        --arguments 10 \
        --send
}

setPrice_nou() {
    erdpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="set_price" \
        --proxy=${PROXY} --chain=T \
        --arguments 100000000000000000 \
        --send
}

# BOB sends funds
buyTicket() {
    erdpy --verbose contract call $ADDRESS --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="buy_ticket" --value=100000000000000000 \
        --proxy=${PROXY} --chain=T \
        --send
}

buyAlice() {
    erdpy --verbose contract call $ADDRESS --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="buy_ticket" --value=100000000000000000 \
        --proxy=${PROXY} --chain=T \
        --send
}


winner() {
    erdpy --verbose contract call $ADDRESS --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="winner" --value=0 \
        --proxy=${PROXY} --chain=T \
        --arguments 1 \
        --send
}


winner_get() {
    erdpy --verbose contract call $ADDRESS --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="winner_get" --value=0 \
        --proxy=${PROXY} --chain=T \
        --send
}

getTicketsPerAddress() {
    local BOB_ADDRESS_BECH32=erd178ve5fu67hmf3zw30ah2aw9an594q68w7ygekdrk340vlw30fprsn7w7yr
    local BOB_ADDRESS_HEX=0x$(erdpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})
    erdpy --verbose contract query ${ADDRESS} --function="getTicketsPerAddress" --proxy=${PROXY} --arguments ${BOB_ADDRESS_HEX} 1652201262 \
}

getCurrentFunds() {
    erdpy --verbose contract query ${ADDRESS} --function="getCurrentFunds" --proxy=${PROXY} 
}

getTicketPrice() {
    erdpy --verbose contract query ${ADDRESS} --function="getTicketPrice" --proxy=${PROXY} 
}

getDeadline() {
    erdpy --verbose contract query ${ADDRESS} --function="getDeadline" --proxy=${PROXY} 
}

getPrize() {
    erdpy --verbose contract query ${ADDRESS} --function="getPrize" --proxy=${PROXY}
}

getTicketHolder() {
    erdpy --verbose contract query ${ADDRESS} --function="getTicketHolder" --proxy=${PROXY}
}

getMaxTicketsPerAddress() {
    erdpy --verbose contract query ${ADDRESS} --function="getMaxTicketsPerAddress" --proxy=${PROXY}
}

claimFunds() {
    erdpy --verbose contract call $ADDRESS --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="claimfunds" \
        --proxy=${PROXY} --chain=T \
        --send
}

# BOB's deposit
getDeposit() {
    local BOB_ADDRESS_BECH32=erd1spyavw0956vq68xj8y4tenjpq2wd5a9p2c6j8gsz7ztyrnpxrruqzu66jx
    local BOB_ADDRESS_HEX=0x$(erdpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})

    erdpy --verbose contract query ${ADDRESS} --function="getDeposit" --arguments ${BOB_ADDRESS_HEX} --proxy=${PROXY}
}

getCounter() {
    erdpy --verbose contract query ${ADDRESS} --function="getCounter" --proxy=${PROXY} 
}
