package private

import (
	"context"
	"net/http"
	"time"

	"github.com/TeamA166/WonderTrip/internal/repository"
	"github.com/TeamA166/WonderTrip/internal/utils"
	"github.com/gofiber/fiber/v2"
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
