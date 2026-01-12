package repository

import (
	"context"
	"fmt"

	"github.com/TeamA166/WonderTrip/internal/core"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type PostRepository interface {
	CreatePost(ctx context.Context, post core.Post) (core.Post, error)
	GetPostsByStatus(ctx context.Context, isVerified bool, limit int, offset int) ([]core.Post, error)
	GetPostsByUserID(ctx context.Context, userID uuid.UUID) ([]core.Post, error)
	DeletePost(ctx context.Context, postID uuid.UUID, userID uuid.UUID) error
	UpdatePost(ctx context.Context, post core.Post) error
	GetPostByID(ctx context.Context, postID uuid.UUID) (core.Post, error)
	CreateComment(ctx context.Context, comment core.Comment) error
	GetCommentsByPostID(ctx context.Context, postID uuid.UUID) ([]core.Comment, error)
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

func (r *postRepository) GetPostsByStatus(ctx context.Context, isVerified bool, limit int, offset int) ([]core.Post, error) {

	const query = `
        SELECT id, user_id, title, description, rating, coordinates, photo_path, verified, created_at, updated_at
        FROM posts
        WHERE verified = $1 
        ORDER BY created_at DESC
        LIMIT $2 OFFSET $3`

	posts := []core.Post{}

	if err := r.db.SelectContext(ctx, &posts, query, isVerified, limit, offset); err != nil {
		return nil, fmt.Errorf("repository: get posts by status: %w", err)
	}

	return posts, nil
}
func (r *postRepository) GetPostsByUserID(ctx context.Context, userID uuid.UUID) ([]core.Post, error) {
	// Fetch all posts for a specific user
	const query = `SELECT id, user_id, title, description, rating, coordinates, photo_path, verified, created_at FROM posts WHERE user_id = $1 ORDER BY created_at DESC`

	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []core.Post
	for rows.Next() {
		var p core.Post
		if err := rows.Scan(&p.ID, &p.UserID, &p.Title, &p.Description, &p.Rating, &p.Coordinates, &p.PhotoPath, &p.Verified, &p.CreatedAt); err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}
	return posts, nil
}

func (r *postRepository) DeletePost(ctx context.Context, postID uuid.UUID, userID uuid.UUID) error {
	// Only delete if the ID and UserID match (Security check)
	const query = `DELETE FROM posts WHERE id = $1 AND user_id = $2`
	res, err := r.db.ExecContext(ctx, query, postID, userID)
	if err != nil {
		return err
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("post not found or unauthorized")
	}
	return nil
}

func (r *postRepository) UpdatePost(ctx context.Context, p core.Post) error {
	// ✅ QUERY UPDATED: Updates photo_path, coordinates, and sets verified to FALSE
	const query = `
        UPDATE posts 
        SET title=$1, description=$2, rating=$3, coordinates=$4, photo_path=$5, verified=false 
        WHERE id=$6 AND user_id=$7`

	res, err := r.db.ExecContext(ctx, query,
		p.Title, p.Description, p.Rating, p.Coordinates, p.PhotoPath, p.ID, p.UserID,
	)
	if err != nil {
		return err
	}

	rows, _ := res.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("post not found or unauthorized")
	}
	return nil
}

func (r *postRepository) GetPostByID(ctx context.Context, postID uuid.UUID) (core.Post, error) {
	const query = `SELECT id, user_id, title, description, rating, coordinates, photo_path, verified FROM posts WHERE id = $1`
	var p core.Post
	err := r.db.QueryRowContext(ctx, query, postID).Scan(
		&p.ID, &p.UserID, &p.Title, &p.Description, &p.Rating, &p.Coordinates, &p.PhotoPath, &p.Verified,
	)
	return p, err
}
func (r *postRepository) CreateComment(ctx context.Context, c core.Comment) error {
	const query = `INSERT INTO comments (post_id, user_id, content) VALUES ($1, $2, $3)`
	_, err := r.db.ExecContext(ctx, query, c.PostID, c.UserID, c.Content)
	return err
}

func (r *postRepository) GetCommentsByPostID(ctx context.Context, postID uuid.UUID) ([]core.Comment, error) {
	// Join with users table to get the name of the commenter
	const query = `
        SELECT c.id, c.post_id, c.user_id, c.content, c.created_at, u.name 
        FROM comments c
        JOIN users u ON c.user_id = u.id
        WHERE c.post_id = $1
        ORDER BY c.created_at ASC`

	rows, err := r.db.QueryContext(ctx, query, postID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var comments []core.Comment
	for rows.Next() {
		var c core.Comment
		if err := rows.Scan(&c.ID, &c.PostID, &c.UserID, &c.Content, &c.CreatedAt, &c.UserName); err != nil {
			return nil, err
		}
		comments = append(comments, c)
	}
	return comments, nil
}
