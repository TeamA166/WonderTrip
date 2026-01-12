package core

type LoadScreen struct {
	Title string `json:"title" db:"title"`
}

type MainTitleGetRequest struct {
	Title string `json:"title" validate:"required"`
}
