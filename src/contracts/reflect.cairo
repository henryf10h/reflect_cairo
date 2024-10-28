// SPDX-License-Identifier: MIT

// Welcome to Reflecter.Finance - Innovating the DeFi Space!
// We are a project dedicated to bringing cutting-edge solutions and novel approaches to decentralized finance.

/// Fee rate in pips (e.g., 1000 = 10%, 100 = 1%).

#[starknet::contract]
mod REFLECT {
    use integer::BoundedInt;
    use reflect_cairo::interfaces::rinterface::IERC20;
    use reflect_cairo::interfaces::rinterface::IERC20CamelOnly;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use zeroable::Zeroable;
    use reflect_cairo::interfaces::rinterface::IREFLECT;
    use reflect_cairo::contracts::ownable::OwnableComponent as ownable_component;

    component!(path: ownable_component, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = ownable_component::OwnableImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableCamelOnlyImpl = ownable_component::OwnableCamelOnlyImpl<ContractState>;
    impl OwnableInternalImpl = ownable_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        _r_owned: LegacyMap<ContractAddress, u256>,
        _t_owned: LegacyMap<ContractAddress, u256>,
        _allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
        _is_excluded: LegacyMap<ContractAddress, bool>,
        _excluded_index: u256,
        _excluded_users: LegacyMap<u256, ContractAddress>,
        _r_total: u256,
        _t_total: u256,
        _t_fee_total: u256,
        _name: felt252,
        _symbol: felt252,
        _decimals: u8,
        _fee: u256,
        #[substorage(v0)]
        ownable: ownable_component::Storage
    }

    // Events and other necessary structs 

    #[constructor]
    fn constructor(ref self: ContractState, _name: felt252, _symbol: felt252, _supply: u256, _fee: u256, _creator: ContractAddress) {
        self._name.write(_name);
        self._symbol.write(_symbol);
        self._decimals.write(9);
        self._fee.write(_fee);
        self.ownable.initializer(_creator);
        let MAX: u256 = BoundedInt::max(); 
        self._t_total.write(_supply);
        self._r_total.write(MAX - (MAX % self._t_total.read()));
        self._r_owned.write(_creator, self._r_total.read());
        self.emit(Transfer { from: Zeroable::zero(), to: _creator, value: self._t_total.read() });
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        OwnableEvent: ownable_component::Event
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

    #[abi(embed_v0)]
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
            self._t_total.read()
        }

