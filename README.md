# futarchy-deploy-scripts

Check `commands.sh` to see usage in the CLI of the scripts.

Update or create new config files for programs, e.g. `config_autocrat.sh`
Config files contain

- the program's lib name from cargo.toml (not the package name)
- full file path to the program's keypair
- the URL of the repo, used for the osec verification step

Update `deploy.sh` with the custom devnet and mainnet urls if desired. Also the update the `UPGRADE_AUTHORITY` which is a full path directed to the keypair of the program deployer.

Make sure that `deploy.sh` is set as an executable file in your file system using `chmod +x deploy.sh`.

Probably better not to run `commands.sh` in its entirety and instead just copy paste commands into the command line.

**Important** It doesn't matter where `deploy.sh` is stored but when calling e.g. `~/random_folder/deploy.sh config_autocrat.sh build` make sure that you're in the top level directory of the project. E.g. `cd ~/projects/futarchy`.
