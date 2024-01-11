use starknet:: {
    ContractAddress,
    get_caller_address,
};

//import cargoListing
use crate::CargoListing::{Cargo, CargoStatus};

//storage
struct TransactionAndPayment;

impl TransactionAndPayment {
    //check balance- this function is probably expected to change based on newer code written
    fn check_balance(address: ContractAddress) -> u128 {
        ContractState::load::<TransactionAndPayment>().balance_map.get(address)
    }

    //initiate transaction by getting address then checking balance, after both pass initiate the transfer process
    fn initiate_transaction(amount: u128, recipient: ContractAddress){
        let sender_address = get_caller_address();
        assert!(TransactionAndPayment::check_balance(sender_address) >= amount, "Insufficient funds");
        TransactionAndPayment::transfer_funds(sender_address, recipient, amount);
    }

    //transfer funds from one address to another
    //find cargo -> assert if it has been shipped -> calculate payment based on size, weight, destination (length to be calculated)
    fn process_payment(cargo_id: u64) {
        let cargo = ContractState::load::<CargoListing>().cargo_map.get(cargo_id).expect("Cargo not found");
        assert_eq!(cago.status, CargoStatus::InTransit, "Cargo not shipped");
        let payment_amount = TransactionAndPayment::calculate_payment_amount(cargo.size, cargo.weight, cargo.destination);
        TransactionAndPayment::initiate_transaction(payment_amount, cargo.business_owner);
    }

    //function to calculate payment amount
    fn calculate_payment_amount(size: u64, weight: u64) -> u128 {
        ContractState::load::<TransactionAndPayment>().balance_map.get(address).unwrap_or(&0).clone()
    }

    //similar to the notify function on the shipmentTracking, it notifies users of payment they have sent
    fn notify_users(sender: ContractAddress, recipient: ContractAddress, amount: u128) {
        let sender = ContractState::load::<User>().user_map.get(sender).expect("User not found");
        let recipient = ContractState::load::<User>().user_map.get(recipient).expect("User not found");

        let message = format!("{} has sent {} to {}", sender.name, amount, recipient.name);

        let notification = Notification {
            message: message,
            sender: sender.address,
            recipient: recipient.address,
        };

        ContractState::load::<Notification>().notification_map.insert(notification);
    }
}