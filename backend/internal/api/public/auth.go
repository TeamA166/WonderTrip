package public

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/TeamA166/WonderTrip/internal/core"
	"github.com/TeamA166/WonderTrip/internal/repository"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type AuthHandler struct {
	repo         repository.UserRepository
	tokenSecret  string
	tokenExpiry  time.Duration
	passwordCost int
}

func NewAuthHandler(repo repository.UserRepository, tokenSecret string, tokenExpiry time.Duration, passwordCost int) (*AuthHandler, error) {
	if tokenSecret == "" {
		return nil, errors.New("auth handler: token secret is required")
	}

	if tokenExpiry <= 0 {
		tokenExpiry = 15 * time.Minute
	}

	if passwordCost < bcrypt.MinCost || passwordCost > bcrypt.MaxCost {
		passwordCost = bcrypt.DefaultCost
	}

	return &AuthHandler{
		repo:         repo,
		tokenSecret:  tokenSecret,
		tokenExpiry:  tokenExpiry,
		passwordCost: passwordCost,
	}, nil
}

func (h *AuthHandler) Register(c *fiber.Ctx) error {
	var req core.RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Geçersiz istek gövdesi"})
	}

	req.Email = sanitizeEmail(req.Email)
	req.Name = strings.TrimSpace(req.Name)
	req.Surname = strings.TrimSpace(req.Surname)

	if err := validateRegisterRequest(req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	if _, err := h.repo.GetByEmail(ctx, req.Email); err == nil {
		return c.Status(http.StatusConflict).JSON(fiber.Map{"error": "Bu e-posta zaten kayıtlı"})
	} else if !errors.Is(err, sql.ErrNoRows) {
		fmt.Printf(err.Error())
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Kullanıcı kontrolü başarısız"})

	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), h.passwordCost)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Şifre hashlenemedi"})
	}

	user := core.User{
		Email:        req.Email,
		Name:         req.Name,
		Surname:      req.Surname,
		PasswordHash: string(hash),
	}

	created, err := h.repo.CreateUser(ctx, user)
	if err != nil {
		fmt.Printf(err.Error())
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Kullanıcı kaydedilemedi"})
	}

	authResponse, err := h.buildAuthResponse(created)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Token oluşturulamadı"})
	}

	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"user": sanitizeUser(created),
		"auth": authResponse,
	})
}

func (h *AuthHandler) Login(c *fiber.Ctx) error {
	var req core.LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Geçersiz istek gövdesi"})
	}

	req.Email = sanitizeEmail(req.Email)

	if req.Email == "" || req.Password == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "E-posta ve şifre zorunludur"})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	user, err := h.repo.GetByEmail(ctx, req.Email)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "E-posta veya şifre hatalı"})
		}
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Kullanıcı getirilemedi"})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "E-posta veya şifre hatalı"})
	}

	authResponse, err := h.buildAuthResponse(user)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Token oluşturulamadı"})
	}

	c.Cookie(&fiber.Cookie{
		Name:     "token",
		Value:    authResponse.AccessToken,
		Expires:  time.Now().Add(h.tokenExpiry),
		HTTPOnly: true,
		Secure:   true,
		SameSite: "Strict",
	})

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"user": sanitizeUser(user),
		"auth": authResponse,
	})
}

func (h *AuthHandler) buildAuthResponse(user core.User) (core.AuthResponse, error) {
	expiresAt := time.Now().Add(h.tokenExpiry)
	issuedAt := time.Now()

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":   user.ID,
		"email": user.Email,
		"role":  user.Role,
		"exp":   expiresAt.Unix(),
		"iat":   issuedAt.Unix(),
	})

	signed, err := token.SignedString([]byte(h.tokenSecret))
	if err != nil {
		return core.AuthResponse{}, fmt.Errorf("token imzalanamadı: %w", err)
	}

	return core.AuthResponse{
		AccessToken: signed,
		ExpiresIn:   int64(h.tokenExpiry.Seconds()),
	}, nil
}

func sanitizeEmail(email string) string {
	return strings.TrimSpace(strings.ToLower(email))
}

func sanitizeUser(user core.User) fiber.Map {
	return fiber.Map{
		"id":        user.ID,
		"email":     user.Email,
		"name":      user.Name,
		"createdAt": user.CreatedAt,
		"updatedAt": user.UpdatedAt,
	}
}

func validateRegisterRequest(req core.RegisterRequest) error {
	if req.Email == "" {
		return errors.New("E-posta zorunludur")
	}

	if req.Password == "" {
		return errors.New("Şifre zorunludur")
	}

	if len(req.Password) < 6 {
		return errors.New("Şifre en az 6 karakter olmalıdır")
	}

	return nil
}

func (h *AuthHandler) Logout(c *fiber.Ctx) error {
	// Clear the cookie by setting an expired date
	c.Cookie(&fiber.Cookie{
		Name:     "token",
		Value:    "",
		Expires:  time.Now().Add(-time.Hour), // Set to 1 hour ago
		HTTPOnly: true,
		Secure:   true,
		SameSite: "Strict",
	})

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Successfully logged out",
	})
}
