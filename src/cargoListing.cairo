//  this module is working as expected

use starknet::ContractAddress;

// this is the interface that will be used in the contract
#[starknet::interface]
trait ICargoListing<TContractState> {
    fn get_cargo(self : @TContractState, listing_id: u32) -> Cargo;
    fn add_cargo(ref self : TContractState, weight: u32, size: u32, destination: Location, origin: Location);
    fn update_cargo(ref self : TContractState, listing_id: u32, weight: u32, size: u32, destination: Location, origin: Location, status: CargoStatus);
    fn remove_cargo(ref self : TContractState, listing_id: u32);
    fn transfer_cargo_ownership(ref self : TContractState, listing_id: u32);
    fn get_cargo_list(self : @TContractState) -> Array<Cargo>;
    fn filter_cargo_by_size(self: @TContractState, driver_preference: Preference) -> Array<Cargo>;
    fn filter_cargo_by_weight(self: @TContractState, driver_preference: Preference,  cargo_list: Array<Cargo>) -> Array<Cargo>;
    fn get_cargo_count(self: @TContractState) -> u32;
    }

// this is the Cargo struct that will be stored in the contract
#[derive(Drop, Serde, Copy, starknet::Store)]
struct Cargo {
    id: u32,
    weight: u32,
    size: u32,
    destination: Location,
    origin:Location,
    owner: ContractAddress,
    status: CargoStatus,
    }

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Preference {
    size: u32,
    weight: u32,
    proximity: u32,
    }

// this is the Location struct that will be used in the contract
#[derive(Drop, Serde, Copy, starknet::Store)]
struct Location {
    latitude: felt252,
    longitude: felt252,
}


#[derive(Drop, Serde,Copy, starknet::Store)]
enum CargoStatus {
        Available,
        Matched,
        InTransit,
        Unavailable,
        Delivered,
    }

mod Errors {
    const UNAUTHORIZED: felt252 = 'Not owner';
    const ZERO_ADDRESS_OWNER: felt252 = 'Owner cannot be zero';
    const ZERO_ADDRESS_CALLER: felt252 = 'Caller cannot be zero';
}


// this is the implementation of the interface
#[starknet::contract]
mod CargoListing {
    use core::traits::Into;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use super::Cargo;
    use super::Location;
    use super::CargoStatus;
    use super::Preference;
    use super::Errors;


    #[storage]
    struct Storage {
        next_cargo_id: u32,
        cargo_count: u32,
        cargo_listing: LegacyMap<u32, Cargo>,
    }

    #[constructor]
    fn constructor(ref self : ContractState) {
        self.next_cargo_id.write(0);
        self.cargo_count.write(0);
    }

    #[abi(embed_v0)]
    impl CargoListingImpl of super::ICargoListing<ContractState>{      
        
        // this function will get the cargo from the list
        fn get_cargo(self : @ContractState, listing_id: u32) -> Cargo {
           return self.cargo_listing.read(listing_id);
        }

        // this function will add a new cargo to the list
        fn add_cargo(ref self : ContractState, weight: u32, size: u32, destination: Location, origin: Location) {
            let caller = get_caller_address();
            let id = self.next_cargo_id.read();
            let cargo_count = self.cargo_count.read();

            let cargo = Cargo {
                id: id,
                weight: weight,
                size: size,
                destination: destination,
                origin: origin,
                owner: caller,
                status: CargoStatus::Available,
            };
            self.cargo_listing.write(cargo.id, cargo);
            self.next_cargo_id.write(id + 1);
            self.cargo_count.write(cargo_count + 1);
        }

        // this function will update the cargo in the list
        fn update_cargo(ref self : ContractState, listing_id:u32, weight: u32, size: u32, destination: Location, origin: Location, status: CargoStatus) {
            let caller = get_caller_address();
            let cargo = self.cargo_listing.read(listing_id);

            assert(cargo.owner == caller, Errors::UNAUTHORIZED);
            let cargo = Cargo {
                id: cargo.id,
                weight: weight,
                size: size,
                destination: destination,
                origin: origin,
                owner: caller,
                status: status,
                };
                self.cargo_listing.write(cargo.id, cargo);
            }

