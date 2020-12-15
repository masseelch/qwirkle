// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) {
  return Game()
    ..id = json['id'] as String
    ..players = (json['players'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : Player.fromJson(e as Map<String, dynamic>)),
    )
    ..placed = const PlacedConverter()
        .fromJson(json['placed'] as Map<String, dynamic>);
}

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'id': instance.id,
      'players': instance.players?.map((k, e) => MapEntry(k, e?.toJson())),
      'placed': const PlacedConverter().toJson(instance.placed),
    };
