package ante

import (
	"math/big"

	"github.com/SmartDoge/smartdoge/x/evm/statedb"
	evmtypes "github.com/SmartDoge/smartdoge/x/evm/types"
	feemarkettypes "github.com/SmartDoge/smartdoge/x/feemarket/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
	tx "github.com/cosmos/cosmos-sdk/types/tx"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core"
	"github.com/ethereum/go-ethereum/core/vm"
	"github.com/ethereum/go-ethereum/params"
)

// EVMKeeper defines the expected keeper interface used on the Eth AnteHandler
type EVMKeeper interface {
	statedb.Keeper

	ChainID() *big.Int
	GetParams(ctx sdk.Context) evmtypes.Params
	NewEVM(ctx sdk.Context, msg core.Message, cfg *evmtypes.EVMConfig, tracer vm.EVMLogger, stateDB vm.StateDB) *vm.EVM
	DeductTxCostsFromUserBalance(
		ctx sdk.Context, msgEthTx evmtypes.MsgEthereumTx, txData evmtypes.TxData, denom string, homestead, istanbul, london bool,
	) (sdk.Coins, error)
	GetBaseFee(ctx sdk.Context, ethCfg *params.ChainConfig) *big.Int
	GetBalance(ctx sdk.Context, addr common.Address) *big.Int
	ResetTransientGasUsed(ctx sdk.Context)
	GetTxIndexTransient(ctx sdk.Context) uint64
}

type protoTxProvider interface {
	GetProtoTx() *tx.Tx
}

// FeeMarketKeeper defines the expected keeper interface used on the AnteHandler
type FeeMarketKeeper interface {
	GetParams(ctx sdk.Context) (params feemarkettypes.Params)
	AddTransientGasWanted(ctx sdk.Context, gasWanted uint64) (uint64, error)
}
