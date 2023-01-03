use elrond_wasm::{
    api::ManagedTypeApi,
    types::{TokenIdentifier, BigUint},
};

elrond_wasm::derive_imports!();

#[derive(NestedEncode, NestedDecode, TopEncode, TopDecode, TypeAbi)]

pub struct NftInfo<M: ManagedTypeApi> {
    pub token_identifier: TokenIdentifier<M>,
    pub nft_nonce: u64,
    pub timestamp: u64,
    pub reward: BigUint<M>,
    pub withdraw_timestamp: u64,
}

//MultiValueEncoded<MultiValue4<TokenIdentifier,u64,u64,BigUint>>
/* IDEI UTILE

self.transfer_or_save_payment(
    &auction.current_winner,
    nft_type,
    nft_nonce,
    nft_amount_to_send,
    b"bought token at auction",
);

*/