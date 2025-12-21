package main

import (
	"log"

	"daily-planner-backend/internal/config"
	"daily-planner-backend/internal/database"
	"daily-planner-backend/internal/handlers"
	"daily-planner-backend/internal/middleware"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	cfg := config.Load()

	middleware.SetJWTSecret(cfg.JWTSecret)

	if err := database.Init(cfg); err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	if err := database.AutoMigrate(); err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}

	r := gin.Default()

	// CORS 配置
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		AllowCredentials: true,
	}))

	// Auth routes (public)
	auth := r.Group("/api/auth")
	{
		auth.POST("/register", handlers.Register)
		auth.POST("/login", handlers.Login)
	}

	// Admin routes (public login)
	r.POST("/api/admin/login", handlers.AdminLogin)

	// Admin protected routes
	admin := r.Group("/api/admin")
	admin.Use(middleware.AdminMiddleware())
	{
		admin.GET("/users", handlers.GetUsers)
		admin.POST("/users", handlers.AdminCreateUser)
		admin.PUT("/users/:id/password", handlers.AdminResetPassword)
	}

	// Protected routes
	api := r.Group("/api")
	api.Use(middleware.JWTMiddleware())
	{
		// Token验证
		api.GET("/auth/verify", handlers.VerifyToken)

		// 用户信息
		api.GET("/user/profile", handlers.GetProfile)
		api.PUT("/user/profile", handlers.UpdateProfile)
		api.PUT("/user/password", handlers.ChangePassword)

		// Plans
		api.GET("/plans", handlers.GetPlans)
		api.POST("/plans", handlers.CreatePlan)
		api.PUT("/plans/:id", handlers.UpdatePlan)
		api.DELETE("/plans/:id", handlers.DeletePlan)

		// Expenses
		api.GET("/expenses", handlers.GetExpenses)
		api.POST("/expenses", handlers.CreateExpense)
		api.PUT("/expenses/:id", handlers.UpdateExpense)
		api.DELETE("/expenses/:id", handlers.DeleteExpense)

		// Reminders
		api.GET("/reminders", handlers.GetReminders)
		api.POST("/reminders", handlers.CreateReminder)
		api.PUT("/reminders/:id", handlers.UpdateReminder)
		api.DELETE("/reminders/:id", handlers.DeleteReminder)
	}

	log.Printf("Server starting on port %s", cfg.ServerPort)
	if err := r.Run(":" + cfg.ServerPort); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
