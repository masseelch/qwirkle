package qwirkle

import (
	"github.com/masseelch/go-token"
	"math/rand"
	"time"
)

const (
	cubesPerColorPerGame = 15
)

type Game struct {
	rand *rand.Rand
	// The ID of the game.
	ID token.Token `json:"id"`
	// Registered players for this game.
	Players Players `json:"players"`
	// The cube store to draw new cubes from.
	Cubes []Cube `json:"-"`
	// The cubes placed on the game-plan already.
	Placed Placed ` json:"placed,omitempty"`
	// Currently active player.
	ActivePlayer *Player `json:"active_player"`
}

func NewGame() *Game {
	id, err := token.GenerateToken(6)
	if err != nil {
		panic(err)
	}

	// 15 cubes per color.
	cs := make([]Cube, cubesPerColorPerGame*len(Colors))
	for i, c := range Colors {
		for j := 0; j < cubesPerColorPerGame; j++ {
			cs[i*cubesPerColorPerGame+j] = Cube{Color: c}
		}
	}

	return &Game{
		rand:    rand.New(rand.NewSource(time.Now().Unix())),
		ID:      id,
		Cubes:   cs,
		Players: make(Players, 0),
		Placed:  make(Placed),
	}
}

func (g *Game) DrawCubes(c int) []Cube {
	cs := make([]Cube, c)

	for i := range cs {
		cs[i] = g.drawCube()
	}

	return cs
}

func (g *Game) drawCube() Cube {
	// How many cubes are left
	l := len(g.Cubes)
	// Random index
	i := g.rand.Intn(l)
	// Get the cube at index i
	c := g.Cubes[i]
	// Swap the last elem of the cubes slice to the just taken out index
	g.Cubes[i] = g.Cubes[l-1]
	// Remove the last element of cubes slice.
	g.Cubes = g.Cubes[:l-1]

	g.RollCube(&c)

	return c
}

func (g *Game) AddCubes(cs []Cube) {
	g.Cubes = append(g.Cubes, cs...)
}

func (g *Game) RollCube(c *Cube) {
	c.Shape = Shape(g.rand.Intn(int(Star)) + 1)
}

func (g *Game) Start() {
	g.ActivePlayer = g.Players[0]
}

func (g *Game) NextPlayer() {
	g.ActivePlayer = g.Players.NextPlayer(g.ActivePlayer)
}
