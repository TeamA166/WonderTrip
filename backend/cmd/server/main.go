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
	//Repos
	userRepo := repository.NewUserRepository(db)
	postRepo := repository.NewPostRepository(db)
	resetRepo := repository.NewPResetRepository(db)

	//Handlers
	tokenExpiry := time.Duration(cfg.Auth.AccessTokenMinutes) * time.Minute
	authHandler, err := public.NewAuthHandler(userRepo, cfg.Auth.JWTSecret, tokenExpiry, cfg.Auth.PasswordHashingCost)
	postHandler := privateapi.NewPostHandler(postRepo)
	resetHandler := public.NewPasswordResetHandler(resetRepo, userRepo)
	profileHandler := privateapi.NewProfileHandler(userRepo)
	authMiddleware := middleware.NewAuthMiddleware(cfg.Auth.JWTSecret)

	if err != nil {
		log.Fatalf("Failed to initialize auth handler: %v", err)
	}

	app := fiber.New()

	app.Use(cors.New(cors.Config{
		// ✅ FIX: List specific domains instead of "*"
		// Note: For Flutter Web, you usually run on a specific port (see below)
		AllowOrigins:     "http://localhost:3000, http://127.0.0.1:3000, http://10.0.2.2:8080",
		AllowHeaders:     "Origin, Content-Type, Accept, Authorization",
		AllowMethods:     "GET, POST, PUT, DELETE, OPTIONS",
		AllowCredentials: true, // This requires specific AllowOrigins
	}))

	app.Use(logger.New())

	v1 := app.Group("/api/v1") //api to auth
	{
		v1.Get("/title", loadScreenHandler.GetTitle)

		auth := v1.Group("/auth")
		auth.Post("/register", authHandler.Register)
		auth.Post("/login", authHandler.Login)
		auth.Post("/forgot-password", resetHandler.RequestReset)
		auth.Post("/verify-code", resetHandler.VerifyOTP)
		auth.Post("/reset-password", resetHandler.ResetPassword)
		auth.Post("/logout", authHandler.Logout)
		auth.Get("/me", authMiddleware, authHandler.GetMe)

	}

	protected := v1.Group("/protected", authMiddleware)
	{
		protected.Post("/posts", postHandler.Publish)
		protected.Get("/posts", postHandler.GetVerifiedPosts)
		protected.Get("/posts/unverified", postHandler.GetUnverifiedPosts)
		protected.Get("/posts/photo/:filename", postHandler.GetPostPhoto)
		protected.Get("/posts/me", postHandler.GetMyPosts)
		protected.Delete("/posts/:id", postHandler.DeletePost)
		protected.Put("/posts/:id", postHandler.UpdatePost)

		protected.Get("/profile-photo", profileHandler.GetProfilePhoto)
		protected.Get("/profile", profileHandler.GetProfile)
		protected.Put("/profile", profileHandler.UpdateProfile)

		protected.Post("/profile-photo", profileHandler.UploadProfilePhoto)
		protected.Put("/password", profileHandler.ChangePassword)

		protected.Post("/posts/:id/comments", postHandler.AddComment)
		protected.Get("/posts/:id/comments", postHandler.GetComments)
		protected.Get("/users/photos/:filename", profileHandler.GetUserProfilePhoto)

		protected.Post("/posts/:id/favorite", postHandler.ToggleFavorite)
		protected.Get("/posts/:id/favorite", postHandler.CheckFavoriteStatus)
		protected.Get("/favorites", postHandler.GetUserFavorites)

		protected.Get("/users/:id/posts", postHandler.GetUserPosts)

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
