# Modify to take out stuff like deploying to mainnet or devnet where needed
./deploy.sh config_vault.sh build
./deploy.sh config_vault.sh deploy_devnet
./deploy.sh config_vault.sh idl_devnet
./deploy.sh config_vault.sh verify_devnet
./deploy.sh config_vault.sh deploy_mainnet
./deploy.sh config_vault.sh verify_mainnet
./deploy.sh config_vault.sh verify_ottersec

./deploy.sh config_migrator.sh build
./deploy.sh config_migrator.sh deploy_devnet
./deploy.sh config_migrator.sh idl_devnet
./deploy.sh config_migrator.sh verify_devnet
./deploy.sh config_migrator.sh deploy_mainnet
./deploy.sh config_migrator.sh verify_mainnet
./deploy.sh config_migrator.sh verify_ottersec

./deploy.sh config_autocrat.sh build
./deploy.sh config_autocrat.sh deploy_devnet
./deploy.sh config_autocrat.sh idl_devnet
./deploy.sh config_autocrat.sh verify_devnet
./deploy.sh config_autocrat.sh deploy_mainnet
./deploy.sh config_autocrat.sh verify_mainnet
./deploy.sh config_autocrat.sh idl_mainnet
./deploy.sh config_autocrat.sh verify_ottersec

cd /root/projects/openbook-twap
/root/projects/futarchy/deploy.sh /root/projects/futarchy/config_twap.sh build
/root/projects/futarchy/deploy.sh /root/projects/futarchy/config_twap.sh deploy_devnet
/root/projects/futarchy/deploy.sh /root/projects/futarchy/config_twap.sh verify_devnet
/root/projects/futarchy/deploy.sh /root/projects/futarchy/config_twap.sh idl_devnet
/root/projects/futarchy/deploy.sh /root/projects/futarchy/config_twap.sh deploy_mainnet
/root/projects/futarchy/deploy.sh /root/projects/futarchy/config_twap.sh verify_mainnet
/root/projects/futarchy/deploy.sh /root/projects/futarchy/config_twap.sh idl_mainnet
/root/projects/futarchy/deploy.sh /root/projects/futarchy/config_twap.sh verify_ottersec

# Double check all addresses
# metaRK9dUBnrAdZN6uUDKvxBVKW5pyCbPVmLtUZwtBp
# MigRDW6uxyNMDBD8fX2njCRyJC4YZk2Rx9pDUZiAESt
# vAuLTQjV5AZx5f3UgE75wcnkxnQowWxThn1hGjfCVwP
# twAP5sArq2vDS1mZCT7f4qRLwzTfHvf5Ay5R5Q5df1m
# The new auth
# BC1jThSN7Cgy5LfBZdCKCfMnhKcq155gMjhd9HPWzsCN


# have to transfer over the auth
# Autocrat
solana program set-upgrade-authority metaRK9dUBnrAdZN6uUDKvxBVKW5pyCbPVmLtUZwtBp --new-upgrade-authority BC1jThSN7Cgy5LfBZdCKCfMnhKcq155gMjhd9HPWzsCN --skip-new-upgrade-authority-signer-check
# migrator
solana program set-upgrade-authority MigRDW6uxyNMDBD8fX2njCRyJC4YZk2Rx9pDUZiAESt --new-upgrade-authority BC1jThSN7Cgy5LfBZdCKCfMnhKcq155gMjhd9HPWzsCN --skip-new-upgrade-authority-signer-check
# vault
solana program set-upgrade-authority vAuLTQjV5AZx5f3UgE75wcnkxnQowWxThn1hGjfCVwP --new-upgrade-authority BC1jThSN7Cgy5LfBZdCKCfMnhKcq155gMjhd9HPWzsCN --skip-new-upgrade-authority-signer-check
# twap
solana program set-upgrade-authority twAP5sArq2vDS1mZCT7f4qRLwzTfHvf5Ay5R5Q5df1m --new-upgrade-authority BC1jThSN7Cgy5LfBZdCKCfMnhKcq155gMjhd9HPWzsCN --skip-new-upgrade-authority-signer-check



# Temp script needed for deploying the IDL

#!/bin/bash

# Define the command to be executed.
COMMAND="anchor idl upgrade -f target/idl/openbook_twap.json twAP5sArq2vDS1mZCT7f4qRLwzTfHvf5Ay5R5Q5df1m --provider.cluster mainnet --provider.wallet /root/.config/solana/FutaAyNb3x9HUn1EQNueZJhfy6KCNtAwztvBctoK6JnX.json"

# Initial attempt count.
attempt=1

# Maximum number of attempts to avoid infinite loop.
max_attempts=50

# Delay between attempts in seconds.
delay_between_attempts=1

while true; do
    echo "Attempt #$attempt: Executing command..."
    if eval "$COMMAND"; then
        echo "Command executed successfully on attempt #$attempt."
        break
    else
        echo "Command failed on attempt #$attempt."
        ((attempt++))
        if [ $attempt -gt $max_attempts ]; then
            echo "Maximum number of attempts ($max_attempts) reached. Exiting."
            exit 1
        fi
        echo "Waiting $delay_between_attempts seconds before retrying..."
        sleep $delay_between_attempts
    fi
done
