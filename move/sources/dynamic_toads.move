module aptoads_objects::dynamic_toads {
   use std::object::{Self, Object, ConstructorRef, ExtendRef, TransferRef};
   use token_objects::token::{Self, MutatorRef, Token};
   use token_objects::collection::{Self, Collection};
   use token_objects::royalty::{Royalty};
   use std::string::{Self, String};
   use std::option::{Self, Option};
   use aptos_std::string_utils;
   use aptos_std::type_info;
   use std::vector;

   // TODO:
   // create tree of traits mapped to images
   // don't have time to make (or in pressentation to make) the
   // image generator. so just statically create these images
   // and link them in the smart contract.
   // when equipping/uneqipping things to toads, use the tree
   // to find what image should be used



   #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
   struct Metadata has key {
      z_index: u64,
      image: String,
   }

   #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
   struct Aptoad has key {
      background: Option<Object<Background>>,
      skin: Option<Object<Skin>>,
      mouth: Option<Object<Mouth>>,
      mask: Option<Object<Mask>>,
      head: Option<Object<Head>>,
      eyes: Option<Object<Eyes>>,
      clothes: Option<Object<Clothes>>,
      mutator_ref: MutatorRef,
   }

   #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
   struct Background has key {
      trait_name: String,
   }
   #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
   struct Skin has key {
      trait_name: String,
   }
   #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
   struct Mouth has key {
      trait_name: String,
   }
   #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
   struct Mask has key {
      trait_name: String,
   }
   #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
   struct Head has key {
      trait_name: String,
   }
   #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
   struct Eyes has key {
      trait_name: String,
   }
   #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
   struct Clothes has key {
      trait_name: String,
   }

   #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
   struct Refs has key {
      transfer_ref: TransferRef,
      extend_ref: ExtendRef,
   }

   /// Action not authorized because the signer is not the owner of this module
   const ENOT_AUTHORIZED: u64 = 1;
   /// That type doesn't exist on the object
   const EINVALID_TYPE: u64 = 2;

   const COLLECTION_NAME: vector<u8> = b"Aptos Toad 2";
   const COLLECTION_DESCRIPTION: vector<u8> = b"the OGs 2";
   const COLLECTION_URI: vector<u8> = b"https://aptoads.nyc3.digitaloceanspaces.com/images/perfects/pilot.png";
   const BASE_TOKEN_NAME: vector<u8> = b"{} #{}";
   const BASE_TOKEN_URI: vector<u8> = b"https://aptoads.nyc3.digitaloceanspaces.com/images/";
   const MAXIMUM_SUPPLY: u64 = 1000;

   fun init_module(creator: &signer) {
      let collection_constructor_ref = collection::create_fixed_collection(
         creator,
         string::utf8(COLLECTION_DESCRIPTION),
         MAXIMUM_SUPPLY,
         string::utf8(COLLECTION_NAME),
         option::none<Royalty>(),
         string::utf8(COLLECTION_URI),
      );

      let _collection_object = object::object_from_constructor_ref<Collection>(&collection_constructor_ref);
      
   }

   public entry fun mint_new(creator: &signer, object_address: String) {
      let aptoad_constructor_ref = create<Aptoad>(creator, string::utf8(b"Base"), string::utf8(b"1"), 1, 0, string::utf8(b"Base"));
      let aptoad_object = object::object_from_constructor_ref<Aptoad>(&aptoad_constructor_ref);
      // let clothing_object_2 = object::object_address<Clothing>(&object_address);
      // toad_equip_trait(creator, aptoad_object, clothing_object_1);
      
      // std::debug::print(&view_object(aptoad_object));
   }

   public entry fun create_new<T:key> (
      creator: &signer,
      trait_type: String,
      trait_name: String,
      num_trait_type: u64,
      z_index: u64,
      image: String,
   ) {
      let res = create<T>(creator, trait_type, trait_name, num_trait_type, z_index, image);
      //let aptoad_object = object::object_from_constructor_ref<T>(&res);
      //let aptoad_metadata = object::object_from_constructor_ref<Metadata>(&res);
   }

   fun create<T>(
      creator: &signer,
      trait_type: String,
      trait_name: String,
      num_trait_type: u64,
      z_index: u64,
      image: String,
   ): ConstructorRef {
      let token_name = trait_type;
      string::append_utf8(&mut token_name, b" #");
      string::append_utf8(&mut token_name, *string::bytes(&u64_to_string(num_trait_type)));

      let token_uri = string::utf8(BASE_TOKEN_URI);
      string::append_utf8(&mut token_uri, *string::bytes(&trait_type));
      string::append_utf8(&mut token_uri, b"/");
      string::append_utf8(&mut token_uri, *string::bytes(&trait_name));
      string::append_utf8(&mut token_uri, (b".png"));
      


      let constructor_ref = token::create_named_token(
         creator,
         string::utf8(COLLECTION_NAME),
         string::utf8(COLLECTION_DESCRIPTION),
         token_name,
         option::none(),
         token_uri,
      );

      let transfer_ref = object::generate_transfer_ref(&constructor_ref);
      let extend_ref = object::generate_extend_ref(&constructor_ref);
      let token_signer = object::generate_signer(&constructor_ref);

      move_to(
         &token_signer,
         Refs {
            transfer_ref,
            extend_ref,
         }
      );

      if (type_info::type_of<T>() == type_info::type_of<Aptoad>()) {
         let mutator_ref = token::generate_mutator_ref(&constructor_ref);
         // create aptoad object
         move_to(
            &token_signer,
            Aptoad {
               background: option::none(),
               skin: option::none(),
               mouth: option::none(),
               mask: option::none(),
               head: option::none(),
               eyes: option::none(),
               clothes: option::none(),
               mutator_ref,
            }
         );
      } else if (type_info::type_of<T>() == type_info::type_of<Background>()) {
         move_to(
            &token_signer,
            Background {
               trait_name,
            }
         );
      } else if (type_info::type_of<T>() == type_info::type_of<Skin>()) {
         move_to(
            &token_signer,
            Skin {
               trait_name,
            }
         );
      } else if (type_info::type_of<T>() == type_info::type_of<Mouth>()) {
         move_to(
            &token_signer,
            Mouth {
               trait_name,
            }
         );
      } else if (type_info::type_of<T>() == type_info::type_of<Mask>()) {
         move_to(
            &token_signer,
            Mask {
               trait_name,
            }
         );
      } else if (type_info::type_of<T>() == type_info::type_of<Head>()) {
         move_to(
            &token_signer,
            Head {
               trait_name,
            }
         );
      } else if (type_info::type_of<T>() == type_info::type_of<Eyes>()) {
         move_to(
            &token_signer,
            Eyes {
               trait_name,
            }
         );
      } else if (type_info::type_of<T>() == type_info::type_of<Clothes>()) {
         move_to(
            &token_signer,
            Clothes {
               trait_name,
            }
         );
      };

      move_to(
         &token_signer,
         Metadata {
            z_index,
            image,
         }
      );

      constructor_ref
   }

   public fun toad_equip_trait<T: key>(owner: &signer, toad_object: Object<Aptoad>, obj_to_equip: Object<T>) acquires Aptoad {
      let toad_obj_resources = borrow_global_mut<Aptoad>(object::object_address(&toad_object));
      let object_address = object::object_address<T>(&obj_to_equip);
      if (exists<Background>(object_address)) {
         let background_obj = object::convert<T, Background>(obj_to_equip);
         option::fill<Object<Background>>(&mut toad_obj_resources.background, background_obj);
         object::transfer_to_object(owner, obj_to_equip, toad_object);
      } else if (exists<Skin>(object_address)) {
         let skin_obj = object::convert<T, Skin>(obj_to_equip);
         option::fill<Object<Skin>>(&mut toad_obj_resources.skin, skin_obj);
         object::transfer_to_object(owner, obj_to_equip, toad_object);
      } else if (exists<Mouth>(object_address)) {
         let mouth_obj = object::convert<T, Mouth>(obj_to_equip);
         option::fill<Object<Mouth>>(&mut toad_obj_resources.mouth, mouth_obj);
         object::transfer_to_object(owner, obj_to_equip, toad_object);
      } else if (exists<Mask>(object_address)) {
         let mask_obj = object::convert<T, Mask>(obj_to_equip);
         option::fill<Object<Mask>>(&mut toad_obj_resources.mask, mask_obj);
         object::transfer_to_object(owner, obj_to_equip, toad_object);
      } else if (exists<Head>(object_address)) {
         let head_obj = object::convert<T, Head>(obj_to_equip);
         option::fill<Object<Head>>(&mut toad_obj_resources.head, head_obj);
         object::transfer_to_object(owner, obj_to_equip, toad_object);
      } else if (exists<Eyes>(object_address)) {
         let eyes_obj = object::convert<T, Eyes>(obj_to_equip);
         option::fill<Object<Eyes>>(&mut toad_obj_resources.eyes, eyes_obj);
         object::transfer_to_object(owner, obj_to_equip, toad_object);
      } else if (exists<Clothes>(object_address)) {
         let clothes_obj = object::convert<T, Clothes>(obj_to_equip);
         option::fill<Object<Clothes>>(&mut toad_obj_resources.clothes, clothes_obj);
         object::transfer_to_object(owner, obj_to_equip, toad_object);
      };
   }

   
   #[view]
   fun view_object<T: key>(obj: Object<T>): String acquires Aptoad, Background, Skin, Mouth, Mask, Head, Eyes, Clothes {
      let token_address = object::object_address(&obj);
      //string::utils::to_string(borrow_global<T>(token_address))
      if (exists<Aptoad>(token_address)) {
         string_utils::debug_string(borrow_global<Aptoad>(token_address))
      } else if (exists<Background>(token_address)) {
         string_utils::debug_string(borrow_global<Background>(token_address))
      } else if (exists<Skin>(token_address)) {
         string_utils::debug_string(borrow_global<Skin>(token_address))
      } else if (exists<Mouth>(token_address)) {
         string_utils::debug_string(borrow_global<Mouth>(token_address))
      } else if (exists<Mask>(token_address)) {
         string_utils::debug_string(borrow_global<Mask>(token_address))
      } else if (exists<Head>(token_address)) {
         string_utils::debug_string(borrow_global<Head>(token_address))
      } else if (exists<Eyes>(token_address)) {
         string_utils::debug_string(borrow_global<Eyes>(token_address))
      } else if (exists<Clothes>(token_address)) {
         string_utils::debug_string(borrow_global<Clothes>(token_address))
      } else {
         abort EINVALID_TYPE
      }
   }

   #[view]
   fun view_metadata_object<T: key>(obj: Object<T>): String acquires Metadata {
      let token_address = object::object_address(&obj);
      //string::utils::to_string(borrow_global<T>(token_address))
      string_utils::debug_string(borrow_global<Metadata>(token_address))
   }

   fun u64_to_string(value: u64): String {
      if (value == 0) {
         return string::utf8(b"0")
      };
      let buffer = vector::empty<u8>();
      while (value != 0) {
         vector::push_back(&mut buffer, ((48 + value % 10) as u8));
         value = value / 10;
      };
      vector::reverse(&mut buffer);
      string::utf8(buffer)
   }

   // #[test(owner = @0xFA)]
   // fun test(
   //    owner: &signer,
   // ) acquires Aptoad, Clothing, Headwear, Glasses, Tongue, Fly, Metadata {
   //    init_module(owner);
   // }

}