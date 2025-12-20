package database

import (
	"daily-planner-backend/internal/config"
	"daily-planner-backend/internal/models"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Init(cfg *config.Config) error {
	var err error
	DB, err = gorm.Open(mysql.Open(cfg.GetDSN()), &gorm.Config{})
	if err != nil {
		return err
	}
	return nil
}

func AutoMigrate() error {
	return DB.AutoMigrate(
		&models.User{},
		&models.Plan{},
		&models.Expense{},
		&models.Reminder{},
	)
}

func GetDB() *gorm.DB {
	return DB
}
