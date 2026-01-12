-- +goose Up
-- +goose StatementBegin
CREATE TABLE password_resets (
    email VARCHAR(255) PRIMARY KEY,
    code_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_email
        FOREIGN KEY (email)
        REFERENCES users(email)
        ON DELETE CASCADE
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS password_resets;
-- +goose StatementEnd