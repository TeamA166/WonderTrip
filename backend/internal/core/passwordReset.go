package core

import "time"

type PasswordReset struct {
	Email     string    `db:"email"`
	CodeHash  string    `db:"code_hash"`
	ExpiresAt time.Time `db:"expires_at"`
}

type ForgotPasswordRequest struct {
	Email string `json:"email"`
}

type VerifyOTPRequest struct {
	Email string `json:"email"`
	Code  string `json:"code"`
}

type ResetPasswordRequest struct {
	ResetToken  string `json:"reset_token"`
	NewPassword string `json:"new_password"`
}
