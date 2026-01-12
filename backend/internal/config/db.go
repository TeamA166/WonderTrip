package config

import (
	"github.com/spf13/viper"
)

type Config struct {
	Port     string `mapstructure:"port"`
	Database struct {
		Driver   string `mapstructure:"driver"`
		Host     string `mapstructure:"host"`
		Port     string `mapstructure:"port"`
		User     string `mapstructure:"user"`
		Password string `mapstructure:"password"`
		DBName   string `mapstructure:"dbname"`
		SSLMode  string `mapstructure:"sslmode"`
	} `mapstructure:"database"`
	Auth struct {
		JWTSecret           string `mapstructure:"jwt_secret"`
		AccessTokenMinutes  int    `mapstructure:"access_token_minutes"`
		PasswordHashingCost int    `mapstructure:"password_hashing_cost"`
	} `mapstructure:"auth"`
	Password struct {
		JWTSecret string `mapstructure:"temp_jwt_secret"`
	}
	Mail struct {
		AppKey string `mapstructure:"app_key"`
	}
}

func LoadConfig() (config Config, err error) {
	viper.AddConfigPath("./configs")
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")

	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		return
	}

	err = viper.Unmarshal(&config)
	return
}
