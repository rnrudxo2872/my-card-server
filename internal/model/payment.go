package model

import (
	"errors"

	"gorm.io/gorm"
)

type PaymentStatus string

const (
	StatusComplete PaymentStatus = "complete"
	StatusFailed    PaymentStatus = "failed"
	StatusCancelled PaymentStatus = "cancelled"
	StatusPending   PaymentStatus = "pending"
)

type Payment struct {
	gorm.Model
	Amount	int64	`json:"amount" gorm:"not null"`
	Status PaymentStatus `json:"status" gorm:"not null"`
}

func (status PaymentStatus)IsValid() bool {
	switch status {
		case StatusComplete, StatusFailed, StatusCancelled, StatusPending:
			return true
		default:
			return false
	}
}

func (p *Payment)BeforeCreate(tx *gorm.DB) error {
	if !p.Status.IsValid() {
		return errors.New("invalid payment status: " + string(p.Status))
	}
	return nil
}