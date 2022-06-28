package v2_test

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/SmartDoge/cosmos-sdk/testutil"
	sdk "github.com/SmartDoge/cosmos-sdk/types"
	paramtypes "github.com/SmartDoge/cosmos-sdk/x/params/types"

	"github.com/SmartDoge/smartdoge/encoding"

	"github.com/SmartDoge/smartdoge/app"
	v2 "github.com/SmartDoge/smartdoge/x/evm/migrations/v2"
	v2types "github.com/SmartDoge/smartdoge/x/evm/migrations/v2/types"
	"github.com/SmartDoge/smartdoge/x/evm/types"
)

func TestMigrateStore(t *testing.T) {
	encCfg := encoding.MakeConfig(app.ModuleBasics)
	feemarketKey := sdk.NewKVStoreKey(types.StoreKey)
	tFeeMarketKey := sdk.NewTransientStoreKey(fmt.Sprintf("%s_test", types.StoreKey))
	ctx := testutil.DefaultContext(feemarketKey, tFeeMarketKey)
	paramstore := paramtypes.NewSubspace(
		encCfg.Marshaler, encCfg.Amino, feemarketKey, tFeeMarketKey, "evm",
	).WithKeyTable(v2types.ParamKeyTable())

	params := v2types.DefaultParams()
	paramstore.SetParamSet(ctx, &params)

	require.Panics(t, func() {
		var result bool
		paramstore.Get(ctx, types.ParamStoreKeyRejectUnprotectedTx, &result)
	})

	paramstore = paramtypes.NewSubspace(
		encCfg.Marshaler, encCfg.Amino, feemarketKey, tFeeMarketKey, "evm",
	).WithKeyTable(types.ParamKeyTable())
	err := v2.MigrateStore(ctx, &paramstore)
	require.NoError(t, err)

	var result bool
	paramstore.Get(ctx, types.ParamStoreKeyRejectUnprotectedTx, &result)
	require.Equal(t, types.DefaultRejectUnprotectedTx, result)
}
