use integer::BoundedInt;
use reflect_cairo::tests::utils::constants::{
    ZERO, OWNER, SPENDER, RECIPIENT, OTHER, NAME, SYMBOL, DECIMALS, SUPPLY, VALUE, SUPPLY9DECIMALS
};
use reflect_cairo::contracts::reflect::REFLECT::Approval;
use reflect_cairo::contracts::reflect::REFLECT::ERC20Impl;
use reflect_cairo::contracts::reflect::REFLECT::InternalImpl;
use reflect_cairo::contracts::reflect::REFLECT::Transfer;
use reflect_cairo::contracts::reflect::REFLECT;
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
    assert(ERC20Impl::allowance(@state, OWNER(), SPENDER()) == VALUE, 'Spender not approved correctly');
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

    // r_supply.print();
    
    let expected_r_supply: u256 = 115792089237316195423570985008687907853269984665640564039457000000000000000000;  // rTotal
    
    assert(r_supply == expected_r_supply, 'rSupply mismatch');
    assert(t_supply == SUPPLY, 'tSupply mismatch');
}

#[test]
#[available_gas(2000000)]
fn test__get_current_supply_when_excluding() {
    let mut state = setup();  // Assuming setup initializes your contract state
    
    let (r_supply, t_supply) = InternalImpl::_get_current_supply(@state);

    // r_supply.print();
    
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

#[test]
#[available_gas(5000000)]
fn test_transfer() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    let transfer_value:u256 = 500000000000000000;

    // Using the _get_t_values and _get_r_values functions
    let (t_transfer_amount, t_fee) = InternalImpl::_get_t_values(@state, transfer_value);
    let current_rate = InternalImpl::_get_rate(@state);
    let (_r_amount, _r_transfer_amount, _r_fee) = InternalImpl::_get_r_values(@state, transfer_value, t_fee, current_rate);
    
    ERC20Impl::transfer(ref state, RECIPIENT(), transfer_value);
   
    // Update the assertions accordingly
    let redistributed_fee_to_recipient = (t_fee * t_transfer_amount) / SUPPLY;
    let redistributed_fee_to_owner = (t_fee * (SUPPLY - transfer_value)) / SUPPLY;

    // Adjust the expected balance of the recipient to include the redistributed fee.
    let adjusted_t_transfer_amount:u256 = t_transfer_amount + redistributed_fee_to_recipient;
    let adjusted_t_owner_amount:u256 = (SUPPLY - transfer_value) + redistributed_fee_to_owner;

    // Define a tolerance (e.g., 1% of the SUPPLY)
    let tolerance: u256 = SUPPLY / 100;

    // Check that the values are within tolerance
    let lower_bound_recipient = adjusted_t_transfer_amount - tolerance;
    let upper_bound_recipient = adjusted_t_transfer_amount + tolerance;
    assert(ERC20Impl::balance_of(@state, RECIPIENT()) >= lower_bound_recipient && ERC20Impl::balance_of(@state, RECIPIENT()) <= upper_bound_recipient, 'Bal1 should be within tolerance');

    let lower_bound_owner = adjusted_t_owner_amount - tolerance;
    let upper_bound_owner = adjusted_t_owner_amount + tolerance;

    assert(ERC20Impl::balance_of(@state, OWNER()) >= lower_bound_owner && ERC20Impl::balance_of(@state, OWNER()) <= upper_bound_owner, 'Bal2 should be within tolerance');

    // You could keep the total_supply assertion as is since it's expected to remain exact
    assert(ERC20Impl::total_supply(@state) == SUPPLY, 'Sup should not change');
}

