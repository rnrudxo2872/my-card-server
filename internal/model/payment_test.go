package model

import "testing"

func TestPaymentStatusIsValid(t *testing.T) {
	validStatuses := []PaymentStatus {
		StatusComplete, StatusFailed, StatusCancelled, StatusPending,
	}

	for _, status := range validStatuses {
		if !status.IsValid() {
			t.Errorf("%s는 valid 하는데, 왜 아니죠", status)
		}
	}

	invalidStatuses := []PaymentStatus {
		"invalid", "kiki", "approved", "approve",
	}

	for _, status := range invalidStatuses {
		if status.IsValid() {
			t.Errorf("%s가 왜 적절한 값일까요", status)
		}
	}
}