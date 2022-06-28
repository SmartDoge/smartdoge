package encoding

import (
	amino "github.com/SmartDoge/cosmos-sdk/codec"
	"github.com/SmartDoge/cosmos-sdk/codec/types"
	"github.com/SmartDoge/cosmos-sdk/simapp/params"
	"github.com/SmartDoge/cosmos-sdk/types/module"
	"github.com/SmartDoge/cosmos-sdk/x/auth/tx"

	enccodec "github.com/SmartDoge/smartdoge/encoding/codec"
)

// MakeConfig creates an EncodingConfig for testing
func MakeConfig(mb module.BasicManager) params.EncodingConfig {
	cdc := amino.NewLegacyAmino()
	interfaceRegistry := types.NewInterfaceRegistry()
	marshaler := amino.NewProtoCodec(interfaceRegistry)

	encodingConfig := params.EncodingConfig{
		InterfaceRegistry: interfaceRegistry,
		Marshaler:         marshaler,
		TxConfig:          tx.NewTxConfig(marshaler, tx.DefaultSignModes),
		Amino:             cdc,
	}

	enccodec.RegisterLegacyAminoCodec(encodingConfig.Amino)
	mb.RegisterLegacyAminoCodec(encodingConfig.Amino)
	enccodec.RegisterInterfaces(encodingConfig.InterfaceRegistry)
	mb.RegisterInterfaces(encodingConfig.InterfaceRegistry)
	return encodingConfig
}
