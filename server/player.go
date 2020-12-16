package qwirkle

type Player struct {
	// Nickname of the player.
	ID string `json:"id"`
	// The current score of the player.
	Score int `json:"score"`
	// The current cubes this player has on his board.
	Cubes []Cube `json:"cubes"`
}

func (p Player) HasCube(c Cube) bool {
	for _, _c := range p.Cubes {
		if _c.Color == c.Color && _c.Shape == c.Shape {
			return true
		}
	}

	return false
}