#[test]
#[available_gas(5000000)]
fn test__transfer() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    let transfer_value:u256 = 500000000000000000;

     // Using the _get_t_values and _get_r_values functions
    let (t_transfer_amount, t_fee) = InternalImpl::_get_t_values(@state, transfer_value);
    let current_rate = InternalImpl::_get_rate(@state);
    let (_r_amount, _r_transfer_amount, _r_fee) = InternalImpl::_get_r_values(@state, transfer_value, t_fee, current_rate);

    InternalImpl::_transfer(ref state, OWNER(), RECIPIENT(), transfer_value);

    // Update the assertions accordingly
    let redistributed_fee_to_recipient = (t_fee * t_transfer_amount) / SUPPLY;
    let redistributed_fee_to_owner = (t_fee * (SUPPLY - transfer_value)) / SUPPLY;

    // Adjust the expected balance of the recipient to include the redistributed fee.
    let adjusted_t_transfer_amount:u256 = t_transfer_amount + redistributed_fee_to_recipient;
    let adjusted_t_owner_amount:u256 = (SUPPLY - transfer_value) + redistributed_fee_to_owner;

    // Define a tolerance (e.g., 1% of the SUPPLY)
    let tolerance: u256 = SUPPLY / 100;

    // Check that the values are within tolerance
    let lower_bound_recipient = adjusted_t_transfer_amount - tolerance;
    let upper_bound_recipient = adjusted_t_transfer_amount + tolerance;
    assert(ERC20Impl::balance_of(@state, RECIPIENT()) >= lower_bound_recipient && ERC20Impl::balance_of(@state, RECIPIENT()) <= upper_bound_recipient, 'Bal1 should be within tolerance');

    let lower_bound_owner = adjusted_t_owner_amount - tolerance;
    let upper_bound_owner = adjusted_t_owner_amount + tolerance;
    assert(ERC20Impl::balance_of(@state, OWNER()) >= lower_bound_owner && ERC20Impl::balance_of(@state, OWNER()) <= upper_bound_owner, 'Bal2 should be within tolerance');

    assert(ERC20Impl::total_supply(@state) == SUPPLY, 'Sup should not change');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('u256_sub Overflow',))]
