#[starknet::contract]
mod ERC20WRAPPERV0 {
    use integer::BoundedInt;
    use openzeppelin::token::erc20::interface::IERC20;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use zeroable::Zeroable;
    use reflect_cairo::interfaces::winterface::IERC20WRAPPER;
    use openzeppelin::security::reentrancyguard::ReentrancyGuard;

    // Declare the ReentrancyGuard component
    component!(path: ReentrancyGuard, storage: Storage);

    #[storage]
    struct Storage {
        _rTokenBalance: LegacyMap<ContractAddress, u256>,
        _tTokenBalance: LegacyMap<ContractAddress, u256>,
        _allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
        _rTokenSupply: u256,
        _tTokenSupply: u256,
        _tFeeTotal: u256,
        _name: felt252,
        _symbol: felt252,
        _decimals: u8,
        _tContract: ContractAddress,
        #[substorage(v0)]
        reentrancy: ReentrancyGuard::Stogare
    }

    // ... Events and other necessary structs ...

    #[constructor]
    fn constructor(
        ref self: ContractState,
        _name: felt252,
        _symbol: felt252,
        _supply: u256,
        _creator: ContractAddress,
        _tContract: ContractAddress
    ) {
        self._name.write(_name);
        self._symbol.write(_symbol);
        self._decimals.write(9);
        self._tContract.write(_tContract);
        self.emit(Transfer { from: Zeroable::zero(), to: _creator, value: 0 });
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
            self._tTokenSupply.read()
        }

