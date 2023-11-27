use starknet::{ContractAddress, ClassHash, syscalls, SyscallResult};

#[starknet::interface]
trait IReflectFactory<TContractState> {
    // Function to deploy a new reflective token contract
    fn create_token(ref self: TContractState, name: felt252, symbol: felt252, supply: u256, creator: ContractAddress) -> SyscallResult<ContractAddress>;
    fn update_token_class_hash(ref self: TContractState, token_class_hash: ClassHash);
}

#[starknet::contract]
mod ReflectFactory {
    use core::traits::Into;
    use super::IReflectFactory;
    use starknet::{ContractAddress, ClassHash, syscalls, SyscallResult};
    use openzeppelin::access::ownable::Ownable as ownable_component;
    use serde::Serde;
    use poseidon::poseidon_hash_span;

    component!(path: ownable_component, storage: ownable, event: OwnableEvent);

    // Implement the Ownable interfaces
    #[abi(embed_v0)]
    impl OwnableImpl = ownable_component::OwnableImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableCamelOnlyImpl =
        ownable_component::OwnableCamelOnlyImpl<ContractState>;
    impl InternalImpl = ownable_component::InternalImpl<ContractState>;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnableEvent: ownable_component::Event
    }

    #[storage]
    struct Storage {
        // Class hash of the reflective token contract
        token_class_hash: ClassHash,
        #[substorage(v0)]
        ownable: ownable_component::Storage
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, token_class_hash: ClassHash) {
        // Set the initial owner of the contract
        self.ownable.initializer(owner);
        // Store the class hash of the token contract
        self.token_class_hash.write(token_class_hash);
    }

    #[external(v0)]
    impl TokenFactory of IReflectFactory<ContractState> {
        fn create_token(
            ref self: ContractState,
            name: felt252,
            symbol: felt252,
            supply: u256,
            creator: ContractAddress
        ) -> SyscallResult<ContractAddress> {
            // Serialize the constructor arguments into calldata
            let mut initialize_calldata: Array<felt252> = array![
                name, symbol
            ];

            supply.serialize(ref initialize_calldata);
            initialize_calldata.append(creator.into());

            // Generate a unique salt for deployment
            let salt = self.generate_unique_salt(name, symbol, supply, creator);  // Implement this function based on your requirements

            // Deploy the token contract
            let (contract_address, _) = syscalls::deploy_syscall(
                self.token_class_hash.read(), salt, initialize_calldata.span(), false
            )?;

            // Return the address of the newly deployed contract
            SyscallResult::Ok(contract_address)
        }

            // Function to update the class hash of the token contract
        fn update_token_class_hash(ref self: ContractState, token_class_hash: ClassHash) {
            // Ensure that only the owner can call this function
            self.ownable.assert_only_owner();
            // Update the class hash in the storage
            self.token_class_hash.write(token_class_hash);
        }
    }


    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait{

        fn generate_unique_salt(self: @ContractState,
            name: felt252,
            symbol: felt252,
            supply: u256,
            creator: ContractAddress
        )-> felt252 {
            // Get the current block timestamp for a dynamic component.
            let timestamp = starknet::get_block_timestamp();

            // Prepare an array to combine all elements for hashing.
            // Note: You might need to adjust the serialization based on the data types.
            let mut data_for_salt: Array<felt252> = array![
                name, symbol
            ];
            supply.serialize(ref data_for_salt);
            data_for_salt.append(creator.into());
            data_for_salt.append(timestamp.into());

            // Use a hash function like Poseidon to generate the salt from the combined data.
            let salt = poseidon::poseidon_hash_span(data_for_salt.span());

            salt
        }

    }
}
