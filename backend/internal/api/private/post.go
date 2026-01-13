package private

import (
	"context"
	"errors"
	"fmt"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
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
	req.Title = c.FormValue("title")
	req.Description = c.FormValue("description")
	req.Coordinates = c.FormValue("coordinates")

	rating, ratingProvided, err := parseRating(c.FormValue("rating"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid rating value"})
	}
	if ratingProvided {
		req.Rating = &rating
	}

	sanitizePostRequest(&req)

	if err := validatePublishRequest(req, rating); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	file, err := c.FormFile("photo")
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Photo file is required"})
	}

	userID, err := parseUserID(c.Locals("userID"))
	if err != nil {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "Authentication failed"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	photoPath, err := savePhoto(c, file)
	if err != nil {
		fmt.Printf("save photo: %v", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Photo could not be saved"})
	}

	if req.Rating == nil {
		req.Rating = &rating
	}

	if req.Rating != nil {
		rating = *req.Rating
	}

	post := core.Post{
		UserID:      userID,
		Title:       req.Title,
		Description: req.Description,
		Rating:      rating,
		Coordinates: req.Coordinates,
		PhotoPath:   photoPath,
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

func parseRating(value string) (int, bool, error) {
	if value == "" {
		return 0, false, nil
	}

	parsed, err := strconv.Atoi(value)
	if err != nil {
		return 0, false, err
	}

	return parsed, true, nil
}

func parseUserID(value interface{}) (uuid.UUID, error) {
	if value == nil {
		return uuid.UUID{}, errors.New("user id missing")
	}

	userIDStr := fmt.Sprint(value)
	return uuid.Parse(userIDStr)
}

func savePhoto(c *fiber.Ctx, file *multipart.FileHeader) (string, error) {
	const uploadDir = "uploads/photos"

	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		return "", fmt.Errorf("ensure upload dir: %w", err)
	}

	filename := fmt.Sprintf("%s_%s", uuid.NewString(), file.Filename)
	savePath := filepath.Join(uploadDir, filename)

	if err := c.SaveFile(file, savePath); err != nil {
		return "", fmt.Errorf("save file: %w", err)
	}

	return savePath, nil
}
func (h *PostHandler) GetVerifiedPosts(c *fiber.Ctx) error {
	return h.fetchPostsWithPagination(c, true)
}

func (h *PostHandler) GetUnverifiedPosts(c *fiber.Ctx) error {
	return h.fetchPostsWithPagination(c, false)
}

func (h *PostHandler) fetchPostsWithPagination(c *fiber.Ctx, wantVerified bool) error {

	page, err := strconv.Atoi(c.Query("page", "1"))
	if err != nil || page < 1 {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid page number"})
	}

	const limit = 5
	offset := (page - 1) * limit

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	posts, err := h.repo.GetPostsByStatus(ctx, wantVerified, limit, offset)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Could not fetch posts"})
	}

	return c.Status(http.StatusOK).JSON(posts)
}

func (h *PostHandler) GetPostPhoto(c *fiber.Ctx) error {

	filename := c.Params("filename")

	if filename == "" || containsDotDot(filename) {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid filename"})
	}

	const uploadDir = "uploads/photos"
	filePath := fmt.Sprintf("%s/%s", uploadDir, filename)

	return c.SendFile(filePath)
}

func containsDotDot(v string) bool {
	for i := 0; i < len(v)-1; i++ {
		if v[i] == '.' && v[i+1] == '.' {
			return true
		}
	}
	return false
}

// GET /api/v1/protected/posts/me
func (h *PostHandler) GetMyPosts(c *fiber.Ctx) error {
	userID, err := parseUserID(c.Locals("userID"))
	if err != nil {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "Unauthorized"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	posts, err := h.repo.GetPostsByUserID(ctx, userID)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch posts"})
	}

	return c.Status(http.StatusOK).JSON(posts)
}

// DELETE /api/v1/protected/posts/:id
func (h *PostHandler) DeletePost(c *fiber.Ctx) error {
	userID, err := parseUserID(c.Locals("userID"))
	if err != nil {
		return c.SendStatus(http.StatusUnauthorized)
	}

	postID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid ID"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	if err := h.repo.DeletePost(ctx, postID, userID); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.SendStatus(http.StatusOK)
}

// PUT /api/v1/protected/posts/:id
func (h *PostHandler) UpdatePost(c *fiber.Ctx) error {
	// 1. Auth Check
	userID, err := parseUserID(c.Locals("userID"))
	if err != nil {
		return c.SendStatus(http.StatusUnauthorized)
	}

	postID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid Post ID"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	// 2. Fetch Existing Post (To get the OLD photo path in case user didn't change it)
	oldPost, err := h.repo.GetPostByID(ctx, postID)
	if err != nil {
		return c.Status(http.StatusNotFound).JSON(fiber.Map{"error": "Post not found"})
	}

	// 3. Security Check: Does user own this post?
	if oldPost.UserID != userID {
		return c.Status(http.StatusForbidden).JSON(fiber.Map{"error": "You do not own this post"})
	}

	// 4. Parse Form Data (Manual parsing because of File Upload)
	title := c.FormValue("title")
	description := c.FormValue("description")
	coordinates := c.FormValue("coordinates")
	ratingStr := c.FormValue("rating")

	// Update fields if provided
	if title != "" {
		oldPost.Title = title
	}
	if description != "" {
		oldPost.Description = description
	}
	if coordinates != "" {
		oldPost.Coordinates = coordinates
	}

	if ratingStr != "" {
		rating, _ := strconv.Atoi(ratingStr)
		if rating >= 1 && rating <= 5 {
			oldPost.Rating = rating
		}
	}

	// 5. Handle Optional Photo Upload
	file, err := c.FormFile("photo")
	if err == nil {
		// ✅ User sent a new file! Save it.
		// (Optional: You could delete existing oldPost.PhotoPath here to save disk space)

		newPath, err := savePhoto(c, file) // Reusing your existing savePhoto helper function
		if err != nil {
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to save new photo"})
		}
		oldPost.PhotoPath = newPath
	}
	// If err != nil, it means no new file was sent. We keep oldPost.PhotoPath.

	// 6. Save Updates (Repository forces verified = false)
	if err := h.repo.UpdatePost(ctx, oldPost); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to update post"})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Post updated successfully",
		"post":    oldPost,
	})
}

