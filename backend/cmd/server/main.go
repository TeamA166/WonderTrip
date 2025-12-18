package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	middleware "github.com/TeamA166/WonderTrip/internal/api/middlewares"
	privateapi "github.com/TeamA166/WonderTrip/internal/api/private"
	"github.com/TeamA166/WonderTrip/internal/api/public"
	"github.com/TeamA166/WonderTrip/internal/config"
	"github.com/TeamA166/WonderTrip/internal/database"
	"github.com/TeamA166/WonderTrip/internal/repository"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
)

func main() {

	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	db, err := database.NewDatabase(&cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	defer db.Close()
	log.Println("Database connection established successfully.")

	loadScreenRepo := repository.NewLoadScreenRepository(db)
	loadScreenHandler := public.NewLoadScreenHandler(loadScreenRepo)

	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)
	tokenExpiry := time.Duration(cfg.Auth.AccessTokenMinutes) * time.Minute
	authHandler, err := public.NewAuthHandler(userRepo, cfg.Auth.JWTSecret, tokenExpiry, cfg.Auth.PasswordHashingCost)
	postHandler := privateapi.NewPostHandler(postRepo)

	authMiddleware := middleware.NewAuthMiddleware(cfg.Auth.JWTSecret)

	if err != nil {
		log.Fatalf("Failed to initialize auth handler: %v", err)
	}

	app := fiber.New()

	app.Use(cors.New(cors.Config{
		AllowOrigins:     "*", // In production, replace * with your flutter domain
		AllowHeaders:     "Origin, Content-Type, Accept",
		AllowMethods:     "GET, POST, OPTIONS",
		AllowCredentials: true,
	}))

	app.Use(logger.New())

	v1 := app.Group("/api/v1") //api to auth
	{
		v1.Get("/title", loadScreenHandler.GetTitle)

		auth := v1.Group("/auth")
		auth.Post("/register", authHandler.Register)
		auth.Post("/login", authHandler.Login)
	}

	protected := v1.Group("/protected", authMiddleware)
	{
		protected.Post("/posts", postHandler.Publish)
	}

	serverErr := make(chan error, 1)
	go func() {
		log.Printf("Starting server on port %s", cfg.Port)
		if err := app.Listen(cfg.Port); err != nil {
			serverErr <- err
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	select {
	case err := <-serverErr:

		log.Fatalf("Server failed to start and gracefully exit: %v", err)
	case <-quit:

	}

	log.Println("Shutting down server gracefully...")
	if err := app.Shutdown(); err != nil {
		log.Fatalf("Fiber server shutdown error: %v", err)
	}
	log.Println("Server stopped.")

}
