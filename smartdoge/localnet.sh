# A human-friendly name to identify the node.
MONIKER=localnet
# The name of the key to create.
KEY=$MONIKER
# Must follow the pattern [letters]_[eis]-[epoch]. Mainnet uses smartdoge_420-[epoch]. Testnet uses smartdoge_42069-[epoch].
CHAINID=smartdoge_31337-1
# Determines where created keys are stored. "os" uses the OS keychain, "test" stores in an unencrypted file in the home directory.
KEYRING=test

# Init the node with default config
smartdoged init $MONIKER --chain-id=$CHAINID

# Set the chain ID so that it doesn't have to be passed into commands
smartdoged config chain-id $CHAINID

# Set the keyring backend. "os" uses the OS keychain, test  to test, which writes keys to an unencrypted file in ~
smartdoged config keyring-backend $KEYRING

# Create a key
smartdoged keys add $KEY

# Change the default currency from aphoton to wei
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="wei"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="wei"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="wei"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="wei"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="wei"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json

# Configure inflation parameters
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["inflation_rate_change"]="0.500000000000000000"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["inflation_max"]="0.150000000000000000"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["inflation_min"]="0.010000000000000000"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["goal_bonded"]="0.690000000000000000"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["blocks_per_year"]="10519200"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json

# Configure node parameters
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/minimum-gas-prices = "0aphoton"/minimum-gas-prices = "0wei"/g' $HOME/.smartdoged/config/app.toml
    sed -i '' 's/timeout_commit = "5s"/timeout_commit = "3s"/g' $DATA_DIR$i/config/config.toml
else
    sed -i 's/minimum-gas-prices = "0aphoton"/minimum-gas-prices = "0wei"/g' $HOME/.smartdoged/config/app.toml
    sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $DATA_DIR$i/config/config.toml
fi

# Enable JSON-RPC namespaces
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/api = "eth,net,web3"/api = "eth,txpool,personal,net,debug,web3,miner"/g' $HOME/.smartdoged/config/app.toml
else
    sed -i 's/api = "eth,net,web3"/api = "eth,txpool,personal,net,debug,web3,miner"/g' $HOME/.smartdoged/config/app.toml
fi

# Set the governance quorum to 50%
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["gov"]["tally_params"]["quorum"]="0.500000000000000000"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json

# Add a genesis account with the amount of staked currency and the amount of wallet currency
smartdoged add-genesis-account $(smartdoged keys show $KEY -a) 1000000000000000000000000wei # 1 million SDOGE

# Create the genesis transaction to stake
smartdoged gentx $KEY 100000000000000000000000wei --chain-id $CHAINID # Stake 100k SDOGE

# Collect all genesis transactions into the genesis.json config
smartdoged collect-gentxs

# Validatate genesis.json
smartdoged validate-genesis

# Run the node
smartdoged start