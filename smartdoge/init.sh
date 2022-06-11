# TODO: Fill in the variables below

# A human-friendly name to identify the node.
MONIKER=
# The name of the key to create.
KEY=
# Must follow the pattern [letters]_[eis]-[epoch]. SmartDoge uses smartdoge_420-[epoch].
CHAINID=
# Determines where created keys are stored.

# Init the node with default config
smartdoged init $MONIKER --chain-id=$CHAINID

# Change the default currency from aphoton to wei
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="wei"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="wei"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="wei"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="wei"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="wei"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/minimum-gas-prices = "0aphoton"/minimum-gas-prices = "0wei"/g' $HOME/.smartdoged/config/app.toml
else
    sed -i 's/minimum-gas-prices = "0aphoton"/minimum-gas-prices = "0wei"/g' $HOME/.smartdoged/config/app.toml
fi

# Configure inflation parameters
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["inflation_rate_change"]="0.500000000000000000"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["inflation_max"]="0.200000000000000000"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["inflation_min"]="0.010000000000000000"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["goal_bonded"]="0.690000000000000000"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json
cat $HOME/.smartdoged/config/genesis.json | jq '.app_state["mint"]["params"]["blocks_per_year"]="10519200"' > $HOME/.smartdoged/config/tmp_genesis.json && mv $HOME/.smartdoged/config/tmp_genesis.json $HOME/.smartdoged/config/genesis.json

# Set the chain ID so that it doesn't have to be passed into commands
smartdoged config chain-id $CHAINID

# Set the keyring backend to test, which writes keys to an unencrypted file in ~
smartdoged config keyring-backend "test"

# Create a key
smartdoged keys add $KEY

# Add a genesis account with the amount of staked currency and the amount of wallet currency
smartdoged add-genesis-account $(smartdoged keys show $KEY -a) 1000000000000000000000000wei # 1 billion SDOGE

# Create the genesis transaction to stake
smartdoged gentx $KEY 1000000000000000000wei --chain-id $CHAINID # Stake 1 SDOGE

# Collect all genesis transactions into the genesis.json config
smartdoged collect-gentxs

# Validatate genesis.json
smartdoged validate-genesis

# Run the node
smartdoged start