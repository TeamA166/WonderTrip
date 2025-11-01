package main

import (
	"log"

	"github.com/TeamA166/WonderTrip/internal/config"
	"github.com/TeamA166/WonderTrip/internal/database"
	"github.com/gofiber/fiber/v3"
	"gorm.io/gorm"
)

var db *gorm.DB

func main() {

	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	db, err = database.InitDatabase(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	app := fiber.New()

	log.Printf("Starting server on port %s", cfg.Port)
	if err := app.Listen(cfg.Port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}

}
