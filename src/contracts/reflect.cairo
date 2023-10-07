#[starknet::contract]
mod REFLECT {
    use integer::BoundedInt;
    use openzeppelin::token::erc20::interface::IERC20;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use zeroable::Zeroable;
    use reflect_cairo::interfaces::rinterface::IREFLECT;

    #[storage]
    struct Storage {
        _rOwned: LegacyMap<ContractAddress, u256>,
        _tOwned: LegacyMap<ContractAddress, u256>,
        _allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
        // _isExcluded: LegacyMap<ContractAddress, bool>,
        // _excluded: LegacyArray<ContractAddress>,
        _rTotal: u256,
        _tTotal: u256,
        _tFeeTotal: u256,
        _name: felt252,
        _symbol: felt252,
        _decimals: u8
    }

    // ... Events and other necessary structs ...

    #[constructor]
    fn constructor(ref self: ContractState) {
        self._name.write('Reflect.primitives');
        self._symbol.write('RPI');
        self._decimals.write(9);
        let MAX: u256 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        self._tTotal.write(10000000000000000);
        self._rTotal.write(MAX - (MAX % self._tTotal.read()));
        let creator = get_caller_address();
        self._rOwned.write(creator, self._rTotal.read());
        self.emit(Transfer { from: Zeroable::zero(), to: creator, value: self._rTotal.read() });
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    /// Emitted when tokens are moved from address `from` to address `to`.
    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        value: u256
    }

    /// Emitted when the allowance of a `spender` for an `owner` is set by a call
    /// to [approve](approve). `value` is the new allowance.
    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key]
        owner: ContractAddress,
        #[key]
        spender: ContractAddress,
        value: u256
    }

    //
    // External
    //

    #[external(v0)]
    impl ERC20Impl of IERC20<ContractState> {
        /// Returns the name of the token.
        fn name(self: @ContractState) -> felt252 {
            self._name.read()
        }

        /// Returns the ticker symbol of the token, usually a shorter version of the name.
        fn symbol(self: @ContractState) -> felt252 {
            self._symbol.read()
        }

        /// Returns the number of decimals used to get its user representation.
        fn decimals(self: @ContractState) -> u8 {
            self._decimals.read()
        }

        /// Returns the value of tokens in existence.
        fn total_supply(self: @ContractState) -> u256 {
            self._tTotal.read()
        }

        /// Returns the amount of tokens owned by `account`.
        /// Todo: we need to define tokenFromReflection.
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            67
        }

        /// Returns the remaining number of tokens that `spender` is
        /// allowed to spend on behalf of `owner` through [transfer_from](transfer_from).
        /// This is zero by default.
        /// This value changes when [approve](approve) or [transfer_from](transfer_from)
        /// are called.
        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            self._allowances.read((owner, spender))
        }

        /// Moves `amount` tokens from the caller's token balance to `to`.
        /// Emits a [Transfer](Transfer) event.
        /// todo: define internal _transfer.
        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            // let sender = get_caller_address();
            // self._transfer(sender, recipient, amount);
            true
        }

        /// Moves `amount` tokens from `from` to `to` using the allowance mechanism.
        /// `amount` is then deducted from the caller's allowance.
        /// Emits a [Transfer](Transfer) event.
        /// todo: define internal _spend_allowance.
        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            // let caller = get_caller_address();
            // self._spend_allowance(sender, caller, amount);
            // self._transfer(sender, recipient, amount);
            true
        }

        /// Sets `amount` as the allowance of `spender` over the caller’s tokens.
        /// todo: define internal _approve.
        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            // let caller = get_caller_address();
            // self._approve(caller, spender, amount);
            true
        }
    }

    /// Increases the allowance granted from the caller to `spender` by `added_value`.
    /// Emits an [Approval](Approval) event indicating the updated allowance.
    /// Todo: we need to define _approve.
    // #[external(v0)]
    // fn increase_allowance(
    //     ref self: ContractState, spender: ContractAddress, added_value: u256
    // ) -> bool {
    //     self._allowance.write((spender, added_value), )
    // }

    /// Decreases the allowance granted from the caller to `spender` by `subtracted_value`.
    /// Emits an [Approval](Approval) event indicating the updated allowance.
    /// todo: same as above.
    // #[external(v0)]
    // fn decrease_allowance(
    //     ref self: ContractState, spender: ContractAddress, subtracted_value: u256
    // ) -> bool {
    //     self._allowance(spender, subtracted_value)
    // }

    // ... Reflection logic ...

    #[external(v0)]
    impl REFLECTImpl of IREFLECT<ContractState> {
        fn is_excluded(self: @ContractState) -> bool{
            true
        }
        fn total_fees(self: @ContractState) -> felt252{
            123
        }
        fn reflect(ref self: ContractState) -> bool{
            true
        } //return boolean for reflect
        fn reflection_from_token(self: @ContractState) -> u256{
            123
        }
        fn token_from_reflection(self: @ContractState, account: ContractAddress) -> u256{
            1
        }
        fn exclude_account(ref self: ContractState, owner: ContractAddress, spender: ContractAddress) -> bool{
            true
        }//return boolean for include
        fn include_account(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool{
            true
        }//return boolean for exclude
    }

    // ... Utility functions ...
}
