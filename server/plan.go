package qwirkle

type (
	// plan to play on
	Plan struct {
		Reserve []Cube
		Played map[Pos]Cube
	}
)

