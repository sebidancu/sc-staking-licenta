MYWALLET="erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96" #my wallet
PEM_FILE="/Users/Sebi/Licenta2022/edpy/elrond-sdk-erdpy-main/walletTest.pem" #pem

declare -a TRANSACTIONS=(
  "erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96" #my wallet
)

#Snapshot
declare -a wallet_distribution=(
  'erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96'
)

declare -a CONTRACT=(
  'erd1qqqqqqqqqqqqqpgq46x07dae3w8rr4hawgd7cyk7glt99nd3j0wqhh2mqz'
)
# DO NOT MODIFY ANYTHING FROM HERE ON 

PROXY="https://devnet-gateway.elrond.com"
DENOMINATION="000000000000000000"



# We recall the nonce of the wallet
NONCE=$(erdpy account get --nonce --address="$MYWALLET" --proxy="$PROXY")

function send-nft {
  for transaction in "${TRANSACTIONS[@]}"; do
    n=0
    while [ $n -le 0 ] #nr de adrese in snapshot
      do
      erdpy data store --key=address-devnet --value=$(erdpy wallet bech32 --decode ${wallet_distribution[n]} ) #transforma adresa din snapshot in hex
      echo ADDRESS=$(erdpy data load --key=address-devnet)
    
      set -- $transaction
      erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain D --data ESDTNFTTransfer@5450432d623165353562@04@01@00000000000000000500ae8cff37b98b8e31d6fd721bec12de47d652cdb193dc@7374616b655f6e6674
      echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
      (( NONCE++ ))
      n=$(( n+1 ))
      
      #sleep 20
    done
  done
}

function claim-reward {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain D --data claim_rewards@5450432d623165353562@04
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}

function calculate-reward {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain D --data calculate_reward@6290B890
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}

function withdraw-request {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain D --data withdraw_request@5450432d623165353562@04
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}

function claim-nft {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain D --data calim_nft@5450432d623165353562@04
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}