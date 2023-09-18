/*
 * @Author: liziwei01
 * @Date: 2023-05-11 19:37:28
 * @LastEditors: liziwei01
 * @LastEditTime: 2023-09-17 21:15:35
 * @Description: file content
 */
package services

import (
	"context"

	chatModel "github.com/liziwei01/capstone/gin-ichat-appui/modules/chat/model"
)

func Record(ctx context.Context, pars chatModel.RecordPars) (map[string]interface{}, error) {

	return map[string]interface{}{
		"list":  "filesBase(files[start:end])",
		"count": 0,
	}, nil
}
