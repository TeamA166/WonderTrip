-- +goose Up
CREATE TABLE teama (
    title VARCHAR(255) NOT NULL
);

INSERT INTO teama (title)
VALUES ('TeamA');

-- +goose Down
DROP TABLE teama;
