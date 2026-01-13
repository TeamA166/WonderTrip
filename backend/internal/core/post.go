package core

import (
	"time"

	"github.com/google/uuid"
)

type Post struct {
	ID            uuid.UUID `json:"id" db:"id"`
	UserID        uuid.UUID `json:"user_id" db:"user_id"`
	Title         string    `json:"title" db:"title"`
	Description   string    `json:"description" db:"description"`
	Rating        int       `json:"rating" db:"rating"`
	Coordinates   string    `json:"coordinates" db:"coordinates"`
	PhotoPath     string    `json:"photo_path" db:"photo_path"`
	Verified      bool      `json:"verified" db:"verified"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
	UpdatedAt     time.Time `json:"updated_at" db:"updated_at"`
	UserName      string    `json:"user_name"`
	UserPhotoPath string    `json:"user_photo_path"`
}

type PostPublishReq struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	Rating      *int   `json:"rating,omitempty"`
	Coordinates string `json:"coordinates"`
	PhotoPath   string `json:"photo_path"`
}
