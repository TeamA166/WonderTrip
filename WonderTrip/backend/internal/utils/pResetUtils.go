package utils

import (
	"crypto/rand"
	"errors"
	"fmt"
	"math/big"
	"time"

	"github.com/TeamA166/WonderTrip/internal/config"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

// 1. Generate 6-Digit OTP
func GenerateOTP() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1000000))
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%06d", n), nil
}

// 2. Hash OTP (for storage)
func HashCode(code string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(code), 14)
	return string(bytes), err
}

// 3. Verify OTP (compare input vs hash)
func VerifyHash(hashedCode, inputCode string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hashedCode), []byte(inputCode))
	return err == nil
}

// 4. Generate Temporary Reset Token (JWT)
func GenerateResetToken(email string) (string, error) {
	// Load config to get the secret
	cfg, err := config.LoadConfig()
	if err != nil {
		return "", fmt.Errorf("failed to load config: %w", err) // Return error, don't crash
	}

	claims := jwt.MapClaims{
		"email": email,
		"type":  "password_reset", // specific scope
		"exp":   time.Now().Add(5 * time.Minute).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	return token.SignedString([]byte(cfg.Password.JWTSecret))
}

func ValidateResetToken(tokenString string) (string, error) {

	cfg, err := config.LoadConfig()
	if err != nil {
		return "", fmt.Errorf("failed to load config: %w", err)
	}

	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {

		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(cfg.Password.JWTSecret), nil
	})

	if err != nil || !token.Valid {
		return "", errors.New("invalid or expired token")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return "", errors.New("invalid token claims")
	}

	if claims["type"] != "password_reset" {
		return "", errors.New("invalid token type")
	}

	email, ok := claims["email"].(string)
	if !ok {
		return "", errors.New("email claim missing")
	}

	return email, nil
}
