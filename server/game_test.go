package qwirkle

import (
	testify "github.com/stretchr/testify/require"
	"testing"
)

func TestNewGame(t *testing.T) {
	require := testify.New(t)

	g := NewGame()

	require.NotNil(g.rand)
	require.NotZero(g.ID)
	require.NotNil(g.Players)
	require.Len(g.Players, 0)
	require.Len(g.Cubes, 90)

	for c := Blue; c <= Yellow; c++ {
		require.Contains(g.Cubes, Cube{Color: c})
	}
}

func TestGame_DrawCube(t *testing.T) {
	require := testify.New(t)

	g := NewGame()

	c := g.drawCube()
	require.Len(g.Cubes, 89)
	require.NotEqual(None, c.Shape)

	c = g.drawCube()
	require.Len(g.Cubes, 88)
	require.NotEqual(None, c.Shape)
}

func TestGame_DrawCubes(t *testing.T) {
	require := testify.New(t)

	g := NewGame()

	cs := g.DrawCubes(3)
	require.Len(g.Cubes, 87)
	for _, c := range cs {
		require.NotEqual(None, c.Shape)
	}

	cs = g.DrawCubes(15)
	require.Len(g.Cubes, 72)
	for _, c := range cs {
		require.NotEqual(None, c.Shape)
	}

	cs = g.DrawCubes(1)
	require.Len(g.Cubes, 71)
	for _, c := range cs {
		require.NotEqual(None, c.Shape)
	}

	cs = g.DrawCubes(71)
	require.Len(g.Cubes, 0)
	for _, c := range cs {
		require.NotEqual(None, c.Shape)
	}
}

func TestGame_AddCubes(t *testing.T) {
	require := testify.New(t)

	g := NewGame()

	cs := make([]Cube, 10)
	for i := range cs {
		cs[i] = Cube{}
	}

	g.AddCubes(cs)

	require.Len(g.Cubes, 100)
}

func TestGame_RollCube(t *testing.T) {
	require := testify.New(t)

	g := NewGame()
	c := Cube{}

	require.Equal(None, c.Shape)

	for i := 0; i < 100; i++ {
		g.RollCube(&c)
		require.NotEqual(None, c.Shape)
		require.Contains(Shapes, c.Shape)
	}
}
