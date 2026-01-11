package core

type GetProfileResponse struct {
	Email   string `json:"email" db:"email"`
	Name    string `json:"name" db:"name"`
	Surname string `json:"surname" db:"surname"`
}
