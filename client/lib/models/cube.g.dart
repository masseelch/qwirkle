// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cube.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cube _$CubeFromJson(Map<String, dynamic> json) {
  return Cube(
    color: _$enumDecodeNullable(_$ColorEnumMap, json['color']),
    shape: _$enumDecodeNullable(_$ShapeEnumMap, json['shape']),
  );
}

Map<String, dynamic> _$CubeToJson(Cube instance) => <String, dynamic>{
      'color': _$ColorEnumMap[instance.color],
      'shape': _$ShapeEnumMap[instance.shape],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$ColorEnumMap = {
  CubeColor.Blue: 0,
  CubeColor.Green: 1,
  CubeColor.Orange: 2,
  CubeColor.Purple: 3,
  CubeColor.Red: 4,
  CubeColor.Yellow: 5,
};

const _$ShapeEnumMap = {
  Shape.none: 0,
  Shape.circle: 1,
  Shape.diamond: 2,
  Shape.plus: 3,
  Shape.spade: 4,
  Shape.square: 5,
  Shape.star: 6,
};