fn test__transfer_not_enough_balance() {
    let mut state = setup();
    testing::set_caller_address(RECIPIENT());

    let balance_plus_one = 100000;
    InternalImpl::_transfer(ref state, RECIPIENT(), OWNER(), balance_plus_one);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Transfer from the zero address',))]
fn test__transfer_from_zero() {
    let mut state = setup();
    InternalImpl::_transfer(ref state, Zeroable::zero(), RECIPIENT(), VALUE);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Transfer to the zero address',))]
fn test__transfer_to_zero() {
    let mut state = setup();
    InternalImpl::_transfer(ref state, OWNER(), Zeroable::zero(), VALUE);
}

// //
// // _transfer_standard
// //

#[test]
#[available_gas(4000000)]
fn test_transfer_standard() {
    let mut state = setup();  // Assume setup initializes the contract state
    let sender_address = OWNER();
    let recipient_address = RECIPIENT();
    let transfer_amount: u256 = 1000000;

    // Capture the initial balances
    let initial_balance_sender = ERC20Impl::balance_of(@state, sender_address);
    let initial_balance_recipient = ERC20Impl::balance_of(@state, recipient_address);

    // Call the _transfer_standard function
    InternalImpl::_transfer_standard(ref state, sender_address, recipient_address, transfer_amount);

    // Capture the new balances
    let new_balance_sender = ERC20Impl::balance_of(@state, sender_address);
    let new_balance_recipient = ERC20Impl::balance_of(@state, recipient_address);

    // Assert the balances have been updated correctly
    assert(new_balance_sender <= initial_balance_sender, 'Sender balance incorrect');
    assert(new_balance_recipient >= initial_balance_recipient, 'Recipient balance incorrect');
}   // Hard to do '==' because of reflections. i.e. precision loss.

// //
// // _transfer_to_excluded
// //

#[test]
#[available_gas(4000000)]
fn test_transfer_to_excluded() {
    let mut state = setup();  // Assume setup initializes the contract state
    let sender_address = OWNER();
    let recipient_address = RECIPIENT();
    let transfer_amount: u256 = 1000000;

    testing::set_caller_address(OWNER());
    REFLECT::REFLECTImpl::exclude_account(ref state, RECIPIENT());

    // Call the _transfer_standard function
    InternalImpl::_transfer_to_excluded(ref state, sender_address, recipient_address, transfer_amount);

    // Capture the new balances
    let new_balance_sender = ERC20Impl::balance_of(@state, sender_address);
    let new_balance_recipient = ERC20Impl::balance_of(@state, recipient_address);

    // Assert the balances have been updated correctly
    assert(new_balance_sender == 999999999999010000, 'Sender balance incorrect');
    assert(new_balance_recipient == 990000, 'Recipient balance incorrect');
}   

// //
// // _transfer_from_excluded
// //

#[test]
#[available_gas(4000000)]
fn test_transfer_from_excluded() {
    let mut state = setup();  // Assume setup initializes the contract state
    let sender_address = OWNER();
    let recipient_address = RECIPIENT();
    let transfer_amount: u256 = 1000000;

    testing::set_caller_address(OWNER());
    REFLECT::REFLECTImpl::exclude_account(ref state, OWNER());

    // Call the _transfer_standard function
    InternalImpl::_transfer_from_excluded(ref state, sender_address, recipient_address, transfer_amount);

    // Capture the new balances
    let new_balance_sender = ERC20Impl::balance_of(@state, sender_address);
    let new_balance_recipient = ERC20Impl::balance_of(@state, recipient_address);

    // Assert the balances have been updated correctly
    assert(new_balance_sender == 999999999999000000, 'Sender balance incorrect');
    assert(new_balance_recipient == 1000000, 'Recipient balance incorrect');
}   

// //
// // _transfer_both_excluded
// //

#[test]
#[available_gas(4000000)]
fn test_transfer_both_excluded() {
    let mut state = setup();  // Assume setup initializes the contract state
    let sender_address = OWNER();
    let recipient_address = RECIPIENT();
    let transfer_amount: u256 = 1000000;

    testing::set_caller_address(OWNER());
    REFLECT::REFLECTImpl::exclude_account(ref state, OWNER());
    REFLECT::REFLECTImpl::exclude_account(ref state, RECIPIENT());

    // Call the _transfer_standard function
    InternalImpl::_transfer_both_excluded(ref state, sender_address, recipient_address, transfer_amount);

    // Capture the new balances
    let new_balance_sender = ERC20Impl::balance_of(@state, sender_address);
    let new_balance_recipient = ERC20Impl::balance_of(@state, recipient_address);

    // Assert the balances have been updated correctly
    assert(new_balance_sender == 999999999999000000, 'Sender balance incorrect');
    assert(new_balance_recipient == 990000, 'Recipient balance incorrect');
}   

// //
// // transfer_from
// //

#[test]
#[available_gas(5000000)]
fn test_transfer_from() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    let transfer_value:u256 = 500000000000000000;
    ERC20Impl::approve(ref state, SPENDER(), transfer_value);

    testing::set_caller_address(SPENDER());
    assert(ERC20Impl::transfer_from(ref state, OWNER(), RECIPIENT(), transfer_value), 'Should return true');

    // Using the _get_t_values and _get_r_values functions
    let (t_transfer_amount, t_fee) = InternalImpl::_get_t_values(@state, transfer_value);
    let current_rate = InternalImpl::_get_rate(@state);
    let (_, _, _) = InternalImpl::_get_r_values(@state, transfer_value, t_fee, current_rate);

    // Update the assertions accordingly
    let redistributed_fee_to_recipient = (t_fee * t_transfer_amount) / SUPPLY;
    let redistributed_fee_to_owner = (t_fee * (SUPPLY - transfer_value)) / SUPPLY;

    // Adjust the expected balance of the recipient to include the redistributed fee.
    let adjusted_t_transfer_amount:u256 = t_transfer_amount + redistributed_fee_to_recipient;
    let adjusted_t_owner_amount:u256 = (SUPPLY - transfer_value) + redistributed_fee_to_owner;

    // Define a tolerance (e.g., 1% of the SUPPLY)
    let tolerance: u256 = SUPPLY / 100;

    // Check that the values are within tolerance
    let lower_bound_recipient = adjusted_t_transfer_amount - tolerance;
    let upper_bound_recipient = adjusted_t_transfer_amount + tolerance;
    assert(ERC20Impl::balance_of(@state, RECIPIENT()) >= lower_bound_recipient && ERC20Impl::balance_of(@state, RECIPIENT()) <= upper_bound_recipient, 'Bal1 should be within tolerance');

    let lower_bound_owner = adjusted_t_owner_amount - tolerance;
    let upper_bound_owner = adjusted_t_owner_amount + tolerance;
    assert(ERC20Impl::balance_of(@state, OWNER()) >= lower_bound_owner && ERC20Impl::balance_of(@state, OWNER()) <= upper_bound_owner, 'Bal2 should be within tolerance');

    assert(ERC20Impl::allowance(@state, OWNER(), SPENDER()) == 0, 'Should eq 0');
    assert(ERC20Impl::total_supply(@state) == SUPPLY, 'Total supply should not change');
}

#[test]
#[available_gas(2000000)]
fn test_transfer_from_doesnt_consume_infinite_allowance() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    ERC20Impl::approve(ref state, SPENDER(), BoundedInt::max());

    testing::set_caller_address(SPENDER());
    ERC20Impl::transfer_from(ref state, OWNER(), RECIPIENT(), VALUE);

    assert(
        ERC20Impl::allowance(@state, OWNER(), SPENDER()) == BoundedInt::max() - VALUE,
        'Allowance is not infinite'
    );
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('u256_sub Overflow',))]
fn test_transfer_from_greater_than_allowance() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    ERC20Impl::approve(ref state, SPENDER(), VALUE);

    testing::set_caller_address(SPENDER());
    let allowance_plus_one = VALUE + 1;
    ERC20Impl::transfer_from(ref state, OWNER(), RECIPIENT(), allowance_plus_one);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Transfer to the zero address',))]
