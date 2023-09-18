/*
 * @Author: liziwei01
 * @Date: 2022-04-12 11:15:31
 * @LastEditors: liziwei01
 * @LastEditTime: 2023-09-17 21:14:46
 * @Description: file content
 */
package model

type RecordPars struct {
	Secret string `json:"secret" form:"secret" binding:"required"`
}
