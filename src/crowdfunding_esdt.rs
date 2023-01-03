#![no_std]

elrond_wasm::imports!();
elrond_wasm::derive_imports!();

mod nft_status;
use nft_status::NftInfo;

//use core::intrinsics::caller_location;
//TokenIdentifier::egld()

const TOKEN_ID: &[u8; 11] = b"ULBS-c22d32";

#[elrond_wasm::derive::contract]
pub trait Crowdfunding {

    #[init]
    fn init(&self) {

    }

    #[payable("*")]
    #[endpoint]
    fn stake_nft(&self){
        let identifier = TokenIdentifier::from(ManagedBuffer::new_from_bytes(TOKEN_ID));
        let (nft_type, nft_nonce, nft_amount) = self.call_value().payment_as_tuple();

        require!(
            nft_amount == BigUint::from(1 as u32), // verific nft-ul trimis
            "NFT amount is not valid"
        );
        
        require!(
            nft_type == identifier, // verific nft-ul trimis
            "NFT is not valid"
        );
        
        let timestamp = self.blockchain().get_block_timestamp();
        let address = self.blockchain().get_caller(); 
        let caller = self.blockchain().get_caller();
        let reward = BigUint::from(10000000000000000 as u64);
        let token_identifier = nft_type;
        self.set_nonce().set(&nft_nonce);
        self.wallet().set(&address);
        self.identifier().set(&token_identifier);
    
        let info = NftInfo {
            token_identifier,
            nft_nonce,
            timestamp,
            reward,
            withdraw_timestamp : 1,
        };

        self.nft_info(&caller).push(&info);
    }
    
    #[only_owner]
    #[endpoint]
    fn claim_funds(&self){
        self.send_nft(
            self.wallet().get(),
            self.identifier().get(),
            self.set_nonce().get(),
            BigUint::from(1 as u32),
        )
    }

    #[endpoint] 
    fn reward_status(&self){
        let address = self.blockchain().get_caller(); //iau wallet

        for nft in self.nft_info(&address).iter()
        {
            self.reward_nft_status().set(&nft.withdraw_timestamp);
        }
    }


    #[endpoint]
    fn withdraw_request(&self, token_identifier: TokenIdentifier,  nft_nonce: u64)
    {
        let address = self.blockchain().get_caller();
        let timestamp = self.blockchain().get_block_timestamp();
        let withdraw_future_time = timestamp + self.freeze_time().get();
        let mut index = 1;
        let withdraw_timestamp = withdraw_future_time;

        for nft in self.nft_info(&address).iter()
        {
            if nft_nonce == nft.nft_nonce && token_identifier == nft.token_identifier {
                let info_new = NftInfo {
                    token_identifier : nft.token_identifier,
                    nft_nonce : nft.nft_nonce,
                    timestamp: nft.timestamp,
                    reward: nft.reward,
                    withdraw_timestamp,
                };
                self.nft_info(&address).set(index, &info_new);
                //self.new_freeze().set(&nft.withdraw_timestamp);
                self.reward_nft_status().set(&withdraw_future_time);
            }
            index += 1;
        }
    }

    #[endpoint]
    fn claim_nft(&self, token_identifier: TokenIdentifier,  nft_nonce: u64){
        let timestamp = self.blockchain().get_block_timestamp();
        let address = self.blockchain().get_caller();
        //let address_send = self.blockchain().get_caller();
        self.reward_nft_status().set(&timestamp);
        
        //let mut index = 1;

        for nft in self.nft_info(&address).iter(){
                if nft_nonce == nft.nft_nonce && token_identifier == nft.token_identifier {

                require!(
                    nft.withdraw_timestamp != 1, 
                    "Request Withdraw first"
                );

                if nft.withdraw_timestamp > timestamp {
                    require!(
                        timestamp < 1, 
                        "Cooldown Timer Not Expired"
                    );
                }
                else{
                    let wallet =self.blockchain().get_caller();
                    self.send_nft(
                        wallet,
                        nft.token_identifier,
                        nft.nft_nonce,
                        BigUint::from(1 as u32),
                    );

                    //self.nft_info(&address).swap_remove(index);
                    
                    
                }
            }
            //index += 1;
        }



    }
    
