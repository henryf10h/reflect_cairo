use integer::BoundedInt;
use reflect_cairo::tests::utils::constants::{
    ZERO, OWNER, SPENDER, RECIPIENT, NAME, SYMBOL, DECIMALS, SUPPLY, VALUE
};
use openzeppelin::tests::utils;
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
    REFLECT::constructor(ref state, NAME, SYMBOL, SUPPLY, OWNER());
    state
}

#[test]
#[available_gas(20000000)]
fn test_constructor() {
    let mut state = STATE();
    REFLECT::constructor(ref state, NAME, SYMBOL, SUPPLY, OWNER());

    // assert_only_event_transfer(ZERO(), OWNER(), SUPPLY);
    // let balance = ERC20Impl::balance_of(@state, OWNER());
    // let supp = SUPPLY;
    // balance.print();
    // supp.print();

    assert(ERC20Impl::balance_of(@state, OWNER()) == SUPPLY, 'Should eq initial_supply 1');
    assert(ERC20Impl::total_supply(@state) == SUPPLY, 'Should eq initial_supply 2');
    assert(ERC20Impl::name(@state) == NAME, 'Name should be NAME');
    assert(ERC20Impl::symbol(@state) == SYMBOL, 'Symbol should be SYMBOL');
    assert(ERC20Impl::decimals(@state) == DECIMALS, 'Decimals should be 18');
}
//
// Getters
//

#[test]
#[available_gas(2000000)]
fn test_total_supply() {
    let mut state = STATE();
    REFLECT::constructor(ref state, NAME, SYMBOL, SUPPLY, OWNER());
    assert(ERC20Impl::total_supply(@state) == SUPPLY, 'Should eq SUPPLY');
}

#[test]
#[available_gas(2000000)]
fn test_balance_of() {
    let mut state = STATE();
    REFLECT::constructor(ref state, NAME, SYMBOL, SUPPLY, OWNER());
    assert(ERC20Impl::balance_of(@state, OWNER()) == SUPPLY, 'Should eq SUPPLY');
}

#[test]
#[available_gas(2000000)]
fn test_allowance() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    ERC20Impl::approve(ref state, SPENDER(), VALUE);

    assert(ERC20Impl::allowance(@state, OWNER(), SPENDER()) == VALUE, 'Should eq VALUE');
}

// //
// // approve & _approve
// //

#[test]
#[available_gas(2000000)]
fn test_approve() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    assert(ERC20Impl::approve(ref state, SPENDER(), VALUE), 'Should return true');

    // assert_only_event_approval(OWNER(), SPENDER(), VALUE);
    assert(
        ERC20Impl::allowance(@state, OWNER(), SPENDER()) == VALUE, 'Spender not approved correctly'
    );
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Approve from the zero addr',))]
fn test_approve_from_zero() {
    let mut state = setup();
    // testing::set_caller_address(ZERO());
    ERC20Impl::approve(ref state, SPENDER(), VALUE);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Approve to the zero addr',))]
fn test_approve_to_zero() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    ERC20Impl::approve(ref state, Zeroable::zero(), VALUE);
}

#[test]
#[available_gas(2000000)]
fn test__approve() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    InternalImpl::_approve(ref state, OWNER(), SPENDER(), VALUE);

    // assert_only_event_approval(OWNER(), SPENDER(), VALUE);
    assert(
        ERC20Impl::allowance(@state, OWNER(), SPENDER()) == VALUE, 'Spender not approved correctly'
    );
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Approve from the zero addr',))]
fn test__approve_from_zero() {
    let mut state = setup();
    InternalImpl::_approve(ref state, Zeroable::zero(), SPENDER(), VALUE);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Approve to the zero addr',))]
fn test__approve_to_zero() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    InternalImpl::_approve(ref state, OWNER(), Zeroable::zero(), VALUE);
}

// //
// // _get_current_supply
// //

#[test]
#[available_gas(2000000)]
fn test__get_current_supply() {
    let mut state = setup();  // Assuming setup initializes your contract state
    
    let (r_supply, t_supply) = InternalImpl::_get_current_supply(@state);
    
    let expected_r_supply: u256 = 115792089237316195423570985008687907853269984665640564039457000000000000000000;  // rTotal
    
    assert(r_supply == expected_r_supply, 'rSupply mismatch');
    assert(t_supply == SUPPLY, 'tSupply mismatch');
}

