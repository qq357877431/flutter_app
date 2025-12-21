package handlers

import (
	"net/http"

	"daily-planner-backend/internal/database"
	"daily-planner-backend/internal/middleware"
	"daily-planner-backend/internal/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// 硬编码管理员凭据
const (
	AdminUsername = "nagenanren"
	AdminPassword = "nagenanren123"
)

type AdminLoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type AdminCreateUserRequest struct {
	Username    string `json:"username" binding:"required,min=3,max=50"`
	PhoneNumber string `json:"phone_number" binding:"required"`
	Password    string `json:"password" binding:"required,min=6"`
}

type AdminResetPasswordRequest struct {
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

// UserListItem 用户列表项（不含敏感数据）
type UserListItem struct {
	ID          uint   `json:"id"`
	Username    string `json:"username"`
	PhoneNumber string `json:"phone_number"`
	Nickname    string `json:"nickname"`
	Avatar      string `json:"avatar"`
	CreatedAt   string `json:"created_at"`
}

// AdminLogin 管理员登录
func AdminLogin(c *gin.Context) {
	var req AdminLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "validation error", "details": err.Error()})
		return
	}

	// 验证硬编码的管理员凭据
	if req.Username != AdminUsername || req.Password != AdminPassword {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	// 生成管理员 token（使用特殊的 ID 0 表示管理员）
	token, err := middleware.GenerateToken(0)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "login successful",
		"token":   token,
		"admin": gin.H{
			"username": AdminUsername,
		},
	})
}

// GetUsers 获取用户列表（管理员专用）
func GetUsers(c *gin.Context) {
	var users []models.User
	if err := database.GetDB().Order("created_at DESC").Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch users"})
		return
	}

	// 转换为不含敏感数据的列表
	userList := make([]UserListItem, len(users))
	for i, user := range users {
		userList[i] = UserListItem{
			ID:          user.ID,
			Username:    user.Username,
			PhoneNumber: user.PhoneNumber,
			Nickname:    user.Nickname,
			Avatar:      user.Avatar,
			CreatedAt:   user.CreatedAt.Format("2006-01-02 15:04:05"),
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"users": userList,
		"total": len(userList),
	})
}

// AdminCreateUser 管理员创建用户
func AdminCreateUser(c *gin.Context) {
	var req AdminCreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "validation error", "details": err.Error()})
		return
	}

	// 检查用户名是否已存在
	var existingUser models.User
	if err := database.GetDB().Where("username = ?", req.Username).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "username already exists"})
		return
	}

	// 检查手机号是否已存在
	if err := database.GetDB().Where("phone_number = ?", req.PhoneNumber).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "phone number already registered"})
		return
	}

	// 加密密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	user := models.User{
		Username:    req.Username,
		PhoneNumber: req.PhoneNumber,
		Password:    string(hashedPassword),
	}

	if err := database.GetDB().Create(&user).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "failed to create user"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "user created successfully",
		"user": UserListItem{
			ID:          user.ID,
			Username:    user.Username,
			PhoneNumber: user.PhoneNumber,
			Nickname:    user.Nickname,
			Avatar:      user.Avatar,
			CreatedAt:   user.CreatedAt.Format("2006-01-02 15:04:05"),
		},
	})
}

// AdminResetPassword 管理员重置用户密码
func AdminResetPassword(c *gin.Context) {
	userID := c.Param("id")

	var req AdminResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "validation error", "details": err.Error()})
		return
	}

	var user models.User
	if err := database.GetDB().First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	// 加密新密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	// 更新密码
	if err := database.GetDB().Model(&user).Update("password", string(hashedPassword)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to reset password"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "password reset successfully"})
}
