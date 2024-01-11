// import CargoListing
use crate::CargoListing::{Cargo, CargoStatus};

//this should implement the interface upon completion
#[starknet::interface]
trait CargoListingTrait<TContractState> {

}

//matching contract implementation
#[starknet::contract]
mod MatchingAlgorithm {
    //import contractaddress and get caller from starknet
    use starknet::{
        ContractAddress,
        get_caller_address,
    };

    //implement the storage here (Cairo requires a storage to be implemented)
    #[storage]
    struct MatchingAlgorithm{}

    //So the basic working of this is that two cargos are compared based source, size, destination, and weight
    //This is just a simple implementation, when fully implemented it should use algorithms to find the nearest match
    //and handle cases when the destination of one is enroute to the next
    //unmatch can be implemented here too

    impl MatchingAlgorithm {
        fn match_cargos(cargo_id1: u64, cargo_id2: u64) -> bool {
            let cargo1 = ContractState::load::<CargoListing>().cargo_map.get(cargo_id1).expect("Cargo not found");
            let cargo2 = ContractState::load::<CargoListing>().cargo_map.get(cargo_id2).expect("Cargo not found");
            
            // let source_match = cargo1.source == cargo2.source;
            let destination_match = cargo1.destination == cargo2.destination;
            let size_match = cargo1.size == cargo2.size;
            let weight_match = cargo1.weight == cargo2.weight;
            
            destination_match && size_match && weight_match; //&& source_match
        }

        //take ids of two cargos, match them and update status of CargoListing
        fn perform_matching(cargoid1, cargo_id2) {
            if MatchingAlgorithm::match_cargos(cargo_id1, cargo_id2) {
                ContractState::load::<CargoListing>().update_cargo_status(cargo_id1, CargoStatus::Matched)
                ContractState::load::<CargoListing>().update_cargo_status(cargo_id2, CargoStatus::Matched)
            }
        }
    }
}
