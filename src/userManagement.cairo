use starknet::{ContractAddress, get_caller_address};

#[starknet::interface]
trait IUserManagementContract<TContractState> {
    fn register_user(ref self: TContractState);
    fn authenticate_user(ref self: TContractState);
    fn get_user_profile(self: @TContractState, user_address: ContractAddress) -> User;
}

#[starknet::contract]
mod UserManagementContract {
    use starknet::LegacyMap;
    use super::{IUserManagementContract, ContractAddress};

    #[derive(Clone, Copy)]
    struct User {
        address: ContractAddress,
    }

    #[storage]
    struct Storage {
        users: LegacyMap<ContractAddress, User>,
    }

    #[external(v0)]
    impl UserManagementImpl of IUserManagementContract<ContractState> {
        fn register_user(ref self: ContractState) {
            let user_address = get_caller_address();

            assert(!self.users.contains(user_address), "User already registered");

            let new_user = User {
                address: user_address,
            };

            self.users.write(user_address, new_user);
        }

        fn authenticate_user(ref self: ContractState) {
            let user_address = get_caller_address();
            assert(self.users.contains(user_address), "User not registered");
        }

        fn get_user_profile(self: @ContractState, user_address: ContractAddress) -> User {
            let caller_address = get_caller_address();
            assert(caller_address == user_address, "Unauthorized");

            self.users.read(user_address)
        }
    }
}
