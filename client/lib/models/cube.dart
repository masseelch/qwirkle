import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cube.g.dart';

enum Shape {
  @JsonValue(0)
  none,
  @JsonValue(1)
  circle,
  @JsonValue(2)
  diamond,
  @JsonValue(3)
  plus,
  @JsonValue(4)
  spade,
  @JsonValue(5)
  square,
  @JsonValue(6)
  star,
}

enum CubeColor {
  @JsonValue(0)
  Blue,
  @JsonValue(1)
  Green,
  @JsonValue(2)
  Orange,
  @JsonValue(3)
  Purple,
  @JsonValue(4)
  Red,
  @JsonValue(5)
  Yellow,
}

@JsonSerializable()
class Cube {
  Cube({
    @required this.color,
    @required this.shape,
    @required this.locked,
  })  : assert(color != null),
        assert(shape != null),
        assert(locked != null);

  CubeColor color;
  Shape shape;
  bool locked;

  void lock() => locked = true;

  void unlock() => locked = false;

  @override
  int get hashCode => [color.hashCode, shape.hashCode].hashCode;

  @override
  bool operator ==(Object other) =>
      other is Cube && color == other.color && shape == other.shape;

  Cube copyWith({bool locked}) => Cube(
        color: color,
        shape: shape,
        locked: locked ?? this.locked,
      );

  String toString() => 'Cube(color: $color, shape: $shape)';

  factory Cube.fromJson(Map<String, dynamic> json) => _$CubeFromJson(json);

  Map<String, dynamic> toJson() => _$CubeToJson(this);
}
