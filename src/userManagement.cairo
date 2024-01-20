use starknet:: {
    ContractAddress,
    get_caller_address,
};

//at this point User only has Address, depending on scope, this might be expanded
struct User {
    address: ContractAddress,
}

//implement storage
#[starknet::contract]
struct UserManagement {

}


impl UserManagement {
    //user registration using only using get caller address
    fn register_user() {
        let user_address = get_caller_address();

        assert!(!UserManagement::is_user_registered(user_address), "User already registered");

        let new_user = User {
            address: user_address,
        };

        ContractState::load::<UserManagement>().save_user_profile(user_address, new_user);
    }
    
    //authenticate user using caller address
    fn authenticate_user() {
        let user_address = get_caller_address();
        assert!(UserManagement::is_user_registered(user_address), "User not registered");
    }

    //get user profile using caller address if the user profile is expanded later on
    fn get_user_profile(user_address: ContractAddress) -> User {
        assert!(UserManagement::is_user_authorized(get_caller_address(), user_address), "Unauthorized");

        ContractState::load::<UserManagement>().get_user_profile(user_address)
    }

    //helper function to check if a user is registered
    fn is_user_registered(user_address: ContractAddress) -> bool {
        ContractState::load::<UserManagement>().is_user_registered(user_address)
    }

    //helper function  to check if user is authorized
    fn is_user_authorized(caller_address: ContractAddress, target_user_address: ContractAddress) -> bool {
        caller_address == target_user_address
    }

    //helper function to save user profile
    fn save_user_profile(user_address: ContractAddress, user: User) {
        ContractState::load::<UserManagement>().save_user_profile(user_address, user);
    }
}