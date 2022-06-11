# TODO: Fill in the variables below

# A human-friendly name to identify the node.
MONIKER=
# The name of the key to create.
KEY=
# Must follow the pattern [letters]_[eis]-[epoch]. SmartDoge uses smartdoge_420-[epoch].
CHAINID=
# Determines where created keys are stored.

# Init the node with default config
ethermintd init $MONIKER --chain-id=$CHAINID

# Change the default currency from aphoton to wei
cat $HOME/.ethermintd/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="wei"' > $HOME/.ethermintd/config/tmp_genesis.json && mv $HOME/.ethermintd/config/tmp_genesis.json $HOME/.ethermintd/config/genesis.json
cat $HOME/.ethermintd/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="wei"' > $HOME/.ethermintd/config/tmp_genesis.json && mv $HOME/.ethermintd/config/tmp_genesis.json $HOME/.ethermintd/config/genesis.json
cat $HOME/.ethermintd/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="wei"' > $HOME/.ethermintd/config/tmp_genesis.json && mv $HOME/.ethermintd/config/tmp_genesis.json $HOME/.ethermintd/config/genesis.json
cat $HOME/.ethermintd/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="wei"' > $HOME/.ethermintd/config/tmp_genesis.json && mv $HOME/.ethermintd/config/tmp_genesis.json $HOME/.ethermintd/config/genesis.json
cat $HOME/.ethermintd/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="wei"' > $HOME/.ethermintd/config/tmp_genesis.json && mv $HOME/.ethermintd/config/tmp_genesis.json $HOME/.ethermintd/config/genesis.json
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/minimum-gas-prices = "0aphoton"/minimum-gas-prices = "0wei"/g' $HOME/.ethermintd/config/app.toml
else
    sed -i 's/minimum-gas-prices = "0aphoton"/minimum-gas-prices = "0wei"/g' $HOME/.ethermintd/config/app.toml
fi

# Configure inflation parameters
cat $HOME/.ethermintd/config/genesis.json | jq '.app_state["mint"]["params"]["inflation_rate_change"]="0.500000000000000000"' > $HOME/.ethermintd/config/tmp_genesis.json && mv $HOME/.ethermintd/config/tmp_genesis.json $HOME/.ethermintd/config/genesis.json
cat $HOME/.ethermintd/config/genesis.json | jq '.app_state["mint"]["params"]["inflation_max"]="0.200000000000000000"' > $HOME/.ethermintd/config/tmp_genesis.json && mv $HOME/.ethermintd/config/tmp_genesis.json $HOME/.ethermintd/config/genesis.json
cat $HOME/.ethermintd/config/genesis.json | jq '.app_state["mint"]["params"]["inflation_min"]="0.010000000000000000"' > $HOME/.ethermintd/config/tmp_genesis.json && mv $HOME/.ethermintd/config/tmp_genesis.json $HOME/.ethermintd/config/genesis.json
cat $HOME/.ethermintd/config/genesis.json | jq '.app_state["mint"]["params"]["goal_bonded"]="0.690000000000000000"' > $HOME/.ethermintd/config/tmp_genesis.json && mv $HOME/.ethermintd/config/tmp_genesis.json $HOME/.ethermintd/config/genesis.json
cat $HOME/.ethermintd/config/genesis.json | jq '.app_state["mint"]["params"]["blocks_per_year"]="10519200"' > $HOME/.ethermintd/config/tmp_genesis.json && mv $HOME/.ethermintd/config/tmp_genesis.json $HOME/.ethermintd/config/genesis.json

# Set the chain ID so that it doesn't have to be passed into commands
ethermintd config chain-id $CHAINID

# Set the keyring backend to test, which writes keys to an unencrypted file in ~
ethermintd config keyring-backend "test"

# Create a key
ethermintd keys add $KEY

# Add a genesis account with the amount of staked currency and the amount of wallet currency
ethermintd add-genesis-account $(ethermintd keys show $KEY -a) 1000000000000000000000000wei # 1 billion SDOGE

# Create the genesis transaction to stake
ethermintd gentx $KEY 1000000000000000000wei --chain-id $CHAINID # Stake 1 SDOGE

# Collect all genesis transactions into the genesis.json config
ethermintd collect-gentxs

# Validatate genesis.json
ethermintd validate-genesis

# Run the node
ethermintd start