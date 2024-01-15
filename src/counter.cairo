
#[starknet::interface]
trait ICounter<TContractState> {
    fn get_counter(ref self: TContractState) -> u32;
    fn add_counter(ref self: TContractState, number: u32) -> ();
}

#[starknet::contract]
mod Counter {
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        count: u32,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.count.write(0);
    }

    #[abi(embed_v0)]
    impl ICounterImpl of super::ICounter<ContractState>{
    fn get_counter(ref self: ContractState) -> u32 {
        self.count.read()
    }
    fn add_counter(ref self: ContractState, number: u32) -> () {
        self.count.write(self.count.read() + number);
  }
 }
}