// this is a test module for the cargo matching contract - specifically filtering cargo by size function
// but currently could not find a data struct that fits the algorithm
use starknet::ContractAddress;

#[starknet::interface]
trait ICargoMatchingImpl<TContractState> {
   fn filter_cargo_by_size( self: @TContractState, driver_preferance: Preference, addr: ContractAddress);
 
}

#[starknet::interface]
trait ICargoListing<TContractState> {
    // I have not found a way to get the list of cargo from the contract state.
    fn get_cargo_list(self : @TContractState);
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

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Preference {
    size: felt252,
    weight: felt252,
    proximity: felt252,
    }


#[starknet::contract]
mod CargoMatching {
    use super::{ICargoListingDispatcher, ICargoListingDispatcherTrait};
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use super::Preference;
    use super::Location;

    #[storage]
    struct Storage {
        cargo_listing_contract_address: ContractAddress,
    }

    #[abi(embed_v0)]
     impl CargoMatchingImpl of super::ICargoMatchingImpl<ContractState>  {
        fn filter_cargo_by_size( self: @ContractState, driver_preferance: Preference, addr: ContractAddress) {
            ICargoListingDispatcher {contract_address: addr}.get_cargo_list();

            let mut sorted_cargo_list: Felt252Dict<Cargo> = Default::default();
            let mut cargo_index: u32 = 0;

            // Loop through the entire cargo list
            loop {
                if cargo_index == cargo_list.size {
                    break;
                }
                // Assuming the size is the first element of each tuple in the Felt252Dict
                 let cargo_size = cargo_list.get(cargo_index).size;

                // Compare the cargo size with the driver's preference
                // Store the cargo size and original index
                
                if cargo_size <= driver_preference_size {
                    sorted_cargo_list.insert(cargo_index ,cargo_list.get(cargo_index));
                }
                // Increment the cargo list index
                cargo_index = cargo_index + 1;
            }
            
            return sorted_cargo_list;
        }
    }
}



        // fn match_cargo_to_driver(ref self: ContractState, driver_preferance: Preference, cargo_list: Cargo) -> Felt252Dict<Cargo>{
        //     // get the cargo list from the cargolisting contract
        //     let cargo_list_contract = ICargoListingDispatcher(self.cargo_listing_contract_address.read());
        //     let cargo_list = cargo_list_contract.get_cargo_list();
        //     // sort the cargo list based on the driver preference
        //     let cargo_list = self.sort_cargo_by_preference(driver_preferance, cargo_list);
        //     // return the sorted cargo list
        //     return cargo_list;
        // }

        // This function will sort the cargo list first by size, then weight, then proximity
        // fn sort_cargo_by_preference(ref self: ContractState, driver_preferance: Preference, cargo_list: CargoList) -> Felt252Dict<Cargo> {
        //     // sort the cargo list based on the size of the cargo
        //     let cargo_list = self.sort_cargo_by_size(driver_preferance, cargo_list);
        //     // sort the cargo list based on the weight of the cargo
        //     let cargo_list = self.sort_cargo_by_weight(driver_preferance, cargo_list);
        //     // sort the cargo list based on the proximity to the driver
        //     let cargo_list = self.sort_cargo_by_proximity(driver_preferance, cargo_list);
        //     // return the sorted cargo list
        //     return cargo_list;
        // }

        // sort_cargo_by_proximity function will sort the cargo list based on the proximity to the driver
        // Sort cargos based on proximity to the specified origin location
        // Closer destinations should come first
        // fn sort_cargo_by_proximity(ref self: ContractState, driver_preferance: Preference, cargo_list: CargoList) -> Felt252Dict<Cargo>{
        //     // create a new cargo list
        //     let mut sorted_cargo_list: Felt252Dict<Cargo> = Default::default();
        //     // get the driver location
        // }
