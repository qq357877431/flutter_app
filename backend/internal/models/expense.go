package models

import (
	"time"
)

type Expense struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	UserID    uint      `gorm:"index;not null" json:"user_id"`
	Amount    float64   `gorm:"not null" json:"amount"`
	Category  string    `gorm:"not null" json:"category"`
	Note      string    `json:"note"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
