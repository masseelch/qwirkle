package qwirkle

import (
	testify "github.com/stretchr/testify/require"
	"testing"
)

func TestPlayer_HasCube(t *testing.T) {
	require := testify.New(t)

	blue := Cube{Color: Blue, Shape: None}
	orangeCircle := Cube{Color: Orange, Shape: Circle}
	blueDiamon := Cube{Color: Blue, Shape: Diamond}
	redSpade := Cube{Color: Red, Shape: Spade}

	p := Player{Cubes: []Cube{blue, orangeCircle, blueDiamon, redSpade}}

	require.True(p.HasCube(blue))
	require.True(p.HasCube(orangeCircle))
	require.True(p.HasCube(blueDiamon))
	require.True(p.HasCube(redSpade))

	require.False(p.HasCube(Cube{Shape: Circle}))
	require.False(p.HasCube(Cube{Color: Orange}))
	require.False(p.HasCube(Cube{Color: Orange, Shape: Diamond}))
}

func TestPlayers_NextPlayer(t *testing.T) {
	require := testify.New(t)

	ps := Players{&Player{ID: "one"}}
	require.Equal("one", ps.NextPlayer(ps[0]).ID)

	ps = Players{
		&Player{ID: "one"},
		&Player{ID: "two"},
		&Player{ID: "three"},
	}

	require.Equal("two", ps.NextPlayer(ps[0]).ID)
	require.Equal("three", ps.NextPlayer(ps[1]).ID)
	require.Equal("one", ps.NextPlayer(ps[2]).ID)
}
