package models

import (
	"time"
)

type Reminder struct {
	ID            uint      `gorm:"primaryKey" json:"id"`
	UserID        uint      `gorm:"index;not null" json:"user_id"`
	ReminderType  string    `gorm:"not null" json:"reminder_type"`
	ScheduledTime string    `gorm:"not null" json:"scheduled_time"`
	Content       string    `json:"content"`
	IsEnabled     bool      `gorm:"default:true" json:"is_enabled"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}
