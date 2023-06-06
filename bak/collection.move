module collection_addr::trait {
    use std::signer;
    use aptos_framework::account;
    use std::string::String;
    use aptos_std::table::{Self, Table}; 

    // Errors
    const E_NOT_INITIALIZED: u64 = 1;

    struct Collection has key {
        traits: Table<u64, Trait>,
        trait_counter: u64,
    }

    struct Trait has store, drop, copy {
        trait_id: u64,
        content: vector<u8>,
    }

    public entry fun dummy(){
        let function = 0;
    }

    public entry fun create_collection(account: &signer, seed: vector<u8>){
        let (new_resource_signer, _) = account::create_resource_account(account, seed);
        let collection = Collection {
            traits: table::new(),
            trait_counter: 0,
        };

        // move the category resource under the signer account
        move_to(&new_resource_signer, collection);
    }

    public entry fun add_trait(account: &signer, array: vector<u8>) acquires Collection {
        // gets the signer address
        let signer_address = signer::address_of(account);
        // gets the Category resource
        let collection = borrow_global_mut<Collection>(signer_address);
        // increment trait counter
        let counter = collection.trait_counter + 1;
        // creates a new Trait
        let new_trait = Trait {
            trait_id: counter,
            content: array
        };
        // adds the new task into the tasks table
        table::upsert(&mut collection.traits, counter, new_trait);
        // sets the task counter to be the incremented counter
        collection.trait_counter = counter;
    }    

}

