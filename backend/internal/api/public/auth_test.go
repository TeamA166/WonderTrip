package public

import (
	"testing"

	"github.com/TeamA166/WonderTrip/internal/core"
)

func TestSanitizeEmail(t *testing.T) {
	got := sanitizeEmail("  Test@Example.COM ")
	want := "test@example.com"

	if got != want {
		t.Fatalf("sanitizeEmail() = %s, want %s", got, want)
	}
}

func TestValidateRegisterRequest(t *testing.T) {
	testCases := []struct {
		name    string
		req     core.RegisterRequest
		wantErr bool
	}{
		{
			name: "valid",
			req: core.RegisterRequest{
				Email:    "user@example.com",
				Password: "123456",
			},
			wantErr: false,
		},
		{
			name: "missing email",
			req: core.RegisterRequest{
				Email:    "",
				Password: "123456",
			},
			wantErr: true,
		},
		{
			name: "short password",
			req: core.RegisterRequest{
				Email:    "user@example.com",
				Password: "123",
			},
			wantErr: true,
		},
	}

	for _, tc := range testCases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			err := validateRegisterRequest(tc.req)
			if tc.wantErr && err == nil {
				t.Fatalf("expected error but got nil")
			}

			if !tc.wantErr && err != nil {
				t.Fatalf("expected nil error but got %v", err)
			}
		})
	}
}
