use starknet::ContractAddress;

// this is the interface that will be used in the contract
#[starknet::interface]
trait ICargoListing<TContractState> {
    fn get_cargo(self : @TContractState, listing_id: u32) -> Cargo;
    fn add_cargo(ref self : TContractState, weight: felt252, size: felt252, destination: Location, origin: Location);
    fn update_cargo(ref self : TContractState, listing_id: u32, weight: felt252, size: felt252, destination: Location, origin: Location, status: CargoStatus);
    fn remove_cargo(ref self : TContractState, listing_id: u32);
    fn transfer_cargo_ownership(ref self : TContractState, listing_id: u32, new_owner: ContractAddress);
    fn get_cargo_owner(self : @TContractState, listing_id: u32) -> ContractAddress;
    fn get_owner(self : @TContractState) -> ContractAddress;
    // fn get_cargo_count(self : @TContractState) -> u32;
    // fn get_cargo_list(self : @TContractState, start: u32, end: u32) -> Vec<Cargo>;
    // fn get_cargo_list_by_owner(self : @TContractState, owner: ContractAddress, start: u32, end: u32) -> Vec<Cargo>;
    // fn get_cargo_list_by_status(self : @TContractState, status: CargoStatus, start: u32, end: u32) -> Vec<Cargo>;
    // fn get_cargo_list_by_origin(self : @TContractState, origin: Location, start: u32, end: u32) -> Vec<Cargo>;
    // fn get_cargo_list_by_destination(self : @TContractState, destination: Location, start: u32, end: u32) -> Vec<Cargo>;
    // fn get_cargo_list_by_origin_and_destination(self : @TContractState, origin: Location, destination: Location, start: u32, end: u32) -> Vec<Cargo>;
    }

// this is the Cargo struct that will be stored in the contract
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

#[event]
#[derive(Drop, starknet::Event)]
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
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use super::Cargo;
    use super::Location;
    use super::CargoStatus;
    use super::Errors;


    #[storage]
    struct Storage {
        next_cargo_id: u32,
        cargo_listing: LegacyMap::<u32, Cargo>,
    }

    #[constructor]
    fn constructor(ref self : ContractState) {
        self.next_cargo_id.write(1);
    }

    #[abi(embed_v0)]
    impl CargoListingImpl of super::ICargoListing<ContractState>{       
        
        // this function will get the cargo from the list
        fn get_cargo(self : @ContractState, listing_id: u32) -> Cargo {
           return self.cargo_listing.read(listing_id);
        }

        // this function will add a new cargo to the list
        fn add_cargo(ref self : ContractState, weight: felt252, size: felt252, destination: Location, origin: Location) {
            let caller = get_caller_address();
            let id = self.next_cargo_id.read();
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
        }

        // this function will update the cargo in the list
        fn update_cargo(ref self : ContractState, listing_id:u32, weight: felt252, size: felt252, destination: Location, origin: Location, status: CargoStatus) {
            let caller = get_caller_address();
            let cargo = self.cargo_listing.read(listing_id);
            // if cargo.owner!= caller {
            //     return;
            // }
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
            let caller = get_caller_address();
            let cargo = self.cargo_listing.read(listing_id);
            // if cargo.owner!= caller {
            //     return;
            // }
            assert(cargo.owner == caller, Errors::UNAUTHORIZED);
            // change cargo avalability to unavailable
            let cargo = Cargo {
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
        fn transfer_cargo_ownership(ref self : ContractState, listing_id: u32, new_owner: ContractAddress) {
            let caller = get_caller_address();
            let cargo = self.cargo_listing.read(listing_id);

            assert(caller == new_owner, Errors::UNAUTHORIZED);
            // change the owner of the cargo to the new owner
            let cargo = Cargo {
                id: cargo.id,
                weight: cargo.weight,
                size: cargo.size,
                destination: cargo.destination,
                origin: cargo.origin,
                owner: new_owner,
                status: cargo.status,
            };
            self.cargo_listing.write(cargo.id, cargo);
        }

        // this function will return the owner of the cargo
        fn get_cargo_owner(self : @ContractState, listing_id: u32) -> ContractAddress {
            let cargo = self.cargo_listing.read(listing_id);
            return cargo.owner;
        }
    }
}