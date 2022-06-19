# A human-friendly name to identify the node.
MONIKER=
# The name of the key to create.
KEY=$MONIKER
# Must follow the pattern [letters]_[eis]-[epoch]. Mainnet uses smartdoge_420-[epoch]. Testnet uses smartdoge_42069-[epoch].
CHAINID=smartdoge_42069-1
# Determines where created keys are stored. "os" uses the OS keychain, "test" stores in an unencrypted file in the home directory.
KEYRING=os

# Init the node with default config
smartdoged init $MONIKER --chain-id=$CHAINID

# TODO: Retrieve the testnet genesis.json file

# Configure node parameters
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/minimum-gas-prices = "0aphoton"/minimum-gas-prices = "0wei"/g' $HOME/.smartdoged/config/app.toml
    sed -i '' 's/timeout_commit = "5s"/timeout_commit = "3s"/g' $DATA_DIR$i/config/config.toml
else
    sed -i 's/minimum-gas-prices = "0aphoton"/minimum-gas-prices = "0wei"/g' $HOME/.smartdoged/config/app.toml
    sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $DATA_DIR$i/config/config.toml
fi

# Set the chain ID so that it doesn't have to be passed into commands
smartdoged config chain-id $CHAINID

# Set the keyring backend. "os" uses the OS keychain, test  to test, which writes keys to an unencrypted file in ~
smartdoged config keyring-backend $KEYRING

# Create a key
smartdoged keys add $KEY

# Validatate genesis.json
smartdoged validate-genesis

# Run the node
smartdoged start