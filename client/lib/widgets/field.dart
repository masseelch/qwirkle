import 'package:client/models/cube.dart';
import 'package:client/models/player.dart';
import 'package:client/models/pos.dart';
import 'package:flutter/material.dart';

import 'cube.dart';

const _cubeSize = 48.0;
const _cubeOpacity = 0.2;

class Field extends StatefulWidget {
  Field({
    @required this.player,
    @required this.placed,
    this.onPlacedLocked,
  }) : assert(player != null);

  final Player player;
  final Map<Pos, Cube> placed;
  final ValueSetter<Map<Pos, Cube>> onPlacedLocked;

  @override
  _FieldState createState() => _FieldState();
}

class _FieldState extends State<Field> {
  _FieldDimensions _dimensions;
  Map<Pos, Cube> _placedCubesMap;

  List<_Cell> _cells;
  List<Cube> _availableCubes;

  List<_PlacedAvailableCube> _placedAvailableCubes = [];

  @override
  void initState() {
    super.initState();

    _availableCubes = widget.player.cubes;
    _placedCubesMap = widget.placed;

    _computeCells();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 64),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: _placedAvailableCubes.isNotEmpty
                    ? () {
                        if (_placedAvailableCubes.isEmpty) {
                          return;
                        }

                        setState(() {
                          final pc = _placedAvailableCubes.removeLast();
                          _availableCubes[pc.index].unlock();
                          _placedCubesMap.remove(pc.pos);
                          _computeCells();
                        });
                      }
                    : null,
              ),
              const SizedBox(width: 24),
            ]
              ..addAll(_availableCubes.map((c) {
                Widget cube = CubeWidget(cube: c, width: _cubeSize);

                Widget child = Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: cube,
                );

                if (!c.locked) {
                  child = Draggable<int>(
                    child: child,
                    childWhenDragging: child,
                    feedback: cube,
                    data: _availableCubes.indexOf(c),
                  );
                } else {
                  child = Opacity(
                    opacity: 0.2,
                    child: child,
                  );
                }

                return child;
              }))
              ..addAll(
                [
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _placedAvailableCubes.isNotEmpty ? () {
                      widget.onPlacedLocked?.call(_placedAvailableCubes.fold<Map<Pos, Cube>>({}, (cs, pac) {
                        cs[pac.pos] = _availableCubes[pac.index];

                        return cs;
                      }));
                    } : null,
                  ),
                ],
              ),
          ),
          const SizedBox(height: 64),
          Expanded(
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
                        children: _cells.map(_buildCell).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(_Cell cell) {
    Widget child;

    if (cell.cube != null) {
      child = CubeWidget(
        cube: cell.cube,
        width: _cubeSize,
      );

      if (!cell.cube.locked) {
        child = Container(
          color: Colors.tealAccent.withOpacity(_cubeOpacity * 2),
          child: child,
        );
      }
    } else if (cell.hasNeighbour) {
      child = DragTarget<int>(
        onWillAccept: (_) => cell.cube == null,
        onAccept: (index) {
          setState(() {
            final cube = _availableCubes[index];
            final pos = _dimensions.denormalizePos(cell.pos);
            cube.lock();

            _placedCubesMap[pos] = cube.copyWith(locked: false);
            _placedAvailableCubes.add(_PlacedAvailableCube(
              index: index,
              pos: pos,
            ));
            _computeCells();
          });
        },
        builder: (context, candidates, _) {
          if (candidates.length > 0) {
            return Opacity(
              opacity: _cubeOpacity,
              child: CubeWidget(
                cube: _availableCubes[candidates.first],
                width: _cubeSize,
              ),
            );
          }

          return Container(
            width: _cubeSize * 0.8,
            height: _cubeSize * 0.8,
            margin: EdgeInsets.all(_cubeSize * 0.1),
            color: Colors.grey[200],
          );
        },
      );
    } else {
      child = SizedBox(
        width: _cubeSize,
        height: _cubeSize,
      );
    }

    return Positioned(
      left: cell.pos.x * _cubeSize,
      top: cell.pos.y * _cubeSize,
      child: child,
    );
  }

  void _computeCells() {
    _dimensions = _FieldDimensions.fromPlaced(_placedCubesMap);

    _cells = [];
    for (int x = _dimensions.minX; x <= _dimensions.maxX; x++) {
      for (int y = _dimensions.minY; y <= _dimensions.maxY; y++) {
        final pos = Pos(x, y);

        _cells.add(_Cell(
          pos: _dimensions.normalizePos(pos),
          cube: _placedCubesMap[pos],
          hasNeighbour: _placedCubesMap[pos.copyWith(y: pos.y - 1)] != null ||
              _placedCubesMap[pos.copyWith(x: pos.x + 1)] != null ||
              _placedCubesMap[pos.copyWith(y: pos.y + 1)] != null ||
              _placedCubesMap[pos.copyWith(x: pos.x - 1)] != null,
        ));
      }
    }
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

class _PlacedAvailableCube {
  _PlacedAvailableCube({@required this.index, @required this.pos});

  final int index;
  final Pos pos;
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

    placed.forEach((pos, _) {
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
  Pos normalizePos(Pos p) => Pos(p.x - minX, p.y - minY);

  Pos denormalizePos(Pos p) => Pos(p.x + minX, p.y + minY);

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
