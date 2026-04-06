package auth

import (
	"crypto/ed25519"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"strconv"
	"time"
)

const (
	challengePrefix = "pulse-auth:"
	challengeMaxAge = 60 // seconds
	nonceBytes      = 32
)

// Challenge represents an auth challenge sent to a connecting client.
type Challenge struct {
	Nonce     string `json:"nonce"`
	Timestamp int64  `json:"timestamp"`
}

// GenerateChallenge creates a new challenge with a random nonce and current timestamp.
func GenerateChallenge() (*Challenge, error) {
	nonce := make([]byte, nonceBytes)
	if _, err := rand.Read(nonce); err != nil {
		return nil, fmt.Errorf("failed to generate nonce: %w", err)
	}
	return &Challenge{
		Nonce:     hex.EncodeToString(nonce),
		Timestamp: time.Now().Unix(),
	}, nil
}

// VerifyResponse verifies an Ed25519 signature over the challenge payload.
// The client must sign the string "pulse-auth:<nonce>:<timestamp>".
func VerifyResponse(pubkeyHex string, signatureHex string, nonce string, timestamp int64) bool {
	age := time.Now().Unix() - timestamp
	if age < 0 || age > challengeMaxAge {
		return false
	}

	pubkeyBytes, err := hex.DecodeString(pubkeyHex)
	if err != nil || len(pubkeyBytes) != ed25519.PublicKeySize {
		return false
	}

	sigBytes, err := hex.DecodeString(signatureHex)
	if err != nil || len(sigBytes) != ed25519.SignatureSize {
		return false
	}

	message := challengePrefix + nonce + ":" + strconv.FormatInt(timestamp, 10)
	return ed25519.Verify(ed25519.PublicKey(pubkeyBytes), []byte(message), sigBytes)
}

// SignChallenge signs a challenge for testing purposes.
func SignChallenge(privateKey ed25519.PrivateKey, nonce string, timestamp int64) string {
	message := challengePrefix + nonce + ":" + strconv.FormatInt(timestamp, 10)
	sig := ed25519.Sign(privateKey, []byte(message))
	return hex.EncodeToString(sig)
}
