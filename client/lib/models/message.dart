import 'package:client/models/game.dart';
import 'package:client/models/pos.dart';

import 'cube.dart';

enum MessageType {
  drawCubes,
  swapCubes,
  placeCubes,
  rollCubes,
}

extension MessageTypeExtension on MessageType {
  String toJson() {
    switch (this) {
      case MessageType.drawCubes:
        return 'draw_cubes';
      case MessageType.swapCubes:
        return 'swap_cubes';
      case MessageType.placeCubes:
        return 'place_cubes';
      case MessageType.rollCubes:
        return 'roll_cubes';
      default:
        throw UnimplementedError();
    }
  }
}

MessageType _MessageTypeFromJson(String json) {
  switch (json) {
    case 'draw_cubes':
      return MessageType.drawCubes;
    case 'swap_cubes':
      return MessageType.swapCubes;
    case 'place_cubes':
      return MessageType.placeCubes;
    case 'roll_cubes':
      return MessageType.rollCubes;
    default:
      throw UnimplementedError();
  }
}

class Message {
  Message({
    this.type,
    this.meta,
    this.data,
  });

  MessageType type;
  Map<String, String> meta;
  dynamic data;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        type: _MessageTypeFromJson(json['type']),
        meta: (json['meta'] as Map<String, dynamic>)?.map(
          (k, e) => MapEntry(k, e as String),
        ),
        data: json['data'], // todo
      );

  Map<String, dynamic> toJson() {
    final j = <String, dynamic>{
      'type': this.type.toJson(),
      'meta': this.meta,
    };

    if (data is Map<Pos, Cube>) {
      j['data'] = PlacedConverter().toJson(data);
    } else {
      j['data'] = data;
    }

    return j;
  }
}
