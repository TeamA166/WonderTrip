package repository

import (
	"context"
	"fmt"

	"github.com/TeamA166/WonderTrip/internal/core"
	"github.com/jmoiron/sqlx"
)

type PostRepository interface {
	CreatePost(ctx context.Context, post core.Post) (core.Post, error)
}

type postRepository struct {
	db *sqlx.DB
}

func NewPostRepository(db *sqlx.DB) PostRepository {
	return &postRepository{db: db}
}

func (r *postRepository) CreatePost(ctx context.Context, post core.Post) (core.Post, error) {
	const query = `
		INSERT INTO posts (user_id, title, description, rating, coordinates, photo_path)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, user_id, title, description, rating, coordinates, photo_path, created_at, updated_at`

	var created core.Post
	if err := r.db.GetContext(ctx, &created, query, post.UserID, post.Title, post.Description, post.Rating, post.Coordinates, post.PhotoPath); err != nil {
		return core.Post{}, fmt.Errorf("repository: create post: %w", err)
	}

	return created, nil
}
