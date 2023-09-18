/*
 * @Author: liziwei01
 * @Date: 2023-05-11 00:25:59
 * @LastEditors: liziwei01
 * @LastEditTime: 2023-05-11 00:53:44
 * @Description: file content
 */
package totp

import (
	"crypto/sha1"
	"fmt"
	"strconv"
	"time"
)

func Validate(secret string, code string) bool {
	return validate(secret, code, time.Now().Truncate(time.Minute/2).Unix()) ||
		validate(secret, code, time.Now().Truncate(time.Minute/2).Unix()-30)
}

func validate(secret string, code string, time int64) bool {
	return code == getHashedString(secret, time)
}

func getHashedString(s string, n int64) string {
	// 将s和n组合成一个字符串
	input := s + strconv.FormatInt(n, 10)

	// 计算SHA-1哈希值
	h := sha1.Sum([]byte(input))

	// 将哈希值的前6个字节解析为int64类型
	result := int64(h[0])<<40 | int64(h[1])<<32 | int64(h[2])<<24 | int64(h[3])<<16 | int64(h[4])<<8 | int64(h[5])

	// 对10^6取模，保留6位数字
	return fmt.Sprintf("%06d", result%1000000)
}