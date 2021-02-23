package qwirkle

type (
	// Players of a game.
	Players []*Player
	// Player in a game.
	Player struct {
		// Nickname of the player.
		ID string `json:"id"`
		// The current score of the player.
		Score int `json:"score"`
		// The current cubes this player has on his board.
		Cubes []Cube `json:"cubes"`
	}
)

func (p Player) HasCube(c Cube) bool {
	for _, _c := range p.Cubes {
		if _c.Color == c.Color && _c.Shape == c.Shape {
			return true
		}
	}

	return false
}

func (ps Players) GetByNickname(n string) *Player {
	for _, p := range ps {
		if n == p.ID {
			return p
		}
	}

	return nil
}

func (ps Players) NextPlayer(p *Player) *Player {
	i := 0

	// Index of the currently active player.
	for j, _p := range ps {
		if _p.ID == p.ID {
			i = j
			break
		}
	}

	// If the current player is the last one in the list of players the next player is the first one.
	if i == len(ps)-1 {
		return ps[0]
	}

	return ps[i+1]
}

func (ps *Players) Add(p *Player) {
	*ps = append(*ps, p)
}
