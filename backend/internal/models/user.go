package models

import (
	"time"
)

type User struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	PhoneNumber string    `gorm:"type:varchar(20);uniqueIndex;not null" json:"phone_number"`
	Password    string    `gorm:"type:varchar(255);not null" json:"-"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
