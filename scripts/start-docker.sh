#!/bin/bash

echo "prepare genesis: Run validate-genesis to ensure everything worked and that the genesis file is setup correctly"
./smartdoged validate-genesis --home /smartdoge

echo "starting smartdoge node $ID in background ..."
./smartdoged start \
--home /smartdoge \
--keyring-backend test

echo "started smartdoge node"
tail -f /dev/null