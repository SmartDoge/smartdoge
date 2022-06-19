# SmartDoge

## Build

```bash
make install
```

## Completely reset the environment

```bash
rm -rf ~/.smartdoged/
```

## Reset a node

The following script resets a node but retains its validator keys in `priv_validator.json` and node config in `config.toml`.
This can be run to start a fresh local test environment, and must be run when performing a breaking node upgrade.

```bash
rm $HOME/.smartdoged/config/addrbook.json $HOME/.smartdoged/config/genesis.json
smartdoged tendermint unsafe-reset-all --home $HOME/.smartdoged
```

**IMPORTANT: Never run two nodes with the same validator keys. This will result in double-signing and permanent jailing of
the validator.**

## Run a single-node localnet

```bash
./smartdoge/init.sh
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
scp smartdoge-testnet:~/.smartdoged/config/genesis.json ~/.smartdoged/config/genesis.json
```

3. Validate the genesis.json file

```bash
smartdoged validate-genesis
```

3. Get the node ID of a trusted peer on the testnet (e.g. the main testnet node). You can get a node ID by running the following
command:

```bash
smartdoged tendermint show-node-id
```

4. Set the persistent_peers value in ~/.smartdoged/config/config.toml to `<testnet node ID>@<ip>:<port (typically 26656)>`.
More than one persistent peer can be set by comma-separating the values. (c.f. https://docs.tendermint.com/master/spec/p2p/config.html).
At this point you could start the node and it would run against the testnet without validating.

```bash
TARGETNODEID=e6f48494c718fb5287f7ca78caede9aeb172e8a9
TARGETIP=20.229.92.230
TARGETPORT=26656

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/persistent_peers = \"\"/persistent_peers = \"$TARGETNODEID@$TARGETIP:$TARGETPORT\"/g" $HOME/.smartdoged/config/config.toml
else
    sed -i "s/persistent_peers = \"\"/persistent_peers = \"$TARGETNODEID@$TARGETIP:$TARGETPORT\"/g" $HOME/.smartdoged/config/config.toml
fi
```

5. Submit a create validator transaction

```bash
MONIKER=testnet-local
CHAINID=smartdoge_420-1
KEY=validator

smartdoged tx staking create-validator \
    --amount=1000000wei \
    --pubkey=$(smartdoged tendermint show-validator) \
    --moniker=$MONIKER \
    --chain-id=$CHAINID \
    --commission-rate="0.05" \
    --commission-max-rate="0.10" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="1000000" \
    --from=$(smartdoged keys show $KEY -a) # a bug prevents us from using the key name
```

6. Confirm your validation status by checking if the following command returns anything.

```bash
smartdoged query tendermint-validator-set | grep "$(smartdoged tendermint show-address)"
```

## Collect validation rewards

```bash
# $KEY      - the key name

# Optionally set the address to which you want rewards to be withdrawn
# smartdoged tx distribution set-withdraw-addr $ADDRESS

# Withdraw all rewards validated/delegated with a key
smartdoged tx distribution withdraw-all-rewards --from $(smartdoged keys show $KEY -a)
```

## Delegate to a validator

```bash
# $ADDRESS  - the validator address (starting with "ethmvaloper1")
# $AMOUNT   - the amount to unbond in wei
# $KEY      - the key name

# Find the operator address of the validator to which you wish to delegate
smartdoged query staking validators
$ADDRESS = # TODO: set to address chosen from the output of the previous query
smartdoged tx staking delegate $ADDRESS $AMOUNT"wei" --from $KEY
```

## Determine how much you have delegated

```bash
# $KEY      - the key name
smartdoged query staking delegations $(smartdoged keys show $KEY -a)
```

## Undelegate from a validator

```bash
# $ADDRESS  - the validator address (starting with "ethmvaloper1")
# $AMOUNT   - the amount to unbond in wei
# $KEY      - the key name
smartdoged tx staking unbond $ADDRESS $AMOUNT"wei" --from $KEY
```

## Query unbonding status from a delegator

```bash
# $ADDRESS  - the delegator address (starting with "ethm1")
smartdoged query staking unbonding-delegations $ADDRESS
```

## Unjail a validator

For unjailing to succeed the validator must have bonded at least its configured minimum self delegation amount. To determine
these values, run `smartdoged query staking validators` and find the validator in the list.

```bash
# $KEY      - the key name
smartdoged tx slashing unjail --from $KEY
```