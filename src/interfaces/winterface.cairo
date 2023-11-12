// SPDX-License-Identifier: MIT

use starknet::ContractAddress;

#[starknet::interface]
trait IERC20WRAPPER<TState> {

    fn r_token_supply(self: @TState) -> u256;
    fn total_fees(self: @TState) -> u256;
    fn deposit(ref self: TState, amount: u256) -> bool;
    fn withdraw(ref self: TState, amount: u256) -> bool;
    fn rTokenToEveryone(ref self: TState, tAmount: u256) -> bool;
    fn tTokenFromrToken(self: @TState, rAmount: u256) -> u256;
    
}
