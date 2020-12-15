package qwirkle

import (
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
)

type (
	Pos struct {
		X int
		Y int
	}
	Placed map[Pos]Cube
)

func (p Placed) MarshalJSON() ([]byte, error) {
	j := make(map[string]Cube)

	for pos, c := range p {
		j[fmt.Sprintf("%d|%d", pos.X, pos.Y)] = c
	}

	return json.Marshal(j)
}

func (p *Placed) UnmarshalJSON(data []byte) error {
	j := make(map[string]Cube)

	if err := json.Unmarshal(data, &j); err != nil {
		return err
	}

	r := make(map[Pos]Cube)
	for pos, c := range j {

		tmp := strings.Split(pos, "|")
		x, err := strconv.Atoi(tmp[0])
		if err != nil {
			return err
		}

		y, err := strconv.Atoi(tmp[1])
		if err != nil {
			return err
		}

		r[Pos{x, y}] = c
	}

	*p = r

	return nil
}
