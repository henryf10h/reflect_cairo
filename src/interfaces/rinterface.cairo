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

#[starknet::interface]
    trait IERC20<TState> {
        fn name(self: @TState) -> felt252;
        fn symbol(self: @TState) -> felt252;
        fn decimals(self: @TState) -> u8;
        fn total_supply(self: @TState) -> u256;
        fn balance_of(self: @TState, account: ContractAddress) -> u256;
        fn allowance(self: @TState, owner: ContractAddress, spender: ContractAddress) -> u256;
        fn transfer(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
        fn transfer_from(
            ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256
        ) -> bool;
        fn approve(ref self: TState, spender: ContractAddress, amount: u256) -> bool;
    }

    #[starknet::interface]
    trait IERC20Camel<TState> {
        fn name(self: @TState) -> felt252;
        fn symbol(self: @TState) -> felt252;
        fn decimals(self: @TState) -> u8;
        fn totalSupply(self: @TState) -> u256;
        fn balanceOf(self: @TState, account: ContractAddress) -> u256;
        fn allowance(self: @TState, owner: ContractAddress, spender: ContractAddress) -> u256;
        fn transfer(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
        fn transferFrom(
            ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256
        ) -> bool;
        fn approve(ref self: TState, spender: ContractAddress, amount: u256) -> bool;
    }

    #[starknet::interface]
    trait IERC20CamelOnly<TState> {
        fn totalSupply(self: @TState) -> u256;
        fn balanceOf(self: @TState, account: ContractAddress) -> u256;
        fn transferFrom(
            ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256
        ) -> bool;
    } 