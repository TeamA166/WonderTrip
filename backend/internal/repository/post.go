package repository

import (
	"context"
	"database/sql"
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
	AddFavorite(ctx context.Context, userID, postID uuid.UUID) error
	RemoveFavorite(ctx context.Context, userID, postID uuid.UUID) error
	IsFavorite(ctx context.Context, userID, postID uuid.UUID) (bool, error)
	GetFavorites(ctx context.Context, userID uuid.UUID) ([]core.Post, error)
	GetPosts(ctx context.Context, limit int, offset int) ([]core.Post, error)
	GetFeedPosts(ctx context.Context, limit int, offset int, excludeUserID uuid.UUID) ([]core.Post, error)
	ToggleLike(ctx context.Context, userID, postID uuid.UUID) error
	IsLiked(ctx context.Context, userID, postID uuid.UUID) (bool, error)
}

type postRepository struct {
	db *sqlx.DB
}

func NewPostRepository(db *sqlx.DB) PostRepository {
	return &postRepository{db: db}
}

const postSelectQuery = `
    SELECT p.id, p.user_id, p.title, p.description, p.rating, p.coordinates, p.photo_path, p.verified, p.created_at,
           u.name, COALESCE(u.profile_path, '') 
    FROM posts p
    JOIN users u ON p.user_id = u.id `

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
	// ✅ FIX: Use the shared query to get User Name & Photo
	// We add "WHERE p.verified = $1" to filter by status
	query := postSelectQuery + `
        WHERE p.verified = $1 
        ORDER BY p.created_at DESC
        LIMIT $2 OFFSET $3`

	rows, err := r.db.QueryContext(ctx, query, isVerified, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("repository: get posts by status: %w", err)
	}
	defer rows.Close()

	// ✅ FIX: Use the helper scanner so it fills in UserName and UserPhotoPath
	return r.scanPosts(rows)
}
func (r *postRepository) GetPostsByUserID(ctx context.Context, userID uuid.UUID) ([]core.Post, error) {
	// ✅ CHANGED: We now select the Like Count!
	// Note: We set 'is_favorited' and 'is_liked' to false here by default.
	// (To show if *YOU* liked these posts, we would need to pass your ID into this function too,
	// but for now, this fixes the "0 Likes" bug).
	const query = `
        SELECT p.id, p.user_id, p.title, p.description, p.rating, p.coordinates, p.photo_path, p.verified, p.created_at,
               u.name, COALESCE(u.profile_path, ''),
               false AS is_favorited, 
               false AS is_liked,     
               (SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id) AS like_count
        FROM posts p
        JOIN users u ON p.user_id = u.id
        WHERE p.user_id = $1 
        ORDER BY p.created_at DESC`

	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []core.Post
	for rows.Next() {
		var p core.Post
		// ✅ We must manually scan because we added 3 new columns (fav, liked, count)
		// compared to the old scanner.
		if err := rows.Scan(
			&p.ID, &p.UserID, &p.Title, &p.Description, &p.Rating, &p.Coordinates, &p.PhotoPath, &p.Verified, &p.CreatedAt,
			&p.UserName, &p.UserPhotoPath,
			&p.IsFavorited,
			&p.IsLiked,
			&p.LikeCount, // <--- This will now contain the correct number!
		); err != nil {
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
	query := postSelectQuery + "WHERE p.id = $1"

	var p core.Post
	err := r.db.QueryRowContext(ctx, query, postID).Scan(
		&p.ID, &p.UserID, &p.Title, &p.Description, &p.Rating, &p.Coordinates, &p.PhotoPath, &p.Verified, &p.CreatedAt,
		&p.UserName, &p.UserPhotoPath,
	)
	return p, err
}
func (r *postRepository) CreateComment(ctx context.Context, c core.Comment) error {
	const query = `INSERT INTO comments (post_id, user_id, content) VALUES ($1, $2, $3)`
	_, err := r.db.ExecContext(ctx, query, c.PostID, c.UserID, c.Content)
	return err
}

func (r *postRepository) GetCommentsByPostID(ctx context.Context, postID uuid.UUID) ([]core.Comment, error) {
	// ✅ CHANGED: Select u.photo_path
	const query = `
        SELECT c.id, c.post_id, c.user_id, c.content, c.created_at, u.name, u.profile_path
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
		// ✅ CHANGED: Scan the new column into UserPhotoPath
		if err := rows.Scan(&c.ID, &c.PostID, &c.UserID, &c.Content, &c.CreatedAt, &c.UserName, &c.UserPhotoPath); err != nil {
			return nil, err
		}
		comments = append(comments, c)
	}
	return comments, nil
}
func (r *postRepository) AddFavorite(ctx context.Context, userID, postID uuid.UUID) error {
	_, err := r.db.ExecContext(ctx,
		"INSERT INTO favorites (user_id, post_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
		userID, postID)
	return err
}

func (r *postRepository) RemoveFavorite(ctx context.Context, userID, postID uuid.UUID) error {
	_, err := r.db.ExecContext(ctx,
		"DELETE FROM favorites WHERE user_id = $1 AND post_id = $2",
		userID, postID)
	return err
}

func (r *postRepository) IsFavorite(ctx context.Context, userID, postID uuid.UUID) (bool, error) {
	var exists bool
	query := "SELECT EXISTS(SELECT 1 FROM favorites WHERE user_id = $1 AND post_id = $2)"
	err := r.db.QueryRowContext(ctx, query, userID, postID).Scan(&exists)
	return exists, err
}
func (r *postRepository) GetFavorites(ctx context.Context, userID uuid.UUID) ([]core.Post, error) {
	// ✅ FIX: Join with 'users' table to get Name and PhotoPath for favorites too
	const query = `
        SELECT p.id, p.user_id, p.title, p.description, p.rating, p.coordinates, p.photo_path, p.verified, p.created_at,
               u.name, COALESCE(u.profile_path, '')
        FROM posts p
        JOIN favorites f ON p.id = f.post_id
        JOIN users u ON p.user_id = u.id
        WHERE f.user_id = $1
        ORDER BY f.created_at DESC`

	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	// Now we can use your helper scanPosts because the columns match!
	return r.scanPosts(rows)
}
func (r *postRepository) scanPosts(rows *sql.Rows) ([]core.Post, error) {
	var posts []core.Post
	for rows.Next() {
		var p core.Post
		if err := rows.Scan(
			&p.ID, &p.UserID, &p.Title, &p.Description, &p.Rating, &p.Coordinates, &p.PhotoPath, &p.Verified, &p.CreatedAt,
			&p.UserName, &p.UserPhotoPath,
		); err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}
	return posts, nil
}
func (r *postRepository) GetPosts(ctx context.Context, limit int, offset int) ([]core.Post, error) {
	// ✅ ADD LIMIT AND OFFSET
	query := postSelectQuery + `
        ORDER BY p.created_at DESC
        LIMIT $1 OFFSET $2`

	rows, err := r.db.QueryContext(ctx, query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return r.scanPosts(rows)
}
func (r *postRepository) GetFeedPosts(ctx context.Context, limit int, offset int, excludeUserID uuid.UUID) ([]core.Post, error) {
	const query = `
        SELECT p.id, p.user_id, p.title, p.description, p.rating, p.coordinates, p.photo_path, p.verified, p.created_at,
               u.name, COALESCE(u.profile_path, ''),
               -- 1. Check if "Bookmarked" (Favorites table)
               EXISTS(SELECT 1 FROM favorites f WHERE f.post_id = p.id AND f.user_id = $1) AS is_favorited,
               -- 2. Check if "Liked" (Likes table)
               EXISTS(SELECT 1 FROM post_likes l WHERE l.post_id = p.id AND l.user_id = $1) AS is_liked,
               -- 3. Count Total Likes
               (SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id) AS like_count
        FROM posts p
        JOIN users u ON p.user_id = u.id
        WHERE p.user_id != $1 
        ORDER BY p.created_at DESC
        LIMIT $2 OFFSET $3`

	rows, err := r.db.QueryContext(ctx, query, excludeUserID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []core.Post
	for rows.Next() {
		var p core.Post
		if err := rows.Scan(
			&p.ID, &p.UserID, &p.Title, &p.Description, &p.Rating, &p.Coordinates, &p.PhotoPath, &p.Verified, &p.CreatedAt,
			&p.UserName, &p.UserPhotoPath,
			&p.IsFavorited, // Bookmark status
			&p.IsLiked,     // Like status
			&p.LikeCount,   // Total likes
		); err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}

	return posts, nil
}
func (r *postRepository) ToggleLike(ctx context.Context, userID, postID uuid.UUID) error {
	// Check if liked
	var exists bool
	checkQuery := "SELECT EXISTS(SELECT 1 FROM post_likes WHERE user_id = $1 AND post_id = $2)"
	if err := r.db.QueryRowContext(ctx, checkQuery, userID, postID).Scan(&exists); err != nil {
		return err
	}

	if exists {
		_, err := r.db.ExecContext(ctx, "DELETE FROM post_likes WHERE user_id = $1 AND post_id = $2", userID, postID)
		return err
	} else {
		_, err := r.db.ExecContext(ctx, "INSERT INTO post_likes (user_id, post_id) VALUES ($1, $2)", userID, postID)
		return err
	}
}
func (r *postRepository) IsLiked(ctx context.Context, userID, postID uuid.UUID) (bool, error) {
	var exists bool
	query := "SELECT EXISTS(SELECT 1 FROM post_likes WHERE user_id = $1 AND post_id = $2)"
	err := r.db.QueryRowContext(ctx, query, userID, postID).Scan(&exists)
	return exists, err
}
