module trait_addr::trait {
    use upload_addr::upload_file::upload;
    use std::signer;
    use aptos_framework::account;
    use std::string::String;
    use aptos_std::table::{Self, Table}; 

    // Errors
    const E_NOT_INITIALIZED: u64 = 1;

    struct Category has key {
        traits: Table<u64, Trait>,
        trait_counter: u64,
    }

    struct Trait has store, drop, copy {
        trait_id: u64,
        content_reference: u64,
    }

    public entry fun create_category(account: &signer, array: vector<u8>, seed: vector<u8>){
        let (new_resource_signer, _) = account::create_resource_account(account, seed);
        let category = Category {
            traits: table::new(),
            trait_counter: 0,
        };

        // move the category resource under the signer account
        move_to(&new_resource_signer, category);
    }

    public entry fun add_trait(account: &signer, content: vector<u8>) acquires Category {
        // gets the signer address
        let signer_address = signer::address_of(account);
        // assert signer has a category
        assert!(exists<Category>(signer_address), E_NOT_INITIALIZED);
        // gets the Category resource
        let category = borrow_global_mut<Category>(signer_address);
        // increment trait counter
        let counter = category.trait_counter + 1;
        // Upload bytearray and store reference
        let seed = 124323432; // TODO: randomize this? or how do we find storage addresses
        let reference = 23423432; //upload(signer_address,content,seed);
        // creates a new Trait
        let new_trait = Trait {
        trait_id: counter,
        content_reference: reference
        };
        // adds the new task into the tasks table
        table::upsert(&mut category.traits, counter, new_trait);
        // sets the task counter to be the incremented counter
        category.trait_counter = counter;
    }    

}