    #[endpoint]
    fn claim_rewards(&self, token_identifier: TokenIdentifier,  nft_nonce: u64 ){
        let timestamp = self.blockchain().get_block_timestamp();
        let address = self.blockchain().get_caller();
        let mut index = 1;
        for nft in self.nft_info(&address).iter(){
            if (nft.nft_nonce == nft_nonce) && (nft.token_identifier == token_identifier) {
                if nft.withdraw_timestamp > 1 {
                    require!(
                        timestamp < 1, 
                        "Withdraw request in process"
                    );
                }

                if nft.withdraw_timestamp == 1 {
                    let wallet =self.blockchain().get_caller();
                    let token_id = self.identifier_reward().get();
                    self.calculate_reward(nft.timestamp);
                    let new_reward = self.reward_variable().get();

                    self.send().direct(&wallet, &token_id, 0, &new_reward, &[]);

                    let info_new = NftInfo {
                        token_identifier : nft.token_identifier,
                        nft_nonce : nft.nft_nonce,
                        timestamp: timestamp,
                        reward: nft.reward,
                        withdraw_timestamp: nft.withdraw_timestamp,
                    };

                    self.nft_info(&address).set(index, &info_new);
                    
                }
            }
            
            index += 1;

        }


    }

    //trimite un nft 
    fn send_nft(
        &self,
        to: ManagedAddress,
        token_id: TokenIdentifier,
        nft_nonce: u64,
        amount: BigUint,
    ) {
        self.send().direct(&to, &token_id, nft_nonce, &amount, &[]);
    }

    fn calculate_reward(&self, stake_timestamp:u64){
        let month : u64= 2629743;
        let reward_per_second = self.reward_per_month().get() / month;
        let actual_timestamp = self.blockchain().get_block_timestamp();
        let multiplier = actual_timestamp - stake_timestamp;
        let actual_reward = reward_per_second * multiplier;

        self.reward_variable().set(actual_reward);
    }

    // -> FUNCTII SET <- 
    #[endpoint]
    fn set_freeze_time(&self, time:u64){
        self.freeze_time().set(time);
    }

    #[endpoint]
    fn set_max_reward_per_month_per_nft(&self, price:BigUint){
        // 2629743 s in luna // 10.000 lkmex intr-o luna => 
        self.reward_per_month().set(price);
    }

    #[endpoint]
    fn set_reward_identifier(&self, token_id:TokenIdentifier){
        self.identifier_reward().set(token_id);
    }

    #[view(getRewardStatus)]
    #[storage_mapper("rewardnftstatus")]
    fn reward_nft_status(&self) -> SingleValueMapper<u64>;

    #[view(getRewardPerMonth)]
    #[storage_mapper("rewardpermonth")]
    fn reward_per_month(&self) -> SingleValueMapper<BigUint>;

    #[view(getRewardVariabila)]
    #[storage_mapper("reward_variable")]
    fn reward_variable(&self) -> SingleValueMapper<BigUint>;

    #[view(getNftInfo)]
    #[storage_mapper("NftInfo")]
    fn nft_info(&self, address: &ManagedAddress) -> VecMapper<NftInfo<Self::Api>>; // adr1, adr2,..; adr1 = [timestamp, nft_identifier, nonce] | adr1 = [obiect1, obiect2]

    #[view(getFreezeTime)]
    #[storage_mapper("freeze")]
    fn freeze_time(&self) -> SingleValueMapper<u64>; //timestamp freeze

    #[view(getIdentifierReward)]
    #[storage_mapper("identifierreward")]
    fn identifier_reward(&self) -> SingleValueMapper<TokenIdentifier>;


    // -------- Variabile de test --------
    #[view(getNonce)]
    #[storage_mapper("nonce")]
    fn set_nonce(&self) -> SingleValueMapper<u64>;

    #[view(getWallet)]
    #[storage_mapper("wallet")]
    fn wallet(&self) -> SingleValueMapper<ManagedAddress>;

    #[view(getIdentifier)]
    #[storage_mapper("identifier")]
    fn identifier(&self) -> SingleValueMapper<TokenIdentifier>;

    #[view(getNftFreeze)]
    #[storage_mapper("nftfreeze")]
    fn new_freeze(&self) -> SingleValueMapper<u64>;

}
