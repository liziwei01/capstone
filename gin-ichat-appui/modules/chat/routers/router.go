/*
 * @Author: liziwei01
 * @Date: 2022-04-12 10:45:14
 * @LastEditors: liziwei01
 * @LastEditTime: 2023-09-17 21:21:53
 * @Description: file content
 */
package routers

import (
	"github.com/gin-gonic/gin"

	apiController "github.com/liziwei01/capstone/gin-ichat-appui/modules/chat/controllers"
)

/**
 * @description: 后台路由分发
 * @param {*}
 * @return {*}
 */
func Init(router *gin.Engine) {
	chatGroup := router.Group("/chat")
	// apiGroup.Use(middleware.CheckLoginMiddleware())
	{
		chatGroup.GET("/record", apiController.Record)
	}
}
