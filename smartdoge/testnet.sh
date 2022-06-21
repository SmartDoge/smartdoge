# A human-friendly name to identify the node.
MONIKER=
# The name of the key to create.
KEY=$MONIKER
# Must follow the pattern [letters]_[eis]-[epoch]. Mainnet uses smartdoge_420-[epoch]. Testnet uses smartdoge_42069-[epoch].
CHAINID=smartdoge_42069-1
# Determines where created keys are stored. "pass" requires configuring a GPG key, installing "pass", and running "pass init <GPG_KEY_ID>".
# Create a GPG key: https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key
KEYRING=pass

# Init the node with default config
smartdoged init $MONIKER --chain-id=$CHAINID

# Set the chain ID so that it doesn't have to be passed into commands
smartdoged config chain-id $CHAINID

# Set the keyring backend. "os" uses the OS keychain, test  to test, which writes keys to an unencrypted file in ~
smartdoged config keyring-backend $KEYRING

# Create a key
smartdoged keys add $KEY

# TODO: Retrieve the testnet genesis.json file

# Configure node parameters
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/minimum-gas-prices = "0aphoton"/minimum-gas-prices = "0wei"/g' $HOME/.smartdoged/config/app.toml
    sed -i '' 's/timeout_commit = "5s"/timeout_commit = "3s"/g' $HOME/.smartdoged/config/config.toml
else
    sed -i 's/minimum-gas-prices = "0aphoton"/minimum-gas-prices = "0wei"/g' $HOME/.smartdoged/config/app.toml
    sed -i 's/timeout_commit = "5s"/timeout_commit = "3s"/g' $HOME/.smartdoged/config/config.toml
fi

# Validatate genesis.json
smartdoged validate-genesis

# TODO: Add "seeds" and "persistent-peers" to config.toml

# Run the node
smartdoged start