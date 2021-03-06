package v2

import (
	sdk "github.com/SmartDoge/cosmos-sdk/types"
	paramtypes "github.com/SmartDoge/cosmos-sdk/x/params/types"
	"github.com/SmartDoge/smartdoge/x/evm/types"
)

// MigrateStore add the default RejectUnprotected parameter.
func MigrateStore(ctx sdk.Context, paramstore *paramtypes.Subspace) error {
	if !paramstore.HasKeyTable() {
		ps := paramstore.WithKeyTable(types.ParamKeyTable())
		paramstore = &ps
	}

	// add RejectUnprotected
	paramstore.Set(ctx, types.ParamStoreKeyRejectUnprotectedTx, types.DefaultParams().RejectUnprotectedTx)
	return nil
}
