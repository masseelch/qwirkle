class Pos {
  Pos(this.x, this.y)
      : assert(x != null),
        assert(y != null);

  int x;
  int y;

  @override
  int get hashCode => '$x-$y'.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Pos && x == other.x && y == other.y;

  String toJson() => '$x|$y';

  factory Pos.fromJson(String json) {
    final t = json.split('|');

    return Pos(int.parse(t.first), int.parse(t.last));
  }
}