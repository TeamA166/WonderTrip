package database

import (
	"fmt"
	"log"

	"github.com/TeamA166/WonderTrip/internal/config"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func BuildDSN(cfg *config.Config) string {
	return fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		cfg.Database.Host, cfg.Database.Port, cfg.Database.User, cfg.Database.Password, cfg.Database.DBName, cfg.Database.SSLMode)
}

func NewDatabase(cfg *config.Config) (*sqlx.DB, error) {
	dsn := BuildDSN(cfg)

	db, err := sqlx.Connect(cfg.Database.Driver, dsn)
	if err != nil {
		log.Printf("Failed to connect to PostgreSQL: %v", err)
		return nil, err
	}

	log.Println("PostgreSQL connection established successfully.")

	if err = db.Ping(); err != nil {
		log.Printf("Failed to ping database: %v", err)
		return nil, err
	}
	log.Println("Database connection verified with Ping.")

	return db, nil
}
