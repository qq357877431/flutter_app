package models

import (
	"time"
)

type Plan struct {
	ID            uint      `gorm:"primaryKey" json:"id"`
	UserID        uint      `gorm:"index;not null" json:"user_id"`
	Content       string    `gorm:"not null" json:"content"`
	ExecutionDate time.Time `gorm:"index;not null" json:"execution_date"`
	Status        string    `gorm:"default:'pending'" json:"status"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}
