package main_test

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/SmartDoge/cosmos-sdk/client/flags"
	svrcmd "github.com/SmartDoge/cosmos-sdk/server/cmd"
	"github.com/SmartDoge/cosmos-sdk/x/genutil/client/cli"

	"github.com/SmartDoge/smartdoge/app"
	smartdoged "github.com/SmartDoge/smartdoge/cmd/smartdoged"
)

func TestInitCmd(t *testing.T) {
	rootCmd, _ := smartdoged.NewRootCmd()
	rootCmd.SetArgs([]string{
		"init",          // Test the init cmd
		"smartdogetest", // Moniker
		fmt.Sprintf("--%s=%s", cli.FlagOverwrite, "true"), // Overwrite genesis.json, in case it already exists
		fmt.Sprintf("--%s=%s", flags.FlagChainID, "smartdoge_9000-1"),
	})

	err := svrcmd.Execute(rootCmd, app.DefaultNodeHome)
	require.NoError(t, err)
}
