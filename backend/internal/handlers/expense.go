package handlers

import (
	"net/http"

	"daily-planner-backend/internal/database"
	"daily-planner-backend/internal/models"

	"github.com/gin-gonic/gin"
)

type CreateExpenseRequest struct {
	Amount   float64 `json:"amount" binding:"required"`
	Category string  `json:"category" binding:"required"`
	Note     string  `json:"note"`
}

type UpdateExpenseRequest struct {
	Amount   float64 `json:"amount"`
	Category string  `json:"category"`
	Note     string  `json:"note"`
}

func GetExpenses(c *gin.Context) {
	userID := c.GetUint("userID")

	var expenses []models.Expense
	if err := database.GetDB().Where("user_id = ?", userID).Order("created_at DESC").Find(&expenses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	var total float64
	for _, e := range expenses {
		total += e.Amount
	}

	c.JSON(http.StatusOK, gin.H{
		"total":    total,
		"expenses": expenses,
	})
}

func CreateExpense(c *gin.Context) {
	userID := c.GetUint("userID")

	var req CreateExpenseRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "validation error", "details": err.Error()})
		return
	}

	expense := models.Expense{
		UserID:   userID,
		Amount:   req.Amount,
		Category: req.Category,
		Note:     req.Note,
	}

	if err := database.GetDB().Create(&expense).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusCreated, expense)
}

func UpdateExpense(c *gin.Context) {
	userID := c.GetUint("userID")
	expenseID := c.Param("id")

	var expense models.Expense
	if err := database.GetDB().First(&expense, expenseID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "resource not found"})
		return
	}

	if expense.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "access denied"})
		return
	}

	var req UpdateExpenseRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "validation error", "details": err.Error()})
		return
	}

	updates := make(map[string]interface{})
	if req.Amount != 0 {
		updates["amount"] = req.Amount
	}
	if req.Category != "" {
		updates["category"] = req.Category
	}
	if req.Note != "" {
		updates["note"] = req.Note
	}

	if err := database.GetDB().Model(&expense).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusOK, expense)
}

func DeleteExpense(c *gin.Context) {
	userID := c.GetUint("userID")
	expenseID := c.Param("id")

	var expense models.Expense
	if err := database.GetDB().First(&expense, expenseID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "resource not found"})
		return
	}

	if expense.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "access denied"})
		return
	}

	if err := database.GetDB().Delete(&expense).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "expense deleted"})
}
