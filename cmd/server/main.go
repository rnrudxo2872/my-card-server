package main

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"mycard-server/internal/database"
	"mycard-server/internal/handler"
)

func main() {
	database.Connect()

	r := gin.Default()
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})

	})

	r.POST("/payments", handler.CreatePayment)

	if err := r.Run(":8080"); err != nil {
		panic(err)
	}
}