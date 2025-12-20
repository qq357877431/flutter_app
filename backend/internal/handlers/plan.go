package handlers

import (
	"net/http"
	"time"

	"daily-planner-backend/internal/database"
	"daily-planner-backend/internal/models"

	"github.com/gin-gonic/gin"
)

type CreatePlanRequest struct {
	Content       string `json:"content" binding:"required"`
	ExecutionDate string `json:"execution_date" binding:"required"`
}

type UpdatePlanRequest struct {
	Content string `json:"content"`
	Status  string `json:"status"`
}

func GetPlans(c *gin.Context) {
	userID := c.GetUint("userID")
	dateStr := c.Query("date")

	var plans []models.Plan
	query := database.GetDB().Where("user_id = ?", userID)

	if dateStr != "" {
		date, err := time.Parse("2006-01-02", dateStr)
		if err == nil {
			nextDay := date.AddDate(0, 0, 1)
			query = query.Where("execution_date >= ? AND execution_date < ?", date, nextDay)
		}
	}

	if err := query.Order("execution_date ASC").Find(&plans).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusOK, plans)
}

func CreatePlan(c *gin.Context) {
	userID := c.GetUint("userID")

	var req CreatePlanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "validation error", "details": err.Error()})
		return
	}

	executionDate, err := time.Parse("2006-01-02", req.ExecutionDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid date format, use YYYY-MM-DD"})
		return
	}

	plan := models.Plan{
		UserID:        userID,
		Content:       req.Content,
		ExecutionDate: executionDate,
		Status:        "pending",
	}

	if err := database.GetDB().Create(&plan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusCreated, plan)
}

func UpdatePlan(c *gin.Context) {
	userID := c.GetUint("userID")
	planID := c.Param("id")

	var plan models.Plan
	if err := database.GetDB().First(&plan, planID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "resource not found"})
		return
	}

	if plan.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "access denied"})
		return
	}

	var req UpdatePlanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "validation error", "details": err.Error()})
		return
	}

	updates := make(map[string]interface{})
	if req.Content != "" {
		updates["content"] = req.Content
	}
	if req.Status != "" {
		updates["status"] = req.Status
	}

	if err := database.GetDB().Model(&plan).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusOK, plan)
}

func DeletePlan(c *gin.Context) {
	userID := c.GetUint("userID")
	planID := c.Param("id")

	var plan models.Plan
	if err := database.GetDB().First(&plan, planID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "resource not found"})
		return
	}

	if plan.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "access denied"})
		return
	}

	if err := database.GetDB().Delete(&plan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "plan deleted"})
}
