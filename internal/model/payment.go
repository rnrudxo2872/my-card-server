package model

import "gorm.io/gorm"

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