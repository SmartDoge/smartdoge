# SmartDoge

## Build

    make install

## Reset a node

The following script resets a node but retains its validator keys in `priv_validator.json` and node config in `config.toml`.
This can be run to start a fresh local test environment, and must be run when performing a breaking node upgrade.

```bash
rm $HOME/.ethermintd/config/addrbook.json $HOME/.ethermintd/config/genesis.json
ethermintd tendermint unsafe-reset-all --home $HOME/.ethermintd
```

**IMPORTANT: Never run two nodes with the same validator keys. This will result in double-signing and permanent jailing of
the validator.**

## Run a single-node testnet

```bash
# A human-friendly name to identify the node
MONIKER=testnet-main

# The name of the key to create
KEY=validator

# Must follow the pattern [letters]_[eis]-[epoch]
CHAINID=smartdoge_420-1

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
```

## Query the testnet

### Ethereum JSON-RPC

Exposed on port 8545.

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' -H "Content-Type: application/json" [hostname]:8545
```

### Ethereum WebSocket

Exposed on port 8546.

In a Chrome DevTools instance:

```js
ws = new WebSocket("ws://[hostname]:8546");
ws.onmessage = console.log;
ws.send(JSON.stringify({"id": 1, "method": "eth_subscribe", "params": ["newHeads", {}]}));
```

## Validate the testnet

1. Initialise your node following the steps above until and including the add key step.

2. Replace your local genesis.json file with the one on the testnet server

```bash
scp smartdoge-testnet:~/.ethermintd/config/genesis.json ~/.ethermintd/config/genesis.json
```

3. Validate the genesis.json file

```bash
ethermintd validate-genesis
```

3. Get the node ID of a trusted peer on the testnet (e.g. the main testnet node). You can get a node ID by running the following
command:

```bash
ethermintd tendermint show-node-id
```

4. Set the persistent_peers value in ~/.ethermintd/config/config.toml to `<testnet node ID>@<ip>:<port (typically 26656)>`.
More than one persistent peer can be set by comma-separating the values. (c.f. https://docs.tendermint.com/master/spec/p2p/config.html).
At this point you could start the node and it would run against the testnet without validating.

```bash
TARGETNODEID=e6f48494c718fb5287f7ca78caede9aeb172e8a9
TARGETIP=20.229.92.230
TARGETPORT=26656

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/persistent_peers = \"\"/persistent_peers = \"$TARGETNODEID@$TARGETIP:$TARGETPORT\"/g" $HOME/.ethermintd/config/config.toml
else
    sed -i "s/persistent_peers = \"\"/persistent_peers = \"$TARGETNODEID@$TARGETIP:$TARGETPORT\"/g" $HOME/.ethermintd/config/config.toml
fi
```

5. Submit a create validator transaction

```bash
MONIKER=testnet-local
CHAINID=smartdoge_420-1
KEY=validator

ethermintd tx staking create-validator \
    --amount=1000000wei \
    --pubkey=$(ethermintd tendermint show-validator) \
    --moniker=$MONIKER \
    --chain-id=$CHAINID \
    --commission-rate="0.05" \
    --commission-max-rate="0.10" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="1000000" \
    --from=$(ethermintd keys show $KEY -a) # a bug prevents us from using the key name
```

6. Confirm your validation status by checking if the following command returns anything.

```bash
ethermintd query tendermint-validator-set | grep "$(ethermintd tendermint show-address)"
```

## Collect validation rewards

```bash
# $KEY      - the key name

# Optionally set the address to which you want rewards to be withdrawn
# ethermintd tx distribution set-withdraw-addr $ADDRESS

# Withdraw all rewards validated/delegated with a key
ethermintd tx distribution withdraw-all-rewards --from $(ethermintd keys show $KEY -a)
```

## Delegate to a validator

```bash
# $ADDRESS  - the validator address (starting with "ethmvaloper1")
# $AMOUNT   - the amount to unbond in wei
# $KEY      - the key name

# Find the operator address of the validator to which you wish to delegate
ethermintd query staking validators
$ADDRESS = # TODO: set to address chosen from the output of the previous query
ethermintd tx staking delegate $ADDRESS $AMOUNT"wei" --from $KEY
```

## Determine how much you have delegated

```bash
# $KEY      - the key name
ethermintd query staking delegations $(ethermintd keys show $KEY -a)
```

## Undelegate from a validator

```bash
# $ADDRESS  - the validator address (starting with "ethmvaloper1")
# $AMOUNT   - the amount to unbond in wei
# $KEY      - the key name
ethermintd tx staking unbond $ADDRESS $AMOUNT"wei" --from $KEY
```

## Query unbonding status from a delegator

```bash
# $ADDRESS  - the delegator address (starting with "ethm1")
ethermintd query staking unbonding-delegations $ADDRESS
```

## Unjail a validator

For unjailing to succeed the validator must have bonded at least its configured minimum self delegation amount. To determine
these values, run `ethermintd query staking validators` and find the validator in the list.

```bash
# $KEY      - the key name
ethermintd tx slashing unjail --from $KEY
```