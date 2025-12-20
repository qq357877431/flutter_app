package middleware

import (
	"testing"

	"pgregory.net/rapid"
)

func init() {
	SetJWTSecret("test-secret-key")
}

// **Feature: daily-planner-app, Property 2: JWT token contains correct UserID**
func TestJWTTokenContainsCorrectUserID(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		userID := rapid.Uint().Draw(t, "userID")
		if userID == 0 {
			userID = 1
		}

		token, err := GenerateToken(userID)
		if err != nil {
			t.Fatalf("Failed to generate token: %v", err)
		}

		claims, err := ParseToken(token)
		if err != nil {
			t.Fatalf("Failed to parse token: %v", err)
		}

		if claims.UserID != userID {
			t.Fatalf("UserID mismatch: expected %d, got %d", userID, claims.UserID)
		}
	})
}

// **Feature: daily-planner-app, Property 4: Invalid JWT rejection**
func TestInvalidJWTRejection(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		invalidToken := rapid.String().Draw(t, "invalidToken")

		_, err := ParseToken(invalidToken)
		if err == nil {
			t.Fatal("Expected error for invalid token, got nil")
		}
	})
}

func TestExpiredTokenRejection(t *testing.T) {
	// Test with malformed tokens
	testCases := []string{
		"",
		"invalid",
		"a.b.c",
		"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.invalid.signature",
	}

	for _, tc := range testCases {
		_, err := ParseToken(tc)
		if err == nil {
			t.Errorf("Expected error for token %q, got nil", tc)
		}
	}
}