// POST /api/v1/protected/posts/:id/comments
func (h *PostHandler) AddComment(c *fiber.Ctx) error {
	userID, err := parseUserID(c.Locals("userID"))
	if err != nil {
		return c.SendStatus(http.StatusUnauthorized)
	}

	postID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid Post ID"})
	}

	var req struct {
		Content string `json:"content"`
	}
	if err := c.BodyParser(&req); err != nil || req.Content == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Content required"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	comment := core.Comment{
		PostID:  postID,
		UserID:  userID,
		Content: req.Content,
	}

	if err := h.repo.CreateComment(ctx, comment); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to add comment"})
	}

	return c.Status(http.StatusCreated).JSON(fiber.Map{"message": "Comment added"})
}

// GET /api/v1/protected/posts/:id/comments
func (h *PostHandler) GetComments(c *fiber.Ctx) error {
	postID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid Post ID"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	comments, err := h.repo.GetCommentsByPostID(ctx, postID)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch comments"})
	}

	return c.Status(http.StatusOK).JSON(comments)
}

// GET /api/v1/protected/users/photos/:filename
func (h *ProfileHandler) GetUserProfilePhoto(c *fiber.Ctx) error {
	filename := c.Params("filename")

	// Security check
	if filename == "" || containsDotDot(filename) {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid filename"})
	}

	// ✅ READ FROM "uploads/profile" FOLDER
	filePath := fmt.Sprintf("uploads/profile/%s", filename)

	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		return c.Status(http.StatusNotFound).JSON(fiber.Map{"error": "Image not found"})
	}

	return c.SendFile(filePath)
}
func (h *PostHandler) ToggleFavorite(c *fiber.Ctx) error {
	userID, err := parseUserID(c.Locals("userID"))
	if err != nil {
		return c.SendStatus(http.StatusUnauthorized)
	}

	postID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid Post ID"})
	}

	ctx := c.UserContext()

	// Check if currently favorite
	isFav, err := h.repo.IsFavorite(ctx, userID, postID)
	if err != nil {
		return c.SendStatus(http.StatusInternalServerError)
	}

	if isFav {
		// If it IS a favorite, remove it
		if err := h.repo.RemoveFavorite(ctx, userID, postID); err != nil {
			return c.SendStatus(http.StatusInternalServerError)
		}
		return c.JSON(fiber.Map{"is_favorite": false, "message": "Removed from favorites"})
	} else {
		// If NOT, add it
		if err := h.repo.AddFavorite(ctx, userID, postID); err != nil {
			return c.SendStatus(http.StatusInternalServerError)
		}
		return c.JSON(fiber.Map{"is_favorite": true, "message": "Added to favorites"})
	}
}

