package handlers

import (
	"net/http"

	"daily-planner-backend/internal/database"
	"daily-planner-backend/internal/models"

	"github.com/gin-gonic/gin"
)

type CreateReminderRequest struct {
	ReminderType  string `json:"reminder_type" binding:"required"`
	ScheduledTime string `json:"scheduled_time" binding:"required"`
	Content       string `json:"content"`
}

type UpdateReminderRequest struct {
	ScheduledTime string `json:"scheduled_time"`
	Content       string `json:"content"`
	IsEnabled     *bool  `json:"is_enabled"`
}

func GetReminders(c *gin.Context) {
	userID := c.GetUint("userID")

	var reminders []models.Reminder
	if err := database.GetDB().Where("user_id = ?", userID).Find(&reminders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusOK, reminders)
}

func CreateReminder(c *gin.Context) {
	userID := c.GetUint("userID")

	var req CreateReminderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "validation error", "details": err.Error()})
		return
	}

	reminder := models.Reminder{
		UserID:        userID,
		ReminderType:  req.ReminderType,
		ScheduledTime: req.ScheduledTime,
		Content:       req.Content,
		IsEnabled:     true,
	}

	if err := database.GetDB().Create(&reminder).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusCreated, reminder)
}

func UpdateReminder(c *gin.Context) {
	userID := c.GetUint("userID")
	reminderID := c.Param("id")

	var reminder models.Reminder
	if err := database.GetDB().First(&reminder, reminderID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "resource not found"})
		return
	}

	if reminder.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "access denied"})
		return
	}

	var req UpdateReminderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "validation error", "details": err.Error()})
		return
	}

	updates := make(map[string]interface{})
	if req.ScheduledTime != "" {
		updates["scheduled_time"] = req.ScheduledTime
	}
	if req.Content != "" {
		updates["content"] = req.Content
	}
	if req.IsEnabled != nil {
		updates["is_enabled"] = *req.IsEnabled
	}

	if err := database.GetDB().Model(&reminder).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusOK, reminder)
}

func DeleteReminder(c *gin.Context) {
	userID := c.GetUint("userID")
	reminderID := c.Param("id")

	var reminder models.Reminder
	if err := database.GetDB().First(&reminder, reminderID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "resource not found"})
		return
	}

	if reminder.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "access denied"})
		return
	}

	if err := database.GetDB().Delete(&reminder).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "reminder deleted"})
}
