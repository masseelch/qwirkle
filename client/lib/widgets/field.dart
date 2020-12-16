import 'package:client/models/cube.dart';
import 'package:client/models/player.dart';
import 'package:client/models/pos.dart';
import 'package:flutter/material.dart';

import 'cube.dart';

const _cubeSize = 48.0;

class Field extends StatefulWidget {
  Field({@required this.player, @required this.placed})
      : assert(player != null);

  final Player player;
  final Map<Pos, Cube> placed;

  @override
  _FieldState createState() => _FieldState();
}

class _FieldState extends State<Field> {
  _FieldDimensions _dimensions;
  List<_Cell> _placed;

  @override
  void initState() {
    super.initState();

    _dimensions = _FieldDimensions.fromPlaced(widget.placed);
    print(_dimensions);

    _placed = [];

    for (int x = _dimensions.minX; x <= _dimensions.maxX; x++) {
      for (int y = _dimensions.minY; y <= _dimensions.maxY; y++) {
        final pos = Pos(x, y);

        _placed.add(_Cell(
          pos: _dimensions.zeroIndexedPos(pos),
          cube: widget.placed[pos],
          hasNeighbour: widget.placed[pos.copyWith(y: pos.y - 1)] != null ||
              widget.placed[pos.copyWith(x: pos.x + 1)] != null ||
              widget.placed[pos.copyWith(y: pos.y + 1)] != null ||
              widget.placed[pos.copyWith(x: pos.x - 1)] != null,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor),
                ),
                // Add the padding
                width: _dimensions.sizeX * _cubeSize + 17 * 2,
                height: _dimensions.sizeY * _cubeSize + 17 * 2,
                child: Stack(
                  children: _placed
                      .map(
                        (cell) => Positioned(
                          left: cell.pos.x * _cubeSize,
                          top: cell.pos.y * _cubeSize,
                          child: Builder(
                            builder: (context) {
                              if (cell.cube != null) {
                                return CubeWidget(
                                  cube: cell.cube,
                                  width: _cubeSize,
                                );
                              }

                              if (cell.hasNeighbour) {
                                return Container(
                                  width: _cubeSize * 0.8,
                                  height: _cubeSize * 0.8,
                                  margin: EdgeInsets.all(_cubeSize * 0.1),
                                  color: Colors.grey[200],
                                );
                              }

                              return const SizedBox(
                                width: _cubeSize,
                                height: _cubeSize,
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Cell {
  _Cell({
    @required this.cube,
    @required this.pos,
    @required this.hasNeighbour,
  }) : assert(pos != null);

  final Cube cube;
  final Pos pos;
  final bool hasNeighbour;

  String toString() => '_Cell(pos: $pos, cube: $cube)';
}

class _FieldDimensions {
  _FieldDimensions._internal({
    this.minX,
    this.minY,
    this.maxX,
    this.maxY,
  });

  factory _FieldDimensions.fromPlaced(Map<Pos, Cube> placed) {
    int minX = 0, minY = 0, maxX = 0, maxY = 0;

    placed.forEach((pos, cube) {
      if (pos.x < minX) minX = pos.x;
      if (pos.y < minY) minY = pos.y;
      if (pos.x > maxX) maxX = pos.x;
      if (pos.y > maxY) maxY = pos.y;
    });

    // We add a extra cell in every direction to be able to add
    // stones in every direction.
    return _FieldDimensions._internal(
      minX: minX - 1,
      minY: minY - 1,
      maxX: maxX + 1,
      maxY: maxY + 1,
    );
  }

  final int minX;
  final int minY;
  final int maxX;
  final int maxY;

  // We need the top-left edge to be Pos(0,0). Cubes cannot be placed on the
  // outer edges of the field. If dragged onto the outer edge an extra cell in
  // that direction gets added to the field dynamically.
  int zeroIndexedX(int x) => x - minX;

  int zeroIndexedY(int y) => y - minY;

  Pos zeroIndexedPos(Pos p) => Pos(zeroIndexedX(p.x), zeroIndexedY(p.y));

  // The difference between the lowest and highest x.
  //
  // Adds 1 since a Pos(0,0) means we have one field.
  int get sizeX => maxX - minX + 1;

  // The difference between the lowest and highest y.
  //
  // Adds 1 since a Pos(0,0) means we have one field.
  int get sizeY => maxY - minY + 1;

  String toString() =>
      'Dimensions(minX: $minX, minY: $minY, maxX: $maxX, maxY: $maxY, sizeX: $sizeX, sizeY: $sizeY)';
}
