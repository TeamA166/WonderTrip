package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"github.com/TeamA166/WonderTrip/internal/core"
	"github.com/jmoiron/sqlx"
)

type UserRepository interface {
	CreateUser(ctx context.Context, user core.User) (core.User, error)
	GetByEmail(ctx context.Context, email string) (core.User, error)
}

type userRepository struct {
	db *sqlx.DB
}

func NewUserRepository(db *sqlx.DB) UserRepository {
	return &userRepository{db: db}
}

func (r *userRepository) CreateUser(ctx context.Context, user core.User) (core.User, error) {
	const query = `
		INSERT INTO users (email, password_hash, name, surname)
		VALUES ($1, $2, $3, $4)
		RETURNING id, email, name, surname, password_hash, created_at, updated_at`

	var created core.User
	if err := r.db.GetContext(ctx, &created, query, user.Email, user.PasswordHash, user.Name, user.Surname); err != nil {
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
