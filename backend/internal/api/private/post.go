package private

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/TeamA166/WonderTrip/internal/core"
	"github.com/TeamA166/WonderTrip/internal/repository"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type PostHandler struct {
	repo repository.PostRepository
}

func NewPostHandler(repo repository.PostRepository) *PostHandler {
	return &PostHandler{repo: repo}
}

func (h *PostHandler) Publish(c *fiber.Ctx) error {
	var req core.PostPublishReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Geçersiz istek gövdesi"})
	}

	sanitizePostRequest(&req)

	rating := 0
	if req.Rating != nil {
		rating = *req.Rating
	}

	if err := validatePublishRequest(req, rating); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	userID, err := parseUserID(c.Locals("userID"))
	if err != nil {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "Authentication failed"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	post := core.Post{
		UserID:      userID,
		Title:       req.Title,
		Description: req.Description,
		Rating:      rating,
		Coordinates: req.Coordinates,
		PhotoPath:   req.PhotoPath,
	}

	created, err := h.repo.CreatePost(ctx, post)
	if err != nil {
		fmt.Printf("create post: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Post creation failed"})
	}

	return c.Status(http.StatusCreated).JSON(created)
}

func sanitizePostRequest(req *core.PostPublishReq) {
	req.Title = strings.TrimSpace(req.Title)
	req.Description = strings.TrimSpace(req.Description)
	req.Coordinates = strings.TrimSpace(req.Coordinates)
	req.PhotoPath = strings.TrimSpace(req.PhotoPath)
}

func validatePublishRequest(req core.PostPublishReq, rating int) error {
	if req.Title == "" {
		return errors.New("Title is required")
	}

	if req.Description == "" {
		return errors.New("Description is required")
	}

	if req.Coordinates == "" {
		return errors.New("Coordinates are required")
	}

	if rating < 0 || rating > 5 {
		return errors.New("Rating must be between 0 and 5")
	}

	return nil
}

func parseUserID(value interface{}) (uuid.UUID, error) {
	if value == nil {
		return uuid.UUID{}, errors.New("user id missing")
	}

	userIDStr := fmt.Sprint(value)
	return uuid.Parse(userIDStr)
}
