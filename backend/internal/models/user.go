package models

import (
	"time"
)

type User struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	Username    string    `gorm:"type:varchar(50);uniqueIndex" json:"username"`
	PhoneNumber string    `gorm:"type:varchar(20);uniqueIndex;not null" json:"phone_number"`
	Password    string    `gorm:"type:varchar(255);not null" json:"-"`
	Nickname    string    `gorm:"type:varchar(50);default:''" json:"nickname"`
	Avatar      string    `gorm:"type:varchar(500);default:''" json:"avatar"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
