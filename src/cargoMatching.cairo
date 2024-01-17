
// Algorithm: Cargo-to-Driver Matching
// Input: List of cargos, Driver preferences
// Output: Sorted list of cargos for a driver

    // Sort cargos based on destination proximity, size, and weight
    // This can be a multi-level sort where the first level is proximity, 
    // followed by size and then weight

use starknet::ContractAddress;

// this is the interface that will be used in the contract
#[starknet::interface]
trait ICargoMatchingImpl<TContractState> {
    fn match_cargo_to_driver(ref sefl: TContractState, driver_preferance: Preference, cargo_list: Cargo) -> CargoList;
    fn sort_cargo_by_preference(ref self, driver_preferance: Preference, cargo_list: CargoList) -> CargoList;
    fn sort_cargo_by_proximity(ref self, driver_preferance: Preference, cargo_list: CargoList) -> CargoList;
    fn sort_cargo_by_size(ref self, driver_preferance: Preference, cargo_list: CargoList) -> CargoList;
    fn sort_cargo_by_weight(ref self, driver_preferance: Preference, cargo_list: CargoList) -> CargoList;
}

#[starknet::interface]
trait ICargoListing<TContractState> {
    fn get_cargo(self : @TContractState, listing_id: u32) -> Cargo;
    fn get_cargo_list(self : @TContractState) -> LegacyMap<u32, Cargo>;
    }

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Cargo {
    id: u32,
    weight: felt252,
    size: felt252,
    destination: Location,
    origin:Location,
    owner: ContractAddress,
    status: CargoStatus,
    }

#[derive(Drop, Serde, Copy, starknet::Store)]
struct CargoList { 
    cargo_list: LegacyMap<u32, Cargo>,
    }

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Driver {
    id: ContractAddress,
    preference: Preference,
    }

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Location {
    lat: felt252,
    long: felt252,
    }

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Preference {
    size: felt252,
    weight: felt252,
    proximity: felt252,
    }

#[starknet::contract]
mod CargoMatching {
    use super::{ICalleeDispatcher, ICalleeDispatcherTrait};
    use starknet::[ContractAddress::get_caller_address];
    use super::Preference;
    use super::Driver;

    #[storage]
    struct Storage {
        #[substorage]
        cargo_listing: CargoListing,
    };


    #[abi(embed_v0)]
    impl CargoMatchingImpl of super::CargoMatching<CargoMatchingState>  {
        fn match_cargo_to_driver(ref self, driver_preferance: Preference, cargo_list: Cargo) -> CargoList {

        }

        // This function will sort the cargo list based on the driver preference
        fn sort_cargo_by_preference(ref self, driver_preferance: Preference, cargo_list: CargoList) -> CargoList {

        }

        // This function will sort the cargo list based on the proximity to the driver
        fn sort_cargo_by_proximity(ref self, driver_preferance: Preference, cargo_list: CargoList) -> CargoList {

        }

        // This function will sort the cargo list based on the size of the cargo
        fn sort_cargo_by_size(ref self, driver_preferance: Preference, cargo_list: CargoList) -> CargoList{

        }

        // This function will sort the cargo list based on the weight of the cargo
        fn sort_cargo_by_weight(ref self, driver_preferance: Preference, cargo_list: CargoList) -> CargoList {

        }

        fn get_cargo_list(ref self) -> CargoList {
            let caller_address = ContractAddress::get_caller_address();
            let cargo_list = self.cargo_listing.get_cargo_list(caller_address);
        }
    }


}