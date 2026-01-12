package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"github.com/TeamA166/WonderTrip/internal/core"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type UserRepository interface {
	CreateUser(ctx context.Context, user core.User) (core.User, error)
	GetByEmail(ctx context.Context, email string) (core.User, error)
	GetById(ctx context.Context, uuid uuid.UUID) (core.User, error)
	UpdateUser(ctx context.Context, user core.User) error
	UpdateProfilePhoto(ctx context.Context, userID uuid.UUID, path string) error
	UpdatePassword(ctx context.Context, userID uuid.UUID, newHash string) error
	GetByIdForPassword(ctx context.Context, uuid uuid.UUID) (core.User, error)
}

type userRepository struct {
	db *sqlx.DB
}

func NewUserRepository(db *sqlx.DB) UserRepository {
	return &userRepository{db: db}
}

func (r *userRepository) CreateUser(ctx context.Context, user core.User) (core.User, error) {
	const query = `
		INSERT INTO users (email, password_hash, name, surname, profile_path)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, email, name, surname, password_hash, created_at, updated_at`

	var created core.User

	const profilePath = "uploads/profile/Default_pfp.jpg"
	if err := r.db.GetContext(ctx, &created, query, user.Email, user.PasswordHash, user.Name, user.Surname, profilePath); err != nil {
		return core.User{}, fmt.Errorf("repository: create user: %w", err)
	}

	return created, nil
}

func (r *userRepository) GetByEmail(ctx context.Context, email string) (core.User, error) {
	const query = `
		SELECT id, email, name, surname, password_hash, created_at, updated_at
		FROM users
		WHERE email = $1
		LIMIT 1`

	var usr core.User
	if err := r.db.GetContext(ctx, &usr, query, email); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return core.User{}, sql.ErrNoRows
		}
		return core.User{}, fmt.Errorf("repository: get user by email: %w", err)
	}

	return usr, nil
}
func (r *userRepository) GetById(ctx context.Context, uuid uuid.UUID) (core.User, error) {
	const query = `
	SELECT id, email, name, surname, profile_path
	FROM users
	WHERE id = $1
	LIMIT 1`

	var user core.User
	if err := r.db.GetContext(ctx, &user, query, uuid); err != nil {
		return core.User{}, fmt.Errorf("repository: get user by id: %w", err)
	}
	return user, nil
}
func (r *userRepository) UpdateUser(ctx context.Context, user core.User) error {
	const query = `
        UPDATE users 
        SET name = $1, surname = $2, email = $3, updated_at = NOW()
        WHERE id = $4`

	_, err := r.db.ExecContext(ctx, query, user.Name, user.Surname, user.Email, user.ID)
	if err != nil {
		return fmt.Errorf("repository: update user: %w", err)
	}
	return nil
}
func (r *userRepository) UpdateProfilePhoto(ctx context.Context, userID uuid.UUID, path string) error {
	const query = `UPDATE users SET profile_path = $1 WHERE id = $2`
	_, err := r.db.ExecContext(ctx, query, path, userID)
	return err
}
func (r *userRepository) UpdatePassword(ctx context.Context, userID uuid.UUID, newHash string) error {
	const query = `UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2`
	_, err := r.db.ExecContext(ctx, query, newHash, userID)
	return err
}
func (r *userRepository) GetByIdForPassword(ctx context.Context, uuid uuid.UUID) (core.User, error) {
	const query = `SELECT id, name, surname, email, password_hash FROM users WHERE id = $1`

	var user core.User
	if err := r.db.GetContext(ctx, &user, query, uuid); err != nil {
		return core.User{}, fmt.Errorf("repository: get user by id: %w", err)
	}
	return user, nil
}
