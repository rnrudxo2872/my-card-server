package handler

import (
	"log"
	"mycard-server/internal/database"
	"mycard-server/internal/model"
	"net/http"

	"github.com/gin-gonic/gin"
)

type CreatePaymentRequest struct {
	Amount int64	`json:"amount" binding:"required"`
	Status model.PaymentStatus	`json:"status" binding:"required"`
}

func CreatePayment(c *gin.Context) {
	var req CreatePaymentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	} 

	payment := model.Payment{
		Amount: req.Amount,
		Status: req.Status,
	}

	result := database.DB.Create(&payment)
	if result.Error != nil {
		log.Printf("결제 기록 실패: %v", result.Error)
		c.JSON(http.StatusBadRequest, gin.H{"error": "결제 기록 실패"})
		return
	}

	c.JSON(http.StatusCreated, payment)
}

func GetPayments(c *gin.Context) {
	var payments []model.Payment

	result := database.DB.Find(&payments)
	if result.Error != nil {
		log.Println("결제 목록 조회 실패", result.Error)
		c.JSON(http.StatusBadRequest, gin.H{"error": "결제 조회 실패"})
		return
	}

	c.JSON(http.StatusOK, payments)
}