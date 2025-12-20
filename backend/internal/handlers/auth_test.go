package handlers

import (
	"testing"

	"golang.org/x/crypto/bcrypt"
	"pgregory.net/rapid"
)

// **Feature: daily-planner-app, Property 1: Password hashing integrity**
func TestPasswordHashingIntegrity(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		password := rapid.StringMatching(`[a-zA-Z0-9]{6,20}`).Draw(t, "password")

		hashed, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
		if err != nil {
			t.Fatalf("Failed to hash password: %v", err)
		}

		// Property: hashed password is not equal to original
		if string(hashed) == password {
			t.Fatal("Hashed password should not equal original password")
		}

		// Property: hashed password can be verified
		err = bcrypt.CompareHashAndPassword(hashed, []byte(password))
		if err != nil {
			t.Fatalf("Failed to verify password: %v", err)
		}
	})
}

// **Feature: daily-planner-app, Property 3: Invalid credentials rejection**
func TestInvalidCredentialsRejection(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		correctPassword := rapid.StringMatching(`[a-zA-Z0-9]{6,20}`).Draw(t, "correctPassword")
		wrongPassword := rapid.StringMatching(`[a-zA-Z0-9]{6,20}`).Draw(t, "wrongPassword")

		if correctPassword == wrongPassword {
			return // Skip if passwords happen to match
		}

		hashed, err := bcrypt.GenerateFromPassword([]byte(correctPassword), bcrypt.DefaultCost)
		if err != nil {
			t.Fatalf("Failed to hash password: %v", err)
		}

		// Property: wrong password should fail verification
		err = bcrypt.CompareHashAndPassword(hashed, []byte(wrongPassword))
		if err == nil {
			t.Fatal("Wrong password should not verify successfully")
		}
	})
}
