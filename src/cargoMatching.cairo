
// Algorithm: Cargo-to-Driver Matching
// Input: List of cargos, Driver preferences
// Output: Sorted list of cargos for a driver
    // Sort cargos based on destination proximity, size, and weight
    // This can be a multi-level sort where the first level is proximity, 
    // followed by size and then weight

use starknet::ContractAddress;

// this is the interface that will be used in the contract
#[starknet::interface]
trait ICargoMatching<TContractState> {
  //  fn match_cargo_to_driver(ref self: TContractState, driver_preferance: Preference, cargo_list: Cargo) -> Felt252Dict<Cargo>;
    //fn sort_cargo_by_preference(ref self: TContractState, driver_preferance: Preference, cargo_list: CargoList) -> Felt252Dict< Cargo>;
    //fn sort_cargo_by_proximity(ref self: TContractState, driver_preferance: Preference, cargo_list: CargoList) -> Felt252Dict< Cargo>;
    fn filter_cargo_by_size(self: @TContractState, driver_preferance: Preference, address: ContractAddress) -> Array<Cargo>;
    fn filter_cargo_by_weight(ref self: TContractState, driver_preferance: Preference, cargo_list: Array<Cargo>) -> Array<Cargo>;
    fn fetch_cargo_list(ref self: TContractState,  contract_address: ContractAddress) -> Array<Cargo>;
}

// this is the interface that will be used to interact with cargolisting contract
// based on the contract address
#[starknet::interface]
trait ICargoListing<TContractState> {
    fn get_cargo_list(ref self : TContractState) -> Array<Cargo>;
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

#[derive(Drop, Serde,Copy, starknet::Store)]
enum CargoStatus {
        Available,
        Matched,
        InTransit,
        Unavailable,
        Delivered,
    }

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Driver {
    id: ContractAddress,
    preference: Preference,
    loaction: Location,
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
    use core::traits::Destruct;
use core::option::OptionTrait;
use core::traits::TryInto;
use core::traits::Into;
    use super::{ICargoListingDispatcher, ICargoListingDispatcherTrait};
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use super::Driver;
    use super::Cargo;
    use super::Location;
    use super::CargoStatus;
    use super::Preference;

    #[storage]
    struct Storage {
        cargo_listing_contract_address: ContractAddress,
    }

//     trait ArrayTrait<T> {
//     fn new() -> Array<T>;
//     fn append(ref self: Array<T>, value: T);
//     fn pop_front(ref self: Array<T>) -> Option<T> nopanic;
//     fn pop_front_consume(self: Array<T>) -> Option<(Array<T>, T)> nopanic;
//     fn get(self: @Array<T>, index: usize) -> Option<Box<@T>>;
//     fn at(self: @Array<T>, index: usize) -> @T;
//     fn len(self: @Array<T>) -> usize;
//     fn is_empty(self: @Array<T>) -> bool;
//     fn span(self: @Array<T>) -> Span<T>;
// }

    #[constructor]
    fn constructor(ref self: ContractAddress) {
        // set the adress of cargolist contract
       // let cargo_listing_address : ContractAddress = 0x0000000000000000000000;
       // self.cargo_listing_contract_address.;
    }

    #[abi(embed_v0)]
    impl ICargoMatchingImpl of super::ICargoMatching<ContractState> {

        // This function will filter the cargo list based on the size of the cargo. return cargos by size which are less than or equal to driver preference
        fn filter_cargo_by_size( self: @ContractState, driver_preferance: Preference, address: ContractAddress) -> Array<Cargo>{
           // get cargo list
            let cargos : Array<Cargo> = ICargoListingDispatcher { contract_address: address}.get_cargo_list();
           // get cargos size
           let cargo_size = cargos.len();
            // get the drivers preference size
            let mut driver_preference_size: core::felt252 = driver_preferance.size;
           
           // create a new cargo list
            let mut sorted_cargo_list = ArrayTrait::<Cargo>::new();
            
            let mut i: u32 = 0;

            // Loop through the entire cargo list
            loop {
                if i >= cargo_size {
                    break;
                }
                // Get the cargo size
                let mut cargo = cargos.at(i);
                let mut c_size = cargo.size;

                // Compare the cargo size with the driver's preference size
                if c_size <= driver_preference_size {
                    sorted_cargo_list.append(cargo);
                };

                i = i + 1;
            };
            return sorted_cargo_list;
        }

        // filter_cargo_by_weight takes sorted cargo list Array from  filter_cargo_by_size function and will filter the cargo list based on the weight of the cargo. Return cargos by weight which are less than or equal to driver preference
         fn filter_cargo_by_weight(ref self: ContractState, driver_preferance: Preference, cargo_list: Array<Cargo>) -> Array<Cargo>{
            // get cargo list
            let mut cargos: Array<Cargo> = cargo_list;
            // get cargos size
            let mut cargo_size: u32 = cargos.len();
            // get the drivers preference weight
            let mut driver_preference_weight: felt252 = driver_preferance.weight;

            // create a new cargo list
            let mut sorted_cargo_list_by_weight = ArrayTrait::<Cargo>::new();

            let mut i: u32 = 0;
            // Loop through the entire cargo list
            loop {
                if i >= cargo_size {
                    break;
                }
                // Get the cargo weight
                let mut cargo =  cargos.at(i);
                let mut cargo_weight = cargo.weight;

                // Compare the cargo weight with the driver's preference
                if cargo_weight <= driver_preference_weight {
                    sorted_cargo_list_by_weight.append(cargo);
                }
                i = i + 1;
            };
            return sorted_cargo_list_by_weight;    
        }

        //  fn filter_cargo_by_weight(ref self: ContractState, driver_preferance: Preference, cargo_list: CargoList) -> Felt252Dict<u32, Cargo> {}

         fn fetch_cargo_list(ref self: ContractState, contract_address: ContractAddress) -> Array<Cargo> {
            let mut cargos: Array<Cargo> = ICargoListingDispatcher { contract_address: contract_address }.get_cargo_list();
            return cargos;
        }
    }
}

// IContractDispatcher { contract_address: addr }.method(value);