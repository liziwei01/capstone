/*
 * @Author: liziwei01
 * @Date: 2023-05-11 19:26:30
 * @LastEditors: liziwei01
 * @LastEditTime: 2023-09-17 21:22:26
 * @Description: file content
 */
package controllers

import (
	"github.com/gin-gonic/gin"
	getModel "github.com/liziwei01/capstone/gin-ichat-appui/modules/chat/model"
	getService "github.com/liziwei01/capstone/gin-ichat-appui/modules/chat/services"
	"github.com/liziwei01/gin-lib/library/response"
)

func Record(ctx *gin.Context) {
	inputs, hasError := getRecordPars(ctx)
	if hasError {
		response.StdInvalidParams(ctx)
		return
	}

	res, err := getService.Record(ctx, inputs)
	if err != nil {
		response.StdFailed(ctx, err.Error())
		return
	}

	response.StdSuccess(ctx, res)
}

func getRecordPars(ctx *gin.Context) (getModel.RecordPars, bool) {
	var inputs getModel.RecordPars

	err := ctx.ShouldBind(&inputs)
	if err != nil {
		return inputs, true
	}

	return inputs, false
}
