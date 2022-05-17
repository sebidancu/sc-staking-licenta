#![no_std]

elrond_wasm::imports!();

mod nft_status;
use nft_status::NftInfo;

//use core::intrinsics::caller_location;
//TokenIdentifier::egld()


//const PERCENTAGE_TOTAL: u8 = 100;
//const PERCENTAGE_FEE: u8 = 7;
//const TICKET_PRICE: u8 = 1;

const TOKEN_ID: &[u8; 10] = b"TPC-b1e55b";


#[elrond_wasm::derive::contract]
pub trait Crowdfunding {
    #[init]
    fn init(&self) {

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

    #[payable("*")]
    #[endpoint]
    fn stake_nft(
        &self,
        // token_identifier: TokenIdentifier,
        // nft_nonce: u64,
        ){
        let payments = self.call_value().all_esdt_transfers();
        let identifier = TokenIdentifier::from(ManagedBuffer::new_from_bytes(TOKEN_ID));
        
        if payments.is_empty() {
            let egld_value = self.call_value().egld_value();
            if egld_value > BigUint::from(0 as u32) {
                let _ = self.stake_nft().push(&(TokenIdentifier::egld(), 0, egld_value));
            }
        } else {
            for payment in payments.into_iter() {
                let _ = self.stake_nft().push(&(payment.token_identifier, payment.token_nonce, payment.amount,));
            }
        }


        require!(
            token_identifier == identifier, // verific nft-ul trimis
            "NFT is not valid"
        );


        let timestamp = self.blockchain().get_block_timestamp();
        let address = self.blockchain().get_caller(); //iau wallet
        let caller = self.blockchain().get_caller();
        let reward = BigUint::from(10000000000000000 as u64);


        let info = NftInfo {
            address, 
            token_identifier,
            nft_nonce,
            timestamp,
            reward,
        };

        self.nft_info(&caller).push(&info);
    }



    #[only_owner]
    #[endpoint]
    fn claimfunds(&self){
        let caller = self.blockchain().get_caller(); //iau wallet
        let prize_winner = self.blockchain().get_sc_balance(&TokenIdentifier::egld(), 0); //vad cat am strans din bilete (deposit) si inmultesc cu 93%
        self.send().direct_egld(
            &caller,
            &prize_winner,
            b"Withdrawing the remaining funds...",
        );
        
    }
    
    #[only_owner] //set max tickets per address -> default 1000 
    #[endpoint]
    fn set_maxtickets_per_wallet(&self, maxtickets: BigUint){
        self.max_tickets_per_address().set(maxtickets);
    }

    #[endpoint] //set ticket price
    fn reward_status(&self, address: &ManagedAddress){
        let actual_time_stamp = self.blockchain().get_block_timestamp();
        let info = self.nft_info(&address);
        let time_stamp = info.get(4);
        let reward = info.get(5);
        //let actual_reward = (actual_time_stamp - time_stamp) * reward;
    }

    #[view(getTicketHolder)]
    #[storage_mapper("ticketHolder")]
    fn ticket_holder(&self) -> VecMapper<ManagedAddress>;

    #[view(getStatus)]
    #[storage_mapper("active")]
    fn active(&self) -> SingleValueMapper<bool>;

    #[view(getDeadline)]
    #[storage_mapper("deadline")]
    fn deadline(&self) -> SingleValueMapper<u64>;

    #[view(getRewardStatus)]
    #[storage_mapper("rewardnftstatus")]
    fn reward_nft_status(&self, address: &ManagedAddress) -> SingleValueMapper<BigUint>;

    #[view(getCounter)]
    #[storage_mapper("ticketcounter")]
    fn counter(&self) -> SingleValueMapper<i32>;

    #[view(getMaxTicketsPerAddress)]
    #[storage_mapper("maxTicketsPerAddress")]
    fn max_tickets_per_address(&self) -> SingleValueMapper<BigUint>;

    #[view(getTicketPrice)]
    #[storage_mapper("TicketPrice")]
    fn get_ticket_price(&self) -> SingleValueMapper<BigUint>;

    #[view(getNftInfo)]
    #[storage_mapper("NftInfo")]
    fn nft_info(&self, address: &ManagedAddress) -> VecMapper<NftInfo<Self::Api>>;

    #[storage_mapper("check_payments")]
    fn check_payments(&self) -> VecMapper<(TokenIdentifier, u64, BigUint)>;
}
