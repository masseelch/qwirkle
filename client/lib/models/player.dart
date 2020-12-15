import 'package:json_annotation/json_annotation.dart';

import 'cube.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  Player();

  String id;
  List<Cube> cubes;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
