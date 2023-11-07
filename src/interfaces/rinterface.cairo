// SPDX-License-Identifier: MIT

use starknet::ContractAddress;

#[starknet::interface]
trait IREFLECT<TState> {
    // fn is_excluded(self: @TState, account: ContractAddress) -> bool;
    fn r_total(self: @TState) -> u256;
    fn total_fees(self: @TState) -> u256;
    fn reflect(ref self: TState, tAmount: u256) -> bool; //return boolean for reflect
    // fn reflection_from_token(self: @TState, tAmount: u256, deductTransferFee: bool) -> u256;
    fn token_from_reflection(self: @TState, rAmount: u256) -> u256;
    // fn exclude_account(ref self: TState, user: ContractAddress) -> bool;//return boolean for include
    // fn include_account(ref self: TState, user: ContractAddress) -> bool;//return boolean for exclude
}

