package middleware

import (
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
)

func NewAuthMiddleware(secret string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		var tokenString string

		authHeader := c.Get("Authorization")
		if authHeader != "" {
			tokenString = strings.TrimPrefix(authHeader, "Bearer ")
		}

		if tokenString == "" {
			tokenString = c.Cookies("token")
		}

		if tokenString == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Unauthorized: No token provided",
			})
		}

		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {

			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fiber.ErrUnauthorized
			}
			return []byte(secret), nil
		})

		if err != nil || !token.Valid {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Unauthorized: Invalid or expired token",
			})
		}

		if claims, ok := token.Claims.(jwt.MapClaims); ok {
			c.Locals("userID", claims["sub"])  // Matches "sub": user.ID
			c.Locals("email", claims["email"]) // Matches "email": user.Email
			c.Locals("role", claims["role"])   // Matches "role": user.Role
		}

		return c.Next()
	}
}