        /// Returns the amount of tokens owned by `account`.
        /// Todo: we need to define tokenFromReflection.
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            let (r ,t) = _get_current_supply();
            return (self._rTokenBalance.read(account) * t) / r;
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
            let sender = get_caller_address();
            self._transfer(sender, recipient, amount);
            true
        }

        /// Moves `amount` tokens from `from` to `to` using the allowance mechanism.
        /// `amount` is then deducted from the caller's allowance.
        /// Emits a [Transfer](Transfer) event.
        /// todo: define internal _spend_allowance. WRONG! it is not needed. 
        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            let caller = get_caller_address();
            self._transfer(sender, recipient, amount);
            self._approve(sender, caller, self._allowances.read((sender, caller)) - amount);
            true
        }

        /// Sets `amount` as the allowance of `spender` over the caller’s tokens.
        /// todo: define internal _approve.
        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            self._approve(caller, spender, amount);
            true
        }
    }

    /// Increases the allowance granted from the caller to `spender` by `added_value`.
    /// Emits an [Approval](Approval) event indicating the updated allowance.
    #[external(v0)]
    fn increase_allowance(
        ref self: ContractState, spender: ContractAddress, added_value: u256
    ) -> bool {
        let sender = get_caller_address();
        self._approve(sender, spender, self._allowances.read((sender, spender)) + added_value);
        true
    }

    /// Decreases the allowance granted from the caller to `spender` by `subtracted_value`.
    /// Emits an [Approval](Approval) event indicating the updated allowance.
    #[external(v0)]
    fn decrease_allowance(
        ref self: ContractState, spender: ContractAddress, subtracted_value: u256
    ) -> bool {
        let sender = get_caller_address();
        self._approve(sender, spender, self._allowances.read((sender, spender)) - subtracted_value);
        true
    }

    // ... Reflection logic ...

    #[external(v0)]
    impl ERC20WRAPPERImpl of IERC20WRAPPER<ContractState> {

        fn r_token_supply(self: @ContractState) -> u256 {
            self._rTokenSupply.read()
        }

        fn total_fees(self: @ContractState) -> u256 {
            self._tFeeTotal.read()
        }

        // Function to deposit tokens into the contract
        fn deposit(ref self: ContractState, amount: u256) -> bool {
            let caller = get_caller_address();
            // Assuming _pull_underlying or a similar function is implemented to transfer tokens
            // self._pull_underlying(self._tContract.read(), caller, amount);
            
            let (rAmount, tAmount) = self._get_values(amount);
            self._tTokenSupply.write(self._tTokenSupply.read() + tAmount);
            self._rTokenBalance.write(caller, self._rTokenBalance.read(caller) + rAmount);
            
            self.emit(Transfer { from: caller, to: ContractAddress::from_address(self.address()), value: amount });
            true
        }

        // Function to withdraw tokens from the contract
        fn withdraw(ref self: ContractState, amount: u256) -> bool {
            let caller = get_caller_address();
            assert(self.balance_of(caller) >= amount, 'Insufficient balance');

            let (rAmount, tAmount) = self._get_values(amount);
            self._tTokenSupply.write(self._tTokenSupply.read() - tAmount);
            self._rTokenBalance.write(caller, self._rTokenBalance.read(caller) - rAmount);

            // Assuming _push_underlying or a similar function is implemented to transfer tokens
            // self._push_underlying(self._tContract.read(), caller, amount);
            
            self.emit(Transfer { from: ContractAddress::from_address(self.address()), to: caller, value: amount });
            true
        }

        // Function to distribute rTokens to everyone (reflect fee)
        fn rTokenToEveryone(ref self: ContractState, tAmount: u256) -> bool {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is the zero address');

            let (rAmount, _, _, _, _) = self._get_values(tAmount);
            self._rTokenSupply.write(self._rTokenSupply.read() - rAmount);
            self._tFeeTotal.write(self._tFeeTotal.read() + tAmount);

            true
        }

        // Function to convert rTokens to tTokens
        fn tTokenFromrToken(self: @ContractState, rAmount: u256) -> u256 {
            assert(rAmount <= self._rTokenSupply.read(), 'Amount exceeds total rTokens');
            let currentRate = self._get_rate();
            rAmount * currentRate
        }

    }

    // ... Internal functions ...

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _approve(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            // Check for zero addresses
            assert(!owner.is_zero(), 'Approve from the zero addr');
            assert(!spender.is_zero(), 'Approve to the zero addr');

            // Update the allowance
            self._allowances.write((owner, spender), amount);

            // Emit the Approval event
            self.emit(Approval { owner: owner, spender: spender, value: amount });
        }


        fn _transfer(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) {
            // Check for zero addresses and amount > 0
            assert(!sender.is_zero(), 'Transfer from the zero address');
            assert(!recipient.is_zero(), 'Transfer to the zero address');
            assert(amount > 0, 'Must be greater than zero');
            self._transfer_standard(sender, recipient, amount);
        }

        fn _transfer_standard(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            tAmount: u256
        ) {
            let (rAmount, rTransferAmount, rFee, tTransferAmount, tFee) = self._get_values(tAmount);
            self._rTokenBalance.write(sender, self._rTokenBalance.read(sender) - rAmount);
            self._rTokenBalance.write(recipient, self._rTokenBalance.read(recipient) + rTransferAmount);
            self._reflect_fee(rFee, tFee);
            self.emit(Transfer { from: sender, to: recipient, value: tTransferAmount });
        }

        fn _reflect_fee(ref self: ContractState, r_fee: u256, t_fee: u256) {
            self._rTokenSupply.write(self._rTokenSupply.read() - r_fee);
            self._tFeeTotal.write(self._tFeeTotal.read() + t_fee);
        }

        fn _get_values(self: @ContractState, t_amount: u256) -> (u256, u256, u256, u256, u256) {
            let (t_transfer_amount, t_fee) = self._get_t_values(t_amount);
            let current_rate = self._get_rate();
            let (r_amount, r_transfer_amount, r_fee) = self._get_r_values(t_amount, t_fee, current_rate);
            return (r_amount, r_transfer_amount, r_fee, t_transfer_amount, t_fee);
        }

        fn _get_t_values(self: @ContractState, t_amount: u256) -> (u256, u256) {
            let t_fee = t_amount / 100;
            let t_transfer_amount = t_amount - t_fee;
            return (t_transfer_amount, t_fee);
        }

        fn _get_r_values(
            self: @ContractState, t_amount: u256, t_fee: u256, current_rate: u256
        ) -> (u256, u256, u256) {
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
            let mut rSupply = self._rTokenSupply.read();
            let mut tSupply = self._tTokenSupply.read();
            return (rSupply, tSupply);
        }
    }

}
