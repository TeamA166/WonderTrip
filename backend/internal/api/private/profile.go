package private

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/TeamA166/WonderTrip/internal/core"
	"github.com/TeamA166/WonderTrip/internal/repository"
	"github.com/TeamA166/WonderTrip/internal/utils"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type ProfileHandler struct {
	repo repository.UserRepository
}

func NewProfileHandler(repo repository.UserRepository) *ProfileHandler {
	return &ProfileHandler{repo: repo}
}

func (h *ProfileHandler) GetProfilePhoto(c *fiber.Ctx) error {
	userID, err := utils.ParseUUID(c.Locals("userID"))

	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "User ID not Found"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	user, err := h.repo.GetById(ctx, userID)

	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Internal Server Error"})
	}

	return c.SendFile(user.ProfilePath)
}
func (h *ProfileHandler) GetProfile(c *fiber.Ctx) error {
	// Get User ID from Locals (set by your Auth Middleware)
	userID, err := utils.ParseUUID(c.Locals("userID"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "User ID not found"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	// Reuse your existing Repo method!
	user, err := h.repo.GetById(ctx, userID)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Could not fetch profile"})
	}

	// Map database model to JSON response
	response := core.ProfileResponse{
		ID:      user.ID.String(),
		Email:   user.Email,
		Name:    user.Name,
		Surname: user.Surname,
	}

	return c.Status(http.StatusOK).JSON(response)
}
func (h *ProfileHandler) UpdateProfile(c *fiber.Ctx) error {

	userID, err := utils.ParseUUID(c.Locals("userID"))
	if err != nil {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "Unauthorized"})
	}

	var req core.UpdateProfileRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	user, err := h.repo.GetById(ctx, userID)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "User not found"})
	}

	if req.Name != "" {
		user.Name = req.Name
	}
	if req.Surname != "" {
		user.Surname = req.Surname
	}
	if req.Email != "" {
		user.Email = req.Email
	}

	if err := h.repo.UpdateUser(ctx, user); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to update profile"})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{"message": "Profile updated successfully"})
}

// POST /api/v1/protected/profile-photo
func (h *ProfileHandler) UploadProfilePhoto(c *fiber.Ctx) error {
	// 1. Get User ID
	userID, err := utils.ParseUUID(c.Locals("userID"))
	if err != nil {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "Unauthorized"})
	}

	// 2. Get the file from form-data
	file, err := c.FormFile("photo")
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "No photo uploaded"})
	}

	// 3. Save File to Disk (using same logic as posts)
	// Ensure "uploads/profiles" folder exists!
	const uploadDir = "uploads/profile"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Server error"})
	}

	// Generate unique filename
	filename := fmt.Sprintf("%s_%s", uuid.NewString(), file.Filename)
	savePath := filepath.Join(uploadDir, filename)

	if err := c.SaveFile(file, savePath); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to save file"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	// 4. Update Database
	if err := h.repo.UpdateProfilePhoto(ctx, userID, savePath); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Database update failed"})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{"message": "Photo updated", "path": savePath})
}
func (h *ProfileHandler) ChangePassword(c *fiber.Ctx) error {
	// 1. Get User ID
	userID, err := utils.ParseUUID(c.Locals("userID"))
	if err != nil {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "Unauthorized"})
	}

	// 2. Parse Body
	var req core.ChangePasswordReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid body"})
	}

	if req.NewPassword == "" || len(req.NewPassword) < 6 {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "New password must be at least 6 characters"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	// 3. Fetch User (to get current password hash)
	user, err := h.repo.GetByIdForPassword(ctx, userID)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "User not found"})
	}

	// 4. Verify Old Password
	if !utils.CheckPasswordHash(req.OldPassword, user.PasswordHash) {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "Incorrect old password"})
	}

	// 5. Hash New Password
	newHash, err := utils.HashPassword(req.NewPassword)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to hash password"})
	}

	// 6. Update in DB
	if err := h.repo.UpdatePassword(ctx, userID, newHash); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Database update failed"})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{"message": "Password updated successfully"})
}
