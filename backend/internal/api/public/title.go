package public

import (
	"context"
	"database/sql"
	"fmt"
	"net/http"
	"time"

	"github.com/TeamA166/WonderTrip/internal/repository"
	"github.com/gofiber/fiber/v2"
)

type LoadScreenHandler struct {
	Repo repository.LoadScreenRepository
}

func NewLoadScreenHandler(repo repository.LoadScreenRepository) *LoadScreenHandler {
	return &LoadScreenHandler{Repo: repo}
}

func (h *LoadScreenHandler) GetTitle(c *fiber.Ctx) error {

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)

	defer cancel()

	user, err := h.Repo.GetTitle(ctx)

	if err != nil {
		if err == sql.ErrNoRows {
			return c.Status(http.StatusNotFound).JSON(fiber.Map{"error": "No title found in the database"})
		}

		fmt.Printf("Error fetching title: %v\n", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": fmt.Sprintf("Failed to fetch title: %v", err)})
	}

	return c.Status(http.StatusOK).JSON(user)
}
