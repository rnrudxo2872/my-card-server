package handler

import (
	"log"
	"mycard-server/internal/database"
	"mycard-server/internal/model"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
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
	status, statusOk := c.GetQuery("status")
	limit := c.DefaultQuery("limit", "10")
	page := c.DefaultQuery("page", "1")	

	limitInt, err := strconv.Atoi(limit)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "limit must be an integer"})
		return
	}

	pageInt, err := strconv.Atoi(page)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "page must be an integer"})
		return
	}

	offset := (pageInt - 1) * limitInt

	var payments []model.Payment
	var query *gorm.DB

	if(statusOk) {
		query = database.DB.Where("status = ?", status).Limit(limitInt).Offset(offset)
	} else {
		query = database.DB.Limit(limitInt).Offset(offset)
	}

	result := query.Find(&payments)

	if result.Error != nil {
		log.Println("결제 목록 조회 실패", result.Error)
		c.JSON(http.StatusBadRequest, gin.H{"error": "결제 조회 실패"})
		return
	}

	c.JSON(http.StatusOK, payments)
}