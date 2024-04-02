#!/bin/bash
set -e
set -x # debug print outs

# Default network URLs
DEVNET_URL="https://api.devnet.solana.com"
MAINNET_URL="https://api.mainnet-beta.solana.com"
UPGRADE_AUTHORITY=~/.config/solana/FutaAyNb3x9HUn1EQNueZJhfy6KCNtAwztvBctoK6JnX.json

# Function to check and source the configuration file
source_config() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 config_file_path {build|deploy_devnet|deploy_mainnet|verify_remote}"
        exit 1
    fi

    CONFIG_FILE_PATH=$1
    if [ ! -f "$CONFIG_FILE_PATH" ]; then
        echo "Configuration file not found: $CONFIG_FILE_PATH"
        exit 1
    fi

    # Source the configuration file
    source "$CONFIG_FILE_PATH"
}

# Function to build and get IDL
build_and_get_idl() {
    echo "Building and getting IDL for $PROGRAM_LIB_NAME"
    anchor build -p $PROGRAM_LIB_NAME
    rm -rf target/deploy/${PROGRAM_LIB_NAME}.so
    solana-verify build --library-name "$PROGRAM_LIB_NAME"
    solana-verify get-executable-hash "target/deploy/${PROGRAM_LIB_NAME}.so"
}

# Function to deploy program
deploy_program() {
    local network_url=$1
    local network_name=$2
    echo "Deploying to $network_name"
    solana config set --keypair "$UPGRADE_AUTHORITY"
    solana config set --url "$network_url"
    solana program deploy -u "$network_url" "target/deploy/${PROGRAM_LIB_NAME}.so" --program-id "$PROGRAM_ID_KEYPAIR" --upgrade-authority "$UPGRADE_AUTHORITY" --with-compute-unit-price 1
}

# Function to upload IDL
upload_idl() {
    local network_name=$1
    local program_id=$(solana-keygen pubkey $PROGRAM_ID_KEYPAIR)
    echo "Uploading IDL for $network_name"
    if ! anchor idl init -f "target/idl/${PROGRAM_LIB_NAME}.json" "$program_id" --provider.cluster "$network_name" --provider.wallet "$UPGRADE_AUTHORITY"; then
        echo "IDL likely already exists, attempting upgrade"
        anchor idl upgrade -f "target/idl/${PROGRAM_LIB_NAME}.json" "$program_id" --provider.cluster "$network_name" --provider.wallet "$UPGRADE_AUTHORITY" 
    fi
}

# New function to execute solana verify with --remote conditionally
verify_remote() {

    local network_name=$1
    local program_id=$(solana-keygen pubkey "$PROGRAM_ID_KEYPAIR")

    if [[ "$network_name" == "devnet" ]]; then
        echo "Verifying deployment on devnet by comparing hashes."
        local local_hash=$(solana-verify get-executable-hash "target/deploy/${PROGRAM_LIB_NAME}.so")
        local deployed_hash=$(solana-verify get-program-hash -u $network_name "$program_id")

        if [[ $local_hash == $deployed_hash ]]; then
            echo "Success: Local and devnet deployed program hashes match."
        else
            echo "Error: Hash mismatch between local and deployed program."
            exit 1
        fi
    elif [[ "$network_name" == "mainnet" ]]; then
        echo "Verifying deployment on mainnet by comparing hashes."
        local local_hash=$(solana-verify get-executable-hash "target/deploy/${PROGRAM_LIB_NAME}.so")
        local deployed_hash=$(solana-verify get-program-hash -u $network_name "$program_id")

        if [[ $local_hash == $deployed_hash ]]; then
            echo "Success: Local and mainnet deployed program hashes match."
        else
            echo "Error: Hash mismatch between local and deployed program."
            exit 1
        fi
    elif [[ "$network_name" == "ottersec" ]]; then
        local program_id=$(solana-keygen pubkey "$PROGRAM_ID_KEYPAIR")
        echo "Verifying deployment on mainnet with remote repository"
        solana-verify verify-from-repo --remote -um --program-id "$program_id" "$REPO_URL" --library-name $PROGRAM_LIB_NAME
    else
        echo "Remote verification is only performed after mainnet deployments."
    fi
}

# Main execution logic
main() {
    source_config "$@"
    local operation=$2

    case "$operation" in
        build)
            build_and_get_idl
            ;;
        deploy_devnet)
            deploy_program "$DEVNET_URL" "devnet"
            upload_idl "devnet"
            ;;
        idl_devnet)
            upload_idl "devnet"
            ;;
        deploy_mainnet)
            deploy_program "$MAINNET_URL" "mainnet"
            upload_idl "mainnet"
            ;;
        idl_mainnet)
            upload_idl "mainnet"
            ;;
        verify_devnet)
            verify_remote "devnet"
            ;;
        verify_mainnet)
            verify_remote "mainnet"
            ;;
        verify_ottersec)
            verify_remote "ottersec"
            ;;
        *)
            echo "Invalid operation: $operation"
            echo "Usage: $0 config_file_path {build|deploy_devnet|deploy_mainnet|verify_remote}"
            exit 1
            ;;
    esac
}

# Execute the script with provided arguments
main "$@"