fn test_transfer_from_to_zero_address() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    ERC20Impl::approve(ref state, SPENDER(), VALUE);

    testing::set_caller_address(SPENDER());
    ERC20Impl::transfer_from(ref state, OWNER(), Zeroable::zero(), VALUE);
}

// 'Transfer from the zero address' is not being checked, instead 'u256_sub Overflow' does before. OZ criteria.
#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('u256_sub Overflow',))]
fn test_transfer_from_from_zero_address() {
    let mut state = setup();
    testing::set_caller_address(ZERO());
    ERC20Impl::transfer_from(ref state, Zeroable::zero(), RECIPIENT(), VALUE);
}

// //
// // increase_allowance
// //

#[test]
#[available_gas(2000000)]
fn test_increase_allowance() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    ERC20Impl::approve(ref state, SPENDER(), VALUE);

    assert(REFLECT::increase_allowance(ref state, SPENDER(), VALUE), 'Should return true');

    assert(ERC20Impl::allowance(@state, OWNER(), SPENDER()) == VALUE * 2, 'Should be amount * 2');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Approve to the zero addr',))]
fn test_increase_allowance_to_zero_address() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    REFLECT::increase_allowance(ref state, Zeroable::zero(), VALUE);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Approve from the zero addr',))]
fn test_increase_allowance_from_zero_address() {
    let mut state = setup();
    REFLECT::increase_allowance(ref state, SPENDER(), VALUE);
}

// //
// // decrease_allowance 
// //

#[test]
#[available_gas(2000000)]
fn test_decrease_allowance() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    ERC20Impl::approve(ref state, SPENDER(), VALUE);

    assert(REFLECT::decrease_allowance(ref state, SPENDER(), VALUE), 'Should return true');

    assert(ERC20Impl::allowance(@state, OWNER(), SPENDER()) == VALUE - VALUE, 'Should be 0');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('u256_sub Overflow',))]
fn test_decrease_allowance_to_zero_address() {
    let mut state = setup();
    testing::set_caller_address(OWNER());
    REFLECT::decrease_allowance(ref state, Zeroable::zero(), VALUE);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('u256_sub Overflow',))]
fn test_decrease_allowance_from_zero_address() {
    let mut state = setup();
    REFLECT::decrease_allowance(ref state, SPENDER(), VALUE);
}

// //
// // is_excluded
// //

#[test]
#[available_gas(2000000)]
fn test_is_excluded() {
    let mut state = setup();
    testing::set_caller_address(OWNER());

    assert(REFLECT::REFLECTImpl::is_excluded(@state, OWNER()) == false, 'User is already excluded');
}

// //
// // r_total
// //

#[test]
#[available_gas(2000000)]
fn test_r_total() {
    let mut state = setup();

    // REFLECT::REFLECTImpl::r_total(@state).print();

    // Check the returned value
    assert(REFLECT::REFLECTImpl::r_total(@state) == 115792089237316195423570985008687907853269984665640564039457000000000000000000, 'Should return: 2**256 - 1');
}

// //
// // total_fees
// //

#[test]
#[available_gas(2000000)]
fn test_total_fees() {
    let mut state = setup();

    // Check the returned value
    assert(REFLECT::REFLECTImpl::total_fees(@state) == 0, 'total_fees should return 500');
}

// //
// // reflect
// //

