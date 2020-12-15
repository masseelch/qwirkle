import 'package:json_annotation/json_annotation.dart';

import 'cube.dart';
import 'player.dart';
import 'pos.dart';

part 'game.g.dart';

@JsonSerializable()
class Game {
  Game();

  String id;
  Map<String, Player> players;
  @PlacedConverter()
  Map<Pos, Cube> placed;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  Map<String, dynamic> toJson() => _$GameToJson(this);
}

class PlacedConverter implements JsonConverter<Map<Pos, Cube>, Map<String, dynamic>> {
  const PlacedConverter();

  @override
  Map<Pos, Cube> fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    final Map<Pos, Cube> r = {};

    json.forEach((key, value) {
      r[Pos.fromJson(key)] = Cube.fromJson(value);
    });

    return r;
  }

  @override
  Map<String, dynamic> toJson(Map<Pos, Cube> object) {
    if (object == null) {
      return null;
    }

    final r = {};

    object.forEach((key, value) {
      r[key.toJson()] = value.toJson();
    });

    return r;
  }
}