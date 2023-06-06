module collection_addr::trait {
    use std::signer;
    use aptos_framework::account;
    use std::string::String;
    use aptos_std::table::{Self, Table}; 

    // Errors
    const E_NOT_INITIALIZED: u64 = 1;

    struct Collection has key {
        categories: Table<u64, Category>,
        category_counter: u64,
    }

    struct Category has store, drop, copy {
        traits: Table<u64, Trait>,
        trait_counter: u64,
    }

    struct Trait has store, drop, copy {
        trait_id: u64,
        content_reference: u64,
    }

    public entry fun create_collection(account: &signer, seed: vector<u8>){
        let (new_resource_signer, _) = account::create_resource_account(account, seed);
        let collection = Collection {
            categories: table::new(),
            category_counter: 0,
        };

        // move the category resource under the signer account
        move_to(&new_resource_signer, collection);
    }

    public entry fun create_category(account: &signer, seed: vector<u8>){
        
        // gets the signer address
        let signer_address = signer::address_of(account);
        // assert signer has created a collection
        assert!(exists<Collection>(signer_address), E_NOT_INITIALIZED);
        // gets the Collection resource
        let collection = borrow_global_mut<Collection>(signer_address);

        let category = Category {
            traits: table::new(),
            trait_counter: 0,
        };

        // increment category counter
        let counter = collection.category_counter + 1;

        // adds the new task into the tasks table
        table::upsert(&mut collection.categories, counter, category);
        // sets the task counter to be the incremented counter
        collection.category_counter = counter;
    }

    public entry fun add_trait(account: &signer, content: vector<u8>) acquires Category {
        // gets the signer address
        let signer_address = signer::address_of(account);
        // gets the Category resource
        let category = borrow_global_mut<Category>(signer_address);
        // increment trait counter
        let counter = category.trait_counter + 1;
        // Upload bytearray and store reference
        let reference = 23423432;
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