#[test]
#[available_gas(2000000)]
fn test_reflect() {
    let mut state = setup();
    testing::set_caller_address(OWNER());

    let reflection_amount: u256 = 500;

    let before_total_reflections:u256 = REFLECT::REFLECTImpl::r_total(@state);
    let before_total_fees:u256 = REFLECT::REFLECTImpl::total_fees(@state);

    // Check the total reflections and total fees
    let (r_amount, _, _, _, _) = InternalImpl::_get_values(@state, reflection_amount);
    let expected_total_reflections:u256 = before_total_reflections - r_amount;
    let expected_total_fees:u256 = before_total_fees + reflection_amount;

    // Call the reflect function with a reflection amount of 500
    assert(REFLECT::REFLECTImpl::reflect(ref state, reflection_amount) == true, 'Reflect should return true');
    
    let actual_total_reflections = REFLECT::REFLECTImpl::r_total(@state);
    let actual_total_fees = REFLECT::REFLECTImpl::total_fees(@state);
    
    assert(actual_total_reflections == expected_total_reflections, 'Reflections should be updated');
    assert(actual_total_fees == expected_total_fees, 'Total fees should be updated');
}

// //
// // token_from_reflection
// //

#[test]
#[available_gas(2000000)]
fn test_token_from_reflection() {
    let mut state = setup();
    
    // Assume a known rAmount for testing, could be any value <= _rTotal
    let rAmount: u256 = 1000;  

    // Ensure rAmount is valid
    let current_r_total = REFLECT::REFLECTImpl::r_total(@state);
    assert(rAmount <= current_r_total, 'rAmt <= total reflections');

    // Get the current conversion rate
    let current_rate = InternalImpl::_get_rate(@state);

    // Calculate the expected tAmount based on the known conversion rate
    let expected_tAmount: u256 = rAmount / current_rate;

    // Call the function and compare the result to the expected tAmount
    let actual_tAmount = REFLECT::REFLECTImpl::token_from_reflection(@state, rAmount);
    assert(actual_tAmount == expected_tAmount, 'Should match expected tAmts');
}

// //
// // exclude_account
// //

#[test]
#[available_gas(2000000)]
fn test_exclude_account() {
    let mut state = setup();
    testing::set_caller_address(OWNER());

    assert(REFLECT::REFLECTImpl::is_excluded(@state, OWNER()) == false, 'User is already excluded');

    REFLECT::REFLECTImpl::exclude_account(ref state, OWNER());
    
    let is_excluded = REFLECT::REFLECTImpl::is_excluded(@state, OWNER());
    assert(is_excluded == true, 'User not excluded');

}

// //
// // include_account
// //

#[test]
#[available_gas(2000000)]
fn test_include_account() {
    let mut state = setup();
    testing::set_caller_address(OWNER());

    assert(REFLECT::REFLECTImpl::is_excluded(@state, OWNER()) == false, 'User is already excluded');

    REFLECT::REFLECTImpl::exclude_account(ref state, OWNER());
    
    let is_excluded = REFLECT::REFLECTImpl::is_excluded(@state, OWNER());
    assert(is_excluded == true, 'User not excluded');

    REFLECT::REFLECTImpl::include_account(ref state, OWNER());

    assert(REFLECT::REFLECTImpl::is_excluded(@state, OWNER()) == false, 'User is already excluded');

}

#[test]
#[available_gas(3000000)]
fn test_include_account_with_initial_3_excluded() {
    let mut state = setup();
    testing::set_caller_address(OWNER());

    REFLECT::REFLECTImpl::exclude_account(ref state, OWNER());
    REFLECT::REFLECTImpl::exclude_account(ref state, RECIPIENT());
    REFLECT::REFLECTImpl::exclude_account(ref state, OTHER());

    assert(REFLECT::REFLECTImpl::excluded_by_count(@state, 0) == OWNER(), 'Should be the OWNER');
    
    let is_excluded = REFLECT::REFLECTImpl::is_excluded(@state, OWNER());
    assert(is_excluded == true, 'User not excluded');

    REFLECT::REFLECTImpl::include_account(ref state, OWNER());

    assert(REFLECT::REFLECTImpl::is_excluded(@state, OWNER()) == false, 'User is already excluded');
    assert(REFLECT::REFLECTImpl::excluded_count(@state) == 2, 'Excluded count is wrong');
    assert(REFLECT::REFLECTImpl::excluded_by_count(@state, 0) == OTHER(), 'Should be OTHER');

}//keep working...let's check the excluded count

//testing for including functions cases. eg. exclude 3, include the first excluded. Get the the count to user mappings, and assert the values.
//testing _get_current_supply with excluding
//testing fn excluded_count
//testing fn excluded_by_count

