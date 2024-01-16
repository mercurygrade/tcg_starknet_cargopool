#[starknet::interface]
trait IOwned<TContractState> {
    fn do_something(ref self: TContractState);
}

#[starknet::contract]
mod OwnedContract {
    use components::ownable::IOwnable;
    use components::ownable::ownable_component::OwnableInternalTrait;
    use components::ownable::ownable_component;

    component!(path: ownable_component, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = ownable_component::Ownable<ContractState>;
    impl OwnableInternalImpl = ownable_component::OwnableInternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: ownable_component::Storage,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.ownable._init(starknet::get_caller_address());
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnableEvent: ownable_component::Event,
    }

    #[external(v0)]
    impl Owned of super::IOwned<ContractState> {
        fn do_something(ref self: ContractState) {
            self.ownable._assert_only_owner();
        // ...
        }
    }
}