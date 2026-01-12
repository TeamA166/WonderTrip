package repository

import (
	"context"
	"fmt"

	"github.com/TeamA166/WonderTrip/internal/core"
	"github.com/jmoiron/sqlx"
)

type LoadScreenRepository interface {
	GetTitle(ctx context.Context) (core.LoadScreen, error)
}

type loadScreenRepository struct {
	db *sqlx.DB
}

func NewLoadScreenRepository(db *sqlx.DB) LoadScreenRepository {
	return &loadScreenRepository{db: db}
}

func (r *loadScreenRepository) GetTitle(ctx context.Context) (core.LoadScreen, error) {
	var title core.LoadScreen

	query := `SELECT title FROM teama LIMIT 1`

	err := r.db.GetContext(ctx, &title, query)
	if err != nil {

		return core.LoadScreen{}, fmt.Errorf("repository: failed to get first user: %w", err)
	}

	return title, nil
}
