package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/TeamA166/WonderTrip/internal/core"
	"github.com/jmoiron/sqlx"
)

type PResetRepository interface {
	UpdatePassword(ctx context.Context, email string, hash string) error
	SaveOTP(ctx context.Context, email string, codeHash string, expiry time.Time) error
	GetByEmail(ctx context.Context, email string) (core.PasswordReset, error)
	DeleteByEmail(ctx context.Context, email string) error
}

type pResetRepository struct {
	db *sqlx.DB
}

func NewPResetRepository(db *sqlx.DB) PResetRepository {
	return &pResetRepository{db: db}
}

func (r *pResetRepository) UpdatePassword(ctx context.Context, email string, hash string) error {
	const query = `UPDATE users SET password_hash = $1, updated_at = NOW() WHERE email = $2`

	_, err := r.db.ExecContext(ctx, query, hash, email)
	if err != nil {
		return fmt.Errorf("repository: update password: %w", err)
	}
	return nil
}

func (r *pResetRepository) SaveOTP(ctx context.Context, email string, codeHash string, expiry time.Time) error {
	const query = `
        INSERT INTO password_resets (email, code_hash, expires_at)
        VALUES ($1, $2, $3)
        ON CONFLICT (email) 
        DO UPDATE SET 
            code_hash = EXCLUDED.code_hash, 
            expires_at = EXCLUDED.expires_at;`

	_, err := r.db.ExecContext(ctx, query, email, codeHash, expiry)
	if err != nil {
		return fmt.Errorf("repository: save otp: %w", err)
	}
	return nil
}

func (r *pResetRepository) GetByEmail(ctx context.Context, email string) (core.PasswordReset, error) {

	const query = `
        SELECT email, code_hash, expires_at 
        FROM password_resets 
        WHERE email = $1`

	var resetData core.PasswordReset
	// Make sure core.PasswordReset struct has `db` tags matching these columns
	if err := r.db.GetContext(ctx, &resetData, query, email); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return core.PasswordReset{}, sql.ErrNoRows
		}
		return core.PasswordReset{}, fmt.Errorf("repository: get reset otp: %w", err)
	}
	return resetData, nil
}

// 3. DeleteByEmail (Cleanup)
func (r *pResetRepository) DeleteByEmail(ctx context.Context, email string) error {
	const query = `DELETE FROM password_resets WHERE email = $1`

	_, err := r.db.ExecContext(ctx, query, email)
	if err != nil {
		return fmt.Errorf("repository: delete reset otp: %w", err)
	}
	return nil
}
