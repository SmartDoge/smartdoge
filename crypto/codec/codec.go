package codec

import (
	codectypes "github.com/SmartDoge/cosmos-sdk/codec/types"
	cryptotypes "github.com/SmartDoge/cosmos-sdk/crypto/types"

	"github.com/SmartDoge/smartdoge/crypto/ethsecp256k1"
)

// RegisterInterfaces register the SmartDoge key concrete types.
func RegisterInterfaces(registry codectypes.InterfaceRegistry) {
	registry.RegisterImplementations((*cryptotypes.PubKey)(nil), &ethsecp256k1.PubKey{})
}
