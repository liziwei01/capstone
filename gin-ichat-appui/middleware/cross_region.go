package middleware

import (
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func CrossRegionMiddleware() gin.HandlerFunc {
	return cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET"},
		AllowHeaders:     []string{"Origin", "Content-Length", "Content-Type", "Code"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	})
}
