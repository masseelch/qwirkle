package qwirkle

// Existing shapes
const (
	None = Shape(iota)
	Circle
	Diamond
	Plus
	Spade
	Square
	Star
)

// Existing colors
const (
	Blue = Color(iota)
	Green
	Orange
	Purple
	Red
	Yellow
)

var (
	Shapes = [...]Shape{Circle, Diamond, Plus, Spade, Square, Star}
	Colors = [...]Color{Blue, Green, Orange, Purple, Red, Yellow}
)

type (
	// Color information of a symbol
	Color int
	// Shape information of a symbol
	Shape int
	// A Cube has a color and a shape after being rolled.
	Cube struct {
		Color  Color `json:"color"`
		Shape  Shape `json:"shape"`
		Locked bool  `json:"locked"`
	}
)
