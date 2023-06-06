module upload_addr::upload_file {
    use std::signer;
    use aptos_framework::account;
    struct UploadFile has key {
        byte_array: vector<u8>
            }


    public à

    public entry fun upload(account: &signer, array: vector<u8>, seed: vector<u8>){
        let (new_resource_signer, _) = account::create_resource_account(account, seed);
        let upload_file = UploadFile {
            byte_array: array,
        };
        
        // move the UploadFile resource under the signer account
        move_to(&new_resource_signer, upload_file);
    }

    public entry fun uploadLarge(account: &signer, array: vector<u8>, seed: vector<u8>){

    }

}

