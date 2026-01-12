package public

import (
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/TeamA166/WonderTrip/internal/repository"
	"github.com/TeamA166/WonderTrip/internal/utils"
	"github.com/gofiber/fiber/v2"
)

type PasswordResetHandler struct {
	ResetRepo repository.PResetRepository
	UserRepo  repository.UserRepository
}

func NewPasswordResetHandler(rRepo repository.PResetRepository, uRepo repository.UserRepository) *PasswordResetHandler {
	return &PasswordResetHandler{
		ResetRepo: rRepo,
		UserRepo:  uRepo,
	}
}

func (h *PasswordResetHandler) RequestReset(c *fiber.Ctx) error {
	var req struct {
		Email string `json:"email"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid Request"})
	}

	// 2. Check if User Exists
	// We use the UserRepo for this.
	_, err := h.UserRepo.GetByEmail(c.Context(), req.Email)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return c.Status(http.StatusOK).JSON(fiber.Map{
				"message": "If email exist in our database we will sent you a email.",
			})
		}

		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Server Error."})
	}

	// 3. Generate & Hash OTP
	otp, _ := utils.GenerateOTP()
	otpHash, _ := utils.HashCode(otp)
	expiry := time.Now().Add(10 * time.Minute)

	// 4. Save to Repository
	if err := h.ResetRepo.SaveOTP(c.Context(), req.Email, otpHash, expiry); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Kod oluşturulamadı"})
	}

	go func(targetEmail, code string) {
		subject := "WonderTrip - Password Reset"
		body := fmt.Sprintf("Hi,\n\nPassword Reset Code: %s\n\nThis code will be expired after 10 minutes.", code)

		err := utils.SendEmail(targetEmail, subject, body)
		if err != nil {
			// Log the error internally so you can debug later
			fmt.Printf("Email error for %s: %v\n", targetEmail, err)
		}
	}(req.Email, otp)

	// 6. Return Success (Existing code)
	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "If your email exists in our server we will sent you to the code.",
	})
}

// STEP 2: Verify the 6-Digit Code
func (h *PasswordResetHandler) VerifyOTP(c *fiber.Ctx) error {
	var req struct {
		Email string `json:"email"`
		Code  string `json:"code"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request"})
	}

	// 2. Database Checks (Same as before)
	resetData, err := h.ResetRepo.GetByEmail(c.Context(), req.Email)
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid or expired code"})
	}

	if time.Now().After(resetData.ExpiresAt) {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Code has expired"})
	}

	if !utils.VerifyHash(resetData.CodeHash, req.Code) {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Incorrect code"})
	}

	// 3. Generate Token
	token, err := utils.GenerateResetToken(req.Email)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Server error"})
	}

	// 4. [CHANGED] Set HTTP-Only Cookie
	// The frontend cannot read this, but it will be sent back automatically
	cookie := new(fiber.Cookie)
	cookie.Name = "reset_token"
	cookie.Value = token
	cookie.Expires = time.Now().Add(5 * time.Minute) // Match JWT expiry
	cookie.HTTPOnly = true                           // Critical for security (JS/Frontend can't access)
	cookie.Secure = true                             // Send only over HTTPS
	cookie.SameSite = "Lax"                          // CSRF protection

	c.Cookie(cookie)

	// 5. Return Success (No token in body!)
	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Code verified. Please enter your new password.",
	})
}

// STEP 3: Set New Password
func (h *PasswordResetHandler) ResetPassword(c *fiber.Ctx) error {
	var req struct {
		NewPassword string `json:"new_password"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request"})
	}

	tokenString := c.Cookies("reset_token")
	if tokenString == "" {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "Session expired. Please verify code again."})
	}

	// 3. Validate the Token (Same logic)
	email, err := utils.ValidateResetToken(tokenString)
	if err != nil {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "Unauthorized or expired token"})
	}

	// 4. Hash & Update (Same as before)
	newHash, _ := utils.HashCode(req.NewPassword)

	if err := h.ResetRepo.UpdatePassword(c.Context(), email, newHash); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to update password"})
	}

	// 5. Cleanup
	_ = h.ResetRepo.DeleteByEmail(c.Context(), email)

	// Clear the cookie since it's used
	c.ClearCookie("reset_token")

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Password reset successfully",
	})
}
