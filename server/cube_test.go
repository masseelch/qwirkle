package qwirkle

import (
	testify "github.com/stretchr/testify/require"
	"testing"
)

func TestConstants(t *testing.T) {
	require := testify.New(t)

	// Shapes
	require.Equal(Shape(0), None)
	require.Equal(Shape(1), Circle)
	require.Equal(Shape(2), Diamond)
	require.Equal(Shape(3), Plus)
	require.Equal(Shape(4), Spade)
	require.Equal(Shape(5), Square)
	require.Equal(Shape(6), Star)

	// Color
	require.Equal(Color(0), Blue)
	require.Equal(Color(1), Green)
	require.Equal(Color(2), Orange)
	require.Equal(Color(3), Purple)
	require.Equal(Color(4), Red)
	require.Equal(Color(5), Yellow)
}
