package utils

import (
	"errors"
	"fmt"

	"github.com/google/uuid"
)

func ParseUUID(id interface{}) (uuid.UUID, error) {
	if id == nil {
		return uuid.UUID{}, errors.New("user id missing")
	}

	userIDStr := fmt.Sprint(id)
	return uuid.Parse(userIDStr)
}