        // this function will remove the cargo from the list 
        // we do not actually remove the cargo from the list, we just change the status to unavailable
        fn remove_cargo(ref self : ContractState, listing_id: u32) {
            let caller: ContractAddress = get_caller_address();
            let cargo : Cargo = self.cargo_listing.read(listing_id);
            // if cargo.owner!= caller {
            //     return;
            // }
            assert(cargo.owner == caller, Errors::UNAUTHORIZED);
            // change cargo avalability to unavailable
            let cargo: Cargo = Cargo {
                id: cargo.id,
                weight: cargo.weight,
                size: cargo.size,
                destination: cargo.destination,
                origin: cargo.origin,
                owner: caller,
                status: CargoStatus::Unavailable,
            };
            self.cargo_listing.write(cargo.id, cargo);
        }
  
        // this function will transfer the ownership of the cargo to the new owner
        // the caller should be the new owner
        // this method can be usefull if we want to transfer it to another user for example on accepting delivery on driver side
        fn transfer_cargo_ownership(ref self : ContractState, listing_id: u32) {
            let caller = get_caller_address();
            let cargo: Cargo = self.cargo_listing.read(listing_id);

            // assert( calle, Errors::UNAUTHORIZED);
            // change the owner of the cargo to the new owner
            let cargo = Cargo {
                id: cargo.id,
                weight: cargo.weight,
                size: cargo.size,
                destination: cargo.destination,
                origin: cargo.origin,
                owner: caller,
                status: cargo.status,
            };
            self.cargo_listing.write(cargo.id, cargo);
        }

        fn get_cargo_list(self : @ContractState) -> Array<Cargo> {
            let mut cargo_list: Array<Cargo> = ArrayTrait::new();
        //  let mut i: u32 = 0;
            let cargo_one = self.cargo_listing.read(0);
            let cargo_two = self.cargo_listing.read(1);
            cargo_list.append(cargo_one);
            cargo_list.append(cargo_two);
            return cargo_list;
        }

       // This function will filter the cargo list based on the size of the cargo. return cargos by size which are less than or equal to driver preference
       // throws an error
        fn filter_cargo_by_size( self: @ContractState, driver_preference: Preference) -> Array<Cargo>{
           // get cargo list
        let mut cargo_size = self.cargo_count.read();
        let mut driver_preference_size = driver_preference.size;
   
        let mut sorted_cargo_list : Array<Cargo> = ArrayTrait::new();
    
        let mut i: u32 = 0;

            // Loop through the entire cargo list
            loop {
                if i == cargo_size {
                    break;
                }
                // Get the cargo size
                let mut cargo: Cargo = self.cargo_listing.read(i);
                let mut size = cargo.size;

                assert(i > 2, 'i must be greater than 0');

                if size <= driver_preference_size {
                    sorted_cargo_list.append(cargo);
                 }
                i = i + 1;
            };
            return sorted_cargo_list;
        }

        // this function will filter the cargo list based on the weight of the cargo. return cargos by weight which are less than or equal to driver preference
        fn filter_cargo_by_weight(self : @ContractState, driver_preference: Preference,  cargo_list: Array<Cargo>) -> Array<Cargo>{
            
            let mut cargos = cargo_list;
            // get cargos size
            let mut cargo_size: u32 = cargos.len();
            // get the drivers preference weight
            let mut driver_preference_weight = driver_preference.weight;

            // create a new cargo list
            let mut sorted_cargo_list_by_weight : Array<Cargo> = ArrayTrait::new();

            let mut i: u32 = 0;

            loop {
                if i == cargo_size {
                    break;
                }
                // Get the cargo weight
                let mut cargo : Cargo = cargos.at(i);
                let mut weight = cargo.weight;

                if weight <= driver_preference_weight {
                    sorted_cargo_list_by_weight.append(cargo);
                }
            };
            return sorted_cargo_list_by_weight;    
        }

        // return cargo count 
        fn get_cargo_count(self : @ContractState) -> u32 {
            return self.cargo_count.read();
        }
    }
}