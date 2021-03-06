package main

import (
	"os"

	"github.com/SmartDoge/cosmos-sdk/server"
	svrcmd "github.com/SmartDoge/cosmos-sdk/server/cmd"
	sdk "github.com/SmartDoge/cosmos-sdk/types"

	"github.com/SmartDoge/smartdoge/app"
	cmdcfg "github.com/SmartDoge/smartdoge/cmd/config"
)

func main() {
	setupConfig()
	cmdcfg.RegisterDenoms()

	rootCmd, _ := NewRootCmd()

	if err := svrcmd.Execute(rootCmd, app.DefaultNodeHome); err != nil {
		switch e := err.(type) {
		case server.ErrorCode:
			os.Exit(e.Code)

		default:
			os.Exit(1)
		}
	}
}

func setupConfig() {
	// set the address prefixes
	config := sdk.GetConfig()
	cmdcfg.SetBech32Prefixes(config)
	cmdcfg.SetBip44CoinType(config)
	config.Seal()
}
