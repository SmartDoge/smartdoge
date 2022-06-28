package codec

import (
	"github.com/SmartDoge/cosmos-sdk/codec"
	codectypes "github.com/SmartDoge/cosmos-sdk/codec/types"
	"github.com/SmartDoge/cosmos-sdk/std"
	sdk "github.com/SmartDoge/cosmos-sdk/types"

	cryptocodec "github.com/SmartDoge/smartdoge/crypto/codec"
	smartdoge "github.com/SmartDoge/smartdoge/types"
)

// RegisterLegacyAminoCodec registers Interfaces from types, crypto, and SDK std.
func RegisterLegacyAminoCodec(cdc *codec.LegacyAmino) {
	sdk.RegisterLegacyAminoCodec(cdc)
	cryptocodec.RegisterCrypto(cdc)
	codec.RegisterEvidences(cdc)
}

// RegisterInterfaces registers Interfaces from types, crypto, and SDK std.
func RegisterInterfaces(interfaceRegistry codectypes.InterfaceRegistry) {
	std.RegisterInterfaces(interfaceRegistry)
	cryptocodec.RegisterInterfaces(interfaceRegistry)
	smartdoge.RegisterInterfaces(interfaceRegistry)
}
