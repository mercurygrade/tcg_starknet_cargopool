//import cargoListing
use crate::CargoListing::{Cargo, CargoStatus};

//SHipmentTracking implementation
#[starknet::contract]
mod ShipmentTracking {
    //implement storage here
    struct ShipmentTracking;
 
    impl ShipmentTracking {
        //find cargo by id, make sure owner is calling the tracking, get status
        //if new status, call notify users
        fn update_cargo_status(cargo_id: u64, new_status: CargoStatus) {
            let mut cargo = ContractState::load::<CargoListing>().get(cargo_id).expect("Cargo not found");

            assert_eq!(cargo.business_owner, get_caller_address());
            cargo[cargo_id].get_status(CargoStatus);

            //conditional here
            ContractState::store::<CargoListing>().update_cargo_status(cargo_id, new_status);
            ShipmentTracking::notifyUsers(cargo_id, new_status){
            }
        }

        //notify users of status change, send message with se
        fn notifyUsers(cargo_id: u64, new_status:CargoStatus) {
            let sender = ContractState::load::<User>().user_map.get(sender).expect("User not found");
            let recipient = ContractState::load::<User>().user_map.get(recipient).expect("User not found");

            let message = format!("Dear {}, your cargo's status has changed  from {} to {}. It is destined for {}", //owner.name, old_status, new_status, //destination);     

            let notification = Notification {
                message: message,
                owner: cargo.owner,
                old_status: cargo.CargoStatus,
                new_status:,
                destination: cargo.destination,
            };

            ContractState::load::<Notification>().notification_map.insert(notification);
        }

        //this should be sent when  cargo reaches destination
        fn confirmDelivery(cargo_id: u64){
            let Cargo=ContractState::store::<CargoListing>().cargo_map.get(cargo_id).expect("Cargo not found");
            assert_eq!(cargo.business_owner, get_caller_address());
            ShipmentTracking::update_cargo_status(cargo_id, CargoStatus::Delivered);

            TransactionAndPayment::process_payment(cargo_id);
            ShipmentTracking::notifyUsers(cargo_id, new_status::Delivered)
        }
    }
}