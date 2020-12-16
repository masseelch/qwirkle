// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return Player()
    ..id = json['id'] as String
    ..score = json['score'] as int
    ..cubes = (json['cubes'] as List)
        ?.map(
            (e) => e == null ? null : Cube.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'score': instance.score,
      'cubes': instance.cubes?.map((e) => e?.toJson())?.toList(),
    };
