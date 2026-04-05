package metrics

import (
	crand "crypto/rand"
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"time"
)

// PoWChallenge represents a proof-of-work challenge for anti-abuse in open mode.
type PoWChallenge struct {
	Seed       string `json:"seed"`
	Difficulty int    `json:"difficulty"` // number of leading zero bits required
	Expires    int64  `json:"expires"`
}

// PoWSolution represents the client's solution to a PoW challenge.
type PoWSolution struct {
	Seed  string `json:"seed"`
	Nonce uint64 `json:"nonce"`
}

// GeneratePoWChallenge creates a new PoW challenge.
func GeneratePoWChallenge(difficulty int) *PoWChallenge {
	seed := make([]byte, 16)
	crand.Read(seed)

	return &PoWChallenge{
		Seed:       hex.EncodeToString(seed),
		Difficulty: difficulty,
		Expires:    time.Now().Add(5 * time.Minute).Unix(),
	}
}

// VerifyPoW verifies a proof-of-work solution.
func VerifyPoW(challenge *PoWChallenge, solution *PoWSolution) bool {
	if challenge.Seed != solution.Seed {
		return false
	}
	if time.Now().Unix() > challenge.Expires {
		return false
	}

	// Compute SHA-256(seed || nonce)
	data := make([]byte, len(challenge.Seed)+8)
	copy(data, []byte(challenge.Seed))
	binary.BigEndian.PutUint64(data[len(challenge.Seed):], solution.Nonce)

	hash := sha256.Sum256(data)
	return hasLeadingZeros(hash[:], challenge.Difficulty)
}

// hasLeadingZeros checks if a hash has at least n leading zero bits.
func hasLeadingZeros(hash []byte, bits int) bool {
	fullBytes := bits / 8
	remainBits := bits % 8

	for i := 0; i < fullBytes && i < len(hash); i++ {
		if hash[i] != 0 {
			return false
		}
	}

	if remainBits > 0 && fullBytes < len(hash) {
		mask := byte(0xFF << (8 - remainBits))
		if hash[fullBytes]&mask != 0 {
			return false
		}
	}

	return true
}