        /// Returns the amount of tokens owned by `account`.
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            if self._is_excluded.read(account) {
                return self._t_owned.read(account);
            }
            return self.token_from_reflection(self._r_owned.read(account));
        }

        /// Returns the remaining number of tokens that `spender` is
        /// allowed to spend on behalf of `owner` through [transfer_from]
        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            self._allowances.read((owner, spender))
        }

        /// Moves `amount` tokens from the caller's token balance to `to`.
        /// Emits a [Transfer] event.
        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let sender = get_caller_address();
            self._transfer(sender, recipient, amount);
            true
        }

        /// Moves `amount` tokens from `from` to `to` using the allowance mechanism.
        /// `amount` is then deducted from the caller's allowance.
        /// Emits a [Transfer] event.
        fn transfer_from(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            self._approve(sender, caller, self._allowances.read((sender, caller)) - amount);
            self._transfer(sender, recipient, amount);
            true
        }

        /// Sets `amount` as the allowance of `spender` over the caller’s tokens.
        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            self._approve(caller, spender, amount);
            true
        }
    }

    /// Increases the allowance granted from the caller to `spender` by `added_value`.
    /// Emits an [Approval] event indicating the updated allowance.
    #[abi(embed_v0)]
        fn increase_allowance(ref self: ContractState, spender: ContractAddress, added_value: u256) -> bool {
            let sender = get_caller_address();
            self._approve(sender, spender, self._allowances.read((sender, spender)) + added_value);
            true
        }

    /// Decreases the allowance granted from the caller to `spender` by `subtracted_value`.
    /// Emits an [Approval] event indicating the updated allowance.
    #[abi(embed_v0)]
        fn decrease_allowance(ref self: ContractState, spender: ContractAddress, subtracted_value: u256) -> bool {
            let sender = get_caller_address();
            self._approve(sender, spender, self._allowances.read((sender, spender)) - subtracted_value);
            true
        }

    #[abi(embed_v0)]
    impl ERC20CamelOnlyImpl of IERC20CamelOnly<ContractState> {

        fn totalSupply(self: @ContractState) -> u256 {
            ERC20Impl::total_supply(self)
        }

        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            ERC20Impl::balance_of(self, account)
        }

        fn transferFrom(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool {
            ERC20Impl::transfer_from(ref self, sender, recipient, amount)
        }
    }

    #[abi(embed_v0)]
        fn increaseAllowance(ref self: ContractState, spender: ContractAddress, addedValue: u256) -> bool {
            increase_allowance(ref self, spender, addedValue)
        }

    #[abi(embed_v0)]
        fn decreaseAllowance(ref self: ContractState, spender: ContractAddress, subtractedValue: u256) -> bool {
            decrease_allowance(ref self, spender, subtractedValue)
        }

    // Reflection Logic

    #[abi(embed_v0)]
    impl REFLECTImpl of IREFLECT<ContractState> {
        fn is_excluded(self: @ContractState, account: ContractAddress) -> bool{
            self._is_excluded.read(account)
        }

        fn r_total(self: @ContractState) -> u256 {
            self._r_total.read()
        }

        fn total_fees(self: @ContractState) -> u256 {
            self._t_fee_total.read()
        }

        fn reflect(ref self: ContractState, tAmount: u256) -> bool {
            let sender = get_caller_address();
            if self._is_excluded.read(sender) {
                return false;  // Excluded addresses cannot call this function
            }
            let (rAmount, _, _, _, _) = self._get_values(tAmount);
            self._r_owned.write(sender, self._r_owned.read(sender) - rAmount);
            self._r_total.write(self._r_total.read() - rAmount);
            self._t_fee_total.write(self._t_fee_total.read() + tAmount);
            return true;
        }

        fn reflection_from_token(self: @ContractState, tAmount: u256, deductTransferFee: bool) -> u256 {
            assert (tAmount <= self._t_total.read(), 'Amount must be less than supply');
            if !deductTransferFee {
                let (rAmount, _, _, _, _) = self._get_values(tAmount);
                return rAmount;
            } else {
                let (_, rTransferAmount, _, _, _) = self._get_values(tAmount);
                return rTransferAmount;
            }
        }

        fn token_from_reflection(self: @ContractState, rAmount: u256) -> u256 {
            assert(rAmount <= self._r_total.read(), 'Less than total reflections');
            let currentRate = self._get_rate();
            return rAmount / currentRate;
        }

        fn exclude_account(ref self: ContractState, user: ContractAddress) -> bool {
            self.ownable.assert_only_owner();
            if self._is_excluded.read(user) == false {
                if self._r_owned.read(user) > 0 {
                    self._t_owned.write(user, self.token_from_reflection(self._r_owned.read(user)));
                }
                self._is_excluded.write(user, true);
                let index = self._excluded_index.read();
                self._excluded_users.write(index, user);
                self._excluded_index.write(index + 1);
                return true;
            }
            return false;
        }

        fn include_account(ref self: ContractState, user: ContractAddress) -> bool {
            self.ownable.assert_only_owner();
            if self._is_excluded.read(user) == true {
                self._t_owned.write(user, 0); // Reset the _t_owned balance for the user
                self._is_excluded.write(user, false);
                let count = self._excluded_index.read(); 
                self._include_account(user, count, 0);
                return true;
            }
            return false;
        }

    }

    // Internal functions 

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _approve(ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256) {
            assert(!owner.is_zero(), 'Approve from the zero addr');
            assert(!spender.is_zero(), 'Approve to the zero addr');

            self._allowances.write((owner, spender), amount);

            // Emit the Approval event
            self.emit(Approval { owner: owner, spender: spender, value: amount });
        }

        fn _transfer(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256) {
            assert(!sender.is_zero(), 'Transfer from the zero address');
            assert(!recipient.is_zero(), 'Transfer to the zero address');
            assert(amount > 0, 'Must be greater than zero');

            let sender_is_excluded = self._is_excluded.read(sender);
            let recipient_is_excluded = self._is_excluded.read(recipient);

            if sender_is_excluded && !recipient_is_excluded {
                self._transfer_from_excluded(sender, recipient, amount);
            } else if !sender_is_excluded && recipient_is_excluded {
                self._transfer_to_excluded(sender, recipient, amount);
            } else if !sender_is_excluded && !recipient_is_excluded {
                self._transfer_standard(sender, recipient, amount);
            } else if sender_is_excluded && recipient_is_excluded {
                self._transfer_both_excluded(sender, recipient, amount);
            } else {
                self._transfer_standard(sender, recipient, amount);
            }
        }

        fn _transfer_standard(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, tAmount: u256) {
            let (rAmount, rTransferAmount, rFee, tTransferAmount, tFee) = self._get_values(tAmount);
            self._r_owned.write(sender, self._r_owned.read(sender) - rAmount);
            self._r_owned.write(recipient, self._r_owned.read(recipient) + rTransferAmount);
            self._reflect_fee(rFee, tFee);
            self.emit(Transfer { from: sender, to: recipient, value: tTransferAmount });
        }

        fn _transfer_to_excluded(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, tAmount: u256) {
            let (rAmount, rTransferAmount, rFee, tTransferAmount, tFee) = self._get_values(tAmount);
            self._r_owned.write(sender, self._r_owned.read(sender) - rAmount);
            self._t_owned.write(recipient, self._t_owned.read(recipient) + tTransferAmount);
            self._r_owned.write(recipient, self._r_owned.read(recipient) + rTransferAmount);
            self._reflect_fee(rFee, tFee);
            self.emit(Transfer { from: sender, to: recipient, value: tTransferAmount });
        }

        fn _transfer_from_excluded(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, tAmount: u256) {
            let (rAmount, rTransferAmount, rFee, tTransferAmount, tFee) = self._get_values(tAmount);
            self._t_owned.write(sender, self._t_owned.read(sender) - tAmount);
            self._r_owned.write(sender, self._r_owned.read(sender) - rAmount);
            self._r_owned.write(recipient, self._r_owned.read(recipient) + rTransferAmount);
            self._reflect_fee(rFee, tFee);
            self.emit(Transfer { from: sender, to: recipient, value: tTransferAmount });
        }

        fn _transfer_both_excluded(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, tAmount: u256) {
            let (rAmount, rTransferAmount, rFee, tTransferAmount, tFee) = self._get_values(tAmount);
            self._t_owned.write(sender, self._t_owned.read(sender) - tAmount);
            self._r_owned.write(sender, self._r_owned.read(sender) - rAmount);
            self._t_owned.write(recipient, self._t_owned.read(recipient) + tTransferAmount);
            self._r_owned.write(recipient, self._r_owned.read(recipient) + rTransferAmount);
            self._reflect_fee(rFee, tFee);
            self.emit(Transfer { from: sender, to: recipient, value: tTransferAmount });
        }

        fn _reflect_fee(ref self: ContractState, r_fee: u256, t_fee: u256) {
            self._r_total.write(self._r_total.read() - r_fee);
            self._t_fee_total.write(self._t_fee_total.read() + t_fee);
        }

        fn _get_values(self: @ContractState, t_amount: u256) -> (u256, u256, u256, u256, u256) {
            let (t_transfer_amount, t_fee) = self._get_t_values(t_amount);
            let current_rate = self._get_rate();
            let (r_amount, r_transfer_amount, r_fee) = self._get_r_values(t_amount, t_fee, current_rate);
            return (r_amount, r_transfer_amount, r_fee, t_transfer_amount, t_fee);
        }

        fn _get_t_values(self: @ContractState, t_amount: u256) -> (u256, u256) {
            let t_fee = (t_amount * self._fee.read()) / 10000;  // Division by 10000 for pip conversion
            let t_transfer_amount = t_amount - t_fee;
            return (t_transfer_amount, t_fee);
        }

        fn _get_r_values(self: @ContractState, t_amount: u256, t_fee: u256, current_rate: u256) -> (u256, u256, u256) {
            let r_amount = t_amount * current_rate;
            let r_fee = t_fee * current_rate;
            let r_transfer_amount = r_amount - r_fee;
            return (r_amount, r_transfer_amount, r_fee);
        }

        fn _get_rate(self: @ContractState) -> u256 {
            let (rSupply, tSupply) = self._get_current_supply();
            return rSupply / tSupply;
        }

        fn _get_current_supply(self: @ContractState) -> (u256, u256) {
            let r_supply = self._r_total.read();
            let t_supply = self._t_total.read();
            let excluded_count = self._excluded_index.read();

            self._supply(r_supply, t_supply, excluded_count, 0)
        }

        fn _supply(self: @ContractState, r_supply: u256, t_supply: u256, excluded_count: u256, i: u256,) -> (u256, u256) {
            if i >= excluded_count {
                if r_supply < (self._r_total.read() / self._t_total.read()) {
                    return (self._r_total.read(), self._t_total.read());
                }
                return (r_supply, t_supply);
            }

            let excluded_address = self._excluded_users.read(i);
            let r_owned_value = self._r_owned.read(excluded_address);
            let t_owned_value = self._t_owned.read(excluded_address);

            if r_owned_value > r_supply || t_owned_value > t_supply {
                return (self._r_total.read(), self._t_total.read());
            }

            self._supply(r_supply - r_owned_value, t_supply - t_owned_value, excluded_count, i + 1)
        }

        fn _include_account(ref self: ContractState, user: ContractAddress, count: u256, i: u256) {
            if i >= count {
                return;
            }

            if self._excluded_users.read(i) == user {
                if i != count - 1 {
                    let last_user = self._excluded_users.read(count - 1);
                    self._excluded_users.write(i, last_user); // Move the last user to the current position
                }
                self._excluded_users.write(count - 1, Zeroable::zero()); // Set the last address to the zero address
                self._excluded_index.write(count - 1); // Decrement the count
                return;
            }

            self._include_account(user, count, i + 1);
        }

    }

}