// //
// // _get_rate
// //

#[test]
#[available_gas(2000000)]
fn test__get_rate() {
    let mut state = setup();  // Assuming setup initializes your contract state
    
    let rate = InternalImpl::_get_rate(@state);
    
    let expected_rate: u256 = 115792089237316195423570985008687907853269984665640564039457;  // Replace with expected value
    
    assert(rate == expected_rate, 'Rate mismatch');
}

// //
// // get_r_values & get_t_values
// //

#[test]
#[available_gas(2000000)]
fn test__get_t_values() {
    let mut state = setup();  // Assuming setup initializes your contract state

    let t_amount:u256 = 1000000;
    let fee:u256 = t_amount/100;

    let (t_transfer_amount, t_fee) = InternalImpl::_get_t_values(@state, t_amount);

    let expected_t_transfer_amount:u256 = t_amount - fee;  // Corrected this line
    let tTransferAmount:u256 = t_transfer_amount;

    assert(t_fee == fee, 'Incorrect t_fee');
    assert(tTransferAmount == expected_t_transfer_amount, 'Incorrect t_transfer_amount');
} 


#[test]
#[available_gas(2000000)]
fn test__get_r_values() {
    let mut state = setup();  // Assuming setup initializes your contract state

    let t_amount: u256 = 1000000;
    let t_fee: u256 = t_amount / 100;
    let current_rate: u256 = InternalImpl::_get_rate(@state);  // Replace with your rate

    let (r_amount, r_transfer_amount, r_fee) = InternalImpl::_get_r_values(@state, t_amount, t_fee, current_rate);

    let expected_r_amount = t_amount * current_rate;
    let expected_r_fee = t_fee * current_rate;
    let expected_r_transfer_amount = r_amount - r_fee;

    assert(r_amount == expected_r_amount, 'Incorrect r_amount');
    assert(r_fee == expected_r_fee, 'Incorrect r_fee');
    assert(r_transfer_amount == expected_r_transfer_amount, 'Incorrect r_transfer_amount');
} 

// //
// // _get_values
// //

#[test]
#[available_gas(2000000)]
fn test__get_values() {
    let mut state = setup();  // Assuming setup initializes your contract state

    let t_amount: u256 = 1000;

    let (r_amount, r_transfer_amount, r_fee, t_transfer_amount, t_fee) = InternalImpl::_get_values(@state, t_amount);

    let expected_t_fee = t_amount / 100;
    let expected_t_transfer_amount = t_amount - expected_t_fee;
    let current_rate = InternalImpl::_get_rate(@state);
    let expected_r_amount = t_amount * current_rate;
    let expected_r_fee = expected_t_fee * current_rate;
    let expected_r_transfer_amount = expected_r_amount - expected_r_fee;

    assert(t_fee == expected_t_fee, 'Incorrect t_fee calculation');
    assert(t_transfer_amount == expected_t_transfer_amount, 'Incorrect t_transfer_amount');
    assert(r_amount == expected_r_amount, 'Incorrect r_amount calculation');
    assert(r_fee == expected_r_fee, 'Incorrect r_fee calculation');
    assert(r_transfer_amount == expected_r_transfer_amount, 'Incorrect r_transfer_amount');
}

// //
// // _reflect_fee
// //

#[test]
#[available_gas(2000000)]
fn test__reflect_fee() {
    let mut state = setup();  // Assuming setup initializes your contract state

    let r_fee: u256 = 500;
    let t_fee: u256 = 500;
    let initial_tFeeTotal:u256 = REFLECT::REFLECTImpl::total_fees(@state);
    let initial_rTotal:u256 = REFLECT::REFLECTImpl::r_total(@state);

    InternalImpl::_reflect_fee(ref state, r_fee, t_fee);


    assert(REFLECT::REFLECTImpl::r_total(@state) == initial_rTotal - r_fee, 'Incorrect reflection of r_fee');
    assert(REFLECT::REFLECTImpl::total_fees(@state) == initial_tFeeTotal + t_fee, 'Incorrect reflection of t_fee');
}

// //
// // transfer & _transfer
// //

// #[test]
// #[available_gas(2000000)]
// fn test_transfer() {
//     let mut state = setup();
//     testing::set_caller_address(OWNER());
//     assert(ERC20Impl::transfer(ref state, RECIPIENT(), VALUE), 'Should return true');

