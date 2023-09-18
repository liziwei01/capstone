/*
 * @Author: liziwei01
 * @Date: 2023-05-09 22:58:00
 * @LastEditors: liziwei01
 * @LastEditTime: 2023-09-17 21:20:02
 * @Description: file content
 */

package httpapi

import (
	"net/http"

	"github.com/liziwei01/capstone/gin-ichat-appui/middleware"
	chatRouters "github.com/liziwei01/capstone/gin-ichat-appui/modules/chat/routers"

	"github.com/gin-gonic/gin"
)

/**
 * @description: start http server and start listening
 * @param {*}
 * @return {*}
 */
func InitRouters(handler *gin.Engine) {
	// 跨域问题
	handler.Use(middleware.CrossRegionMiddleware())

	// init routers
	chatRouters.Init(handler)

	// safe router
	handler.GET("/", func(ctx *gin.Context) {
		ctx.String(http.StatusOK, "Hello! THis is iChat.")
	})
}
