use integer::BoundedInt;
use openzeppelin::tests::utils::constants::{
    ZERO, OWNER, SPENDER, RECIPIENT, NAME, SYMBOL, DECIMALS, SUPPLY, VALUE
};
use reflect_cairo::tests::utils::constants;
use reflect_cairo::contracts::reflect::REFLECT::Approval;
use reflect_cairo::contracts::reflect::REFLECT::ERC20Impl;
use reflect_cairo::contracts::reflect::REFLECT::InternalImpl;
use reflect_cairo::contracts::reflect::REFLECT::Transfer;
use reflect_cairo::contracts::reflect::REFLECT;
use openzeppelin::utils::serde::SerializedAppend;
use starknet::ContractAddress;
use starknet::contract_address_const;
use starknet::testing;
use debug::PrintTrait;

// Setup

fn STATE() -> REFLECT::ContractState {
    REFLECT::contract_state_for_testing()
}

fn setup() -> REFLECT::ContractState {
    let mut state = STATE();
    REFLECT::constructor(ref state, NAME, SYMBOL, DECIMALS, SUPPLY);
    state
}

#[test]
#[available_gas(20000000)]
fn test_constructor() {
    let mut state = STATE();
    REFLECT::constructor(ref state, NAME, SYMBOL, DECIMALS, SUPPLY);

    // assert_only_event_transfer(ZERO(), OWNER(), SUPPLY);


    assert(ERC20Impl::balance_of(@state, OWNER()) == SUPPLY.print(), 'Should eq initial_supply');
    assert(ERC20Impl::total_supply(@state) == SUPPLY, 'Should eq initial_supply');
    assert(ERC20Impl::name(@state) == NAME, 'Name should be NAME');
    assert(ERC20Impl::symbol(@state) == SYMBOL, 'Symbol should be SYMBOL');
    assert(ERC20Impl::decimals(@state) == DECIMALS, 'Decimals should be 18');
}