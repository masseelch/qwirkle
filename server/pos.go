package qwirkle

// import (
// 	"encoding/json"
// 	"fmt"
// 	"strconv"
// 	"strings"
// )
//
// // position on a plan
//
//
// func (p Pos) MarshalJSON() ([]byte, error) {
// 	return json.Marshal(fmt.Sprintf("%d|%d", p.X, p.Y))
// }
//
// func (p *Pos) UnmarshalJSON(data []byte) error {
// 	var s string
// 	if err := json.Unmarshal(data, &s); err != nil {
// 		return err
// 	}
//
// 	tmp := strings.Split(s, "|")
// 	x, err := strconv.Atoi(tmp[0])
// 	if err != nil {
// 		return err
// 	}
//
// 	y, err := strconv.Atoi(tmp[1])
// 	if err != nil {
// 		return err
// 	}
//
// 	p.X, p.Y = x, y
//
// 	return nil
// }
