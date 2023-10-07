// SPDX-License-Identifier: MIT

use starknet::ContractAddress;

#[starknet::interface]
trait IREFLECT<TState> {
    fn is_excluded(self: @TState) -> bool;
    fn total_fees(self: @TState) -> felt252;
    fn reflect(self: @TState) -> bool; //return boolean for reflect
    fn reflection_from_token(self: @TState) -> u256;
    fn token_from_reflection(self: @TState, account: ContractAddress) -> u256;
    fn exclude_account(ref self: @TState, owner: ContractAddress, spender: ContractAddress) -> bool;//return boolean for include
    fn include_account(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;//return boolean for exclude
}