//     // assert_only_event_transfer(OWNER(), RECIPIENT(), VALUE);
//     assert(ERC20Impl::balance_of(@state, RECIPIENT()) == (VALUE), 'Balance should eq VALUE');
//     assert(ERC20Impl::balance_of(@state, OWNER()) == (SUPPLY),'Should eq supply - VALUE');
//     assert(ERC20Impl::total_supply(@state) == SUPPLY, 'Total supply should not change');
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// fn test__transfer() {
//     let mut state = setup();

//     InternalImpl::_transfer(ref state, OWNER(), RECIPIENT(), VALUE);

//     assert_only_event_transfer(OWNER(), RECIPIENT(), VALUE);
//     assert(ERC20Impl::balance_of(@state, RECIPIENT()) == VALUE, 'Balance should eq amount');
//     assert(ERC20Impl::balance_of(@state, OWNER()) == SUPPLY - VALUE, 'Should eq supply - amount');
//     assert(ERC20Impl::total_supply(@state) == SUPPLY, 'Total supply should not change');
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// #[should_panic(expected: ('u256_sub Overflow',))]
// fn test__transfer_not_enough_balance() {
//     let mut state = setup();
//     testing::set_caller_address(OWNER());

//     let balance_plus_one = SUPPLY + 1;
//     InternalImpl::_transfer(ref state, OWNER(), RECIPIENT(), balance_plus_one);
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// #[should_panic(expected: ('ERC20: transfer from 0',))]
// fn test__transfer_from_zero() {
//     let mut state = setup();
//     InternalImpl::_transfer(ref state, Zeroable::zero(), RECIPIENT(), VALUE);
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// #[should_panic(expected: ('ERC20: transfer to 0',))]
// fn test__transfer_to_zero() {
//     let mut state = setup();
//     InternalImpl::_transfer(ref state, OWNER(), Zeroable::zero(), VALUE);
// }

// //
// // transfer_from
// //

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// fn test_transfer_from() {
//     let mut state = setup();
//     testing::set_caller_address(OWNER());
//     ERC20Impl::approve(ref state, SPENDER(), VALUE);
//     utils::drop_event(ZERO());

//     testing::set_caller_address(SPENDER());
//     assert(ERC20Impl::transfer_from(ref state, OWNER(), RECIPIENT(), VALUE), 'Should return true');

//     assert_event_approval(OWNER(), SPENDER(), 0);
//     assert_only_event_transfer(OWNER(), RECIPIENT(), VALUE);

//     assert(ERC20Impl::balance_of(@state, RECIPIENT()) == VALUE, 'Should eq amount');
//     assert(ERC20Impl::balance_of(@state, OWNER()) == SUPPLY - VALUE, 'Should eq supply - amount');
//     assert(ERC20Impl::allowance(@state, OWNER(), SPENDER()) == 0, 'Should eq 0');
//     assert(ERC20Impl::total_supply(@state) == SUPPLY, 'Total supply should not change');
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// fn test_transfer_from_doesnt_consume_infinite_allowance() {
//     let mut state = setup();
//     testing::set_caller_address(OWNER());
//     ERC20Impl::approve(ref state, SPENDER(), BoundedInt::max());

//     testing::set_caller_address(SPENDER());
//     ERC20Impl::transfer_from(ref state, OWNER(), RECIPIENT(), VALUE);

//     assert(
//         ERC20Impl::allowance(@state, OWNER(), SPENDER()) == BoundedInt::max(),
//         'Allowance should not change'
//     );
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// #[should_panic(expected: ('u256_sub Overflow',))]
// fn test_transfer_from_greater_than_allowance() {
//     let mut state = setup();
//     testing::set_caller_address(OWNER());
//     ERC20Impl::approve(ref state, SPENDER(), VALUE);

//     testing::set_caller_address(SPENDER());
//     let allowance_plus_one = VALUE + 1;
//     ERC20Impl::transfer_from(ref state, OWNER(), RECIPIENT(), allowance_plus_one);
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// #[should_panic(expected: ('ERC20: transfer to 0',))]
// fn test_transfer_from_to_zero_address() {
//     let mut state = setup();
//     testing::set_caller_address(OWNER());
//     ERC20Impl::approve(ref state, SPENDER(), VALUE);

