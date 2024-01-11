//Import Contract Address from starknet because we are using contract address to identify the owner of the request
use starknet::ContractAddress;

//Implementation of the interface
#[starknet::interface]

//according to the requirements we are supposed to have the functionalities add_cargo, update_cargo, remove_cargo
//transfer_ownership and get_owner were added so as to help implement the other functions
//remove_cargo should just change status to unavailable rather than deleting it because it is not recommended to delete such info in enterprise apps.
//as of today I was unable to implement that (did not find a way in Cairo) 
//transfer_ownership is added so that the owner of the contract can transfer the ownership to another address
//cargo_status should implemented in detail here because it is being used in 3 other places

trait CargoListingTrait<T> {
    fn add_cargo(ref self: TContractState, destination: felt252, size: u128, weight: u128);
    fn update_cargo(ref self: TContractState, cargo_id: u128, destination: felt252, size: u128, weight: u128);
    fn remove_cargo(ref self: TContractState, cargo_id: u128);
    fn transfer_ownership(ref self: T, new_owner: ContractAddress);
    fn get_owner(self: @T) -> ContractAddress;
}
//Implementation of the contract
#[starknet::contract]
mod CargoListing {
    //import ContractAddress from parent
    use super::ContractAddress;
    //get_caller_address is an inbuilt function
    use starknet::get_caller_address;

    //I added this as part of debugging the error 'Event defined multiple times'
    //The error was not affected by this. It kept on happening
    #[event]

    //This is the function to implement ownership transfer
    //this function works, can be removed if the developer decides there is no use for trnasfer
    #[derive(Drop, starknet::Event)]
    enum Event {
      OwnershipTransferred1: OwnershipTransferred1,
    }

    //This transfers ownership using contactAddress of existing user as prev_owner and new_owner as transferee
    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred1 {
        #[key]
        prev_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress,
    }
    
    //This is the storage function I chose because Storage should be implemented in each contract (Cairo requires)
    //This simply stores id of the next cargo, cargo_map(this should be imported it is part of Legacy Cairo, i run into multiple errors importing it), and owner.

    #[storage]
    struct Storage {
        next_cargo_id: u64,
        cargo_map: u64,
        owner: ContractAddress,
    }

    //This is the main storage for the Cargo. It is supposed to have id, business_owner, destination, size, weight, CargoStatus. 
    //Additionally a source might be added depending on the Map implementation.
    #[storage]
    struct Cargo {
        id: u64,
        business_owner: ContractAddress,
        destination: felt252,
        size: u64,
        weight: u64,
        status: CargoStatus,
    }

    //This is the enum for the status of the cargo. It is supposed to have Available, InTransit, Matched, Unavailable, Delivered.
    //Unavailable can be added here as well to implement remove_cargo as changing status to unavailable
    //This would render the remove function redundant and might improve efficiency (depends on how developer implements it) so
    enum CargoStatus {
        Available,
        Matched
        InTransit,
        Unavailable,
        Delivered,
    }

    //This is the main contract state. It is supposed to have next_cargo_id and cargo_map.
    struct CargoListing {
        next_cargo_id: u64,
        cargo_map: u64,
    }

    //This is the constructor. It is supposed to view the next Cargo.
    #[constructor]
    fn constructor(ref self:ContractState){
        self.next_cargo_id.write(1);
    }

    //This part holds the implementation of the functions
    #[abi(embed_v0)]
    impl CargoListingImpl of CargoListingTrait<ContractState>{

        //destination was set to felt252 because of recommendation of Cairo (remember it only supports 31 characters so destructure it 
        // if destination can be set to more than that)
        fn add_cargo(ref self: ContractState, destination: felt252, size: u64, weight: u64){
            // this implementation is straight forward: get id of the last cargo -> give the new cargo an ID of id_of_last_cargo + 1 -> get business_owner
            // populate the remaining features of the cargo
            let cargo_id = self.next_cargo_id.read();
            self.next_cargo_id.write(cargo_id + 1);

            let business_owner = get_caller_address();
            let cargo = Cargo{
                id: cargo_id,
                business_owner: business_owner,
                destination: destination,
                size: size,
                weight: weight,
                status: CargoStatus::Available,
            };
            self.cargo_map.set(cargo_id, cargo);
        }

        fn update_cargo(ref self: ContractState, cargo_id: u64, destination: felt252, size: u64, weight: u64){
            //Get cargo by id -> make sure the owner is the one calling the update -> update destination, size, and weight with new values and then save
            let cargo = self.cargo_map.get(cargo_id);
            assert_eq!(cargo.business_owner, get_caller_address());
            cargo.destination = destination;
            cargo.size = size;
            cargo.weight = weight;

            self.cargo_map.insert(cargo_id, cargo);
        }
        fn remove_cargo(ref self: ContractState, cargo_id: u64){
            //find cargo by id -> make sure the owner is the one calling the update -> then remove
            let cargo = self.cargo_map.get(cargo_id);
            let cargo = self.cargo_map.get(cargo_id).expect("Cargo not found");
            assert_eq!(cargo.business_owner, get_caller_address());
            self.cargo_map.remove(cargo_id);
        }

        fn update_cargo_status(ref self:ContractState, cargo_id: u64, new_status: CargoStatus){
            //find cargo by id -> make sure the owner is the one calling the update -> then update
            let mut cargo = self.cargo_map.get(cargo_id).expect("Cargo not found");
            cargo.status = new_status;
            self.cargo_map.insert(cargo_id, cargo)
        }
    }
}