// GET /api/v1/protected/posts/:id/favorite
func (h *PostHandler) CheckFavoriteStatus(c *fiber.Ctx) error {
	userID, err := parseUserID(c.Locals("userID"))
	if err != nil {
		return c.SendStatus(http.StatusUnauthorized)
	}

	postID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid Post ID"})
	}

	isFav, err := h.repo.IsFavorite(c.UserContext(), userID, postID)
	if err != nil {
		return c.SendStatus(http.StatusInternalServerError)
	}

	return c.JSON(fiber.Map{"is_favorite": isFav})
}

// GET /api/v1/protected/favorites
func (h *PostHandler) GetUserFavorites(c *fiber.Ctx) error {
	userID, err := parseUserID(c.Locals("userID"))
	if err != nil {
		return c.SendStatus(http.StatusUnauthorized)
	}

	favs, err := h.repo.GetFavorites(c.UserContext(), userID)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch favorites"})
	}

	return c.JSON(favs)
}
func (h *PostHandler) GetUserPosts(c *fiber.Ctx) error {
	targetUserID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid User ID"})
	}

	posts, err := h.repo.GetPostsByUserID(c.UserContext(), targetUserID)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch user posts"})
	}

	return c.JSON(posts)
}
func (h *PostHandler) GetPosts(c *fiber.Ctx) error {
	// 1. Parse Pagination Query Params
	page, err := strconv.Atoi(c.Query("page", "1"))
	if err != nil || page < 1 {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid page number"})
	}

	limit, err := strconv.Atoi(c.Query("limit", "10"))
	if err != nil || limit < 1 {
		limit = 10 // Default limit
	}

	// 2. Calculate Offset
	offset := (page - 1) * limit

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	// 3. Call the Repository (The one you just added)
	posts, err := h.repo.GetPosts(ctx, limit, offset)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch posts"})
	}

	// 4. Return Data
	return c.Status(http.StatusOK).JSON(posts)
}
func (h *PostHandler) GetFeed(c *fiber.Ctx) error {
	// 1. Get Current User ID (To exclude their own posts)
	userID, err := parseUserID(c.Locals("userID"))
	if err != nil {
		return c.SendStatus(http.StatusUnauthorized)
	}

	// 2. Pagination
	page, _ := strconv.Atoi(c.Query("page", "1"))
	if page < 1 {
		page = 1
	}
	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	if limit < 1 {
		limit = 10
	}
	offset := (page - 1) * limit

	// 3. Call the NEW Repository function
	posts, err := h.repo.GetFeedPosts(c.UserContext(), limit, offset, userID)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch feed"})
	}

	return c.Status(http.StatusOK).JSON(posts)
}