//     testing::set_caller_address(SPENDER());
//     ERC20Impl::transfer_from(ref state, OWNER(), Zeroable::zero(), VALUE);
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// #[should_panic(expected: ('u256_sub Overflow',))]
// fn test_transfer_from_from_zero_address() {
//     let mut state = setup();
//     ERC20Impl::transfer_from(ref state, Zeroable::zero(), RECIPIENT(), VALUE);
// }

// //
// // increase_allowance
// //

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// fn test_increase_allowance() {
//     let mut state = setup();
//     testing::set_caller_address(OWNER());
//     ERC20Impl::approve(ref state, SPENDER(), VALUE);
//     utils::drop_event(ZERO());

//     assert(REFLECT::increase_allowance(ref state, SPENDER(), VALUE), 'Should return true');

//     assert_only_event_approval(OWNER(), SPENDER(), VALUE * 2);
//     assert(ERC20Impl::allowance(@state, OWNER(), SPENDER()) == VALUE * 2, 'Should be amount * 2');
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// #[should_panic(expected: ('ERC20: approve to 0',))]
// fn test_increase_allowance_to_zero_address() {
//     let mut state = setup();
//     testing::set_caller_address(OWNER());
//     REFLECT::increase_allowance(ref state, Zeroable::zero(), VALUE);
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// #[should_panic(expected: ('ERC20: approve from 0',))]
// fn test_increase_allowance_from_zero_address() {
//     let mut state = setup();
//     REFLECT::increase_allowance(ref state, SPENDER(), VALUE);
// }

// //
// // decrease_allowance 
// //

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// fn test_decrease_allowance() {
//     let mut state = setup();
//     testing::set_caller_address(OWNER());
//     ERC20Impl::approve(ref state, SPENDER(), VALUE);
//     utils::drop_event(ZERO());

//     assert(REFLECT::decrease_allowance(ref state, SPENDER(), VALUE), 'Should return true');

//     assert_only_event_approval(OWNER(), SPENDER(), 0);
//     assert(ERC20Impl::allowance(@state, OWNER(), SPENDER()) == VALUE - VALUE, 'Should be 0');
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// #[should_panic(expected: ('u256_sub Overflow',))]
// fn test_decrease_allowance_to_zero_address() {
//     let mut state = setup();
//     testing::set_caller_address(OWNER());
//     REFLECT::decrease_allowance(ref state, Zeroable::zero(), VALUE);
// }

// #[test]
// #[ignore]
// #[available_gas(2000000)]
// #[should_panic(expected: ('u256_sub Overflow',))]
// fn test_decrease_allowance_from_zero_address() {
//     let mut state = setup();
//     REFLECT::decrease_allowance(ref state, SPENDER(), VALUE);
// }

// //
// // Helpers
// //

// fn assert_event_approval(owner: ContractAddress, spender: ContractAddress, value: u256) {
//     let event = utils::pop_log::<Approval>(ZERO()).unwrap();
//     assert(event.owner == owner, 'Invalid `owner`');
//     assert(event.spender == spender, 'Invalid `spender`');
//     assert(event.value == value, 'Invalid `value`');

//     // Check indexed keys
//     // let mut indexed_keys = array![];
//     // indexed_keys.append_serde(owner);
//     // indexed_keys.append_serde(spender);
//     // utils::assert_indexed_keys(event, indexed_keys.span())
// }

// fn assert_only_event_approval(owner: ContractAddress, spender: ContractAddress, value: u256) {
//     assert_event_approval(owner, spender, value);
//     utils::assert_no_events_left(ZERO());
// }

// fn assert_event_transfer(from: ContractAddress, to: ContractAddress, value: u256) {
//     let event = utils::pop_log::<Transfer>(ZERO()).unwrap();
//     assert(event.from == from, 'Invalid `from`');
//     assert(event.to == to, 'Invalid `to`');
//     assert(event.value == value, 'Invalid `value`');

//     // Check indexed keys
//     // let mut indexed_keys = array![];
//     // indexed_keys.append_serde(from);
//     // indexed_keys.append_serde(to);
//     // utils::assert_indexed_keys(event, indexed_keys.span());
// }

// fn assert_only_event_transfer(from: ContractAddress, to: ContractAddress, value: u256) {
//     assert_event_transfer(from, to, value);
//     // utils::assert_no_events_left(ZERO());
// }


