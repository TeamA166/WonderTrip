package utils

import (
	"fmt"
	"net/smtp"

	"github.com/TeamA166/WonderTrip/internal/config"
)

func SendEmail(recipientEmail, subject, body string) error {
	cfg, err := config.LoadConfig()

	senderEmail := "brokefolio@gmail.com"
	appKey := cfg.Mail.AppKey
	if appKey == "" {
		return fmt.Errorf("MAIL_APP_KEY environment variable not set")
	}

	auth := smtp.PlainAuth("", senderEmail, appKey, "smtp.gmail.com")

	to := []string{recipientEmail}

	// Formatting the message
	msg := []byte(fmt.Sprintf(
		"From: %s\r\n"+
			"To: %s\r\n"+
			"Subject: %s\r\n"+
			"MIME-version: 1.0;\nContent-Type: text/plain; charset=\"UTF-8\";\n\n"+
			"%s\r\n",
		senderEmail, recipientEmail, subject, body))

	err = smtp.SendMail("smtp.gmail.com:587", auth, senderEmail, to, msg)
	if err != nil {
		return err
	}
	return nil
}
