import 'package:client/models/cube.dart';
import 'package:flutter/material.dart';

class CubeWidget extends StatelessWidget {
  CubeWidget({@required this.cube, this.width}) : assert(cube != null);

  final Cube cube;
  final double width;

  @override
  Widget build(BuildContext context) {
    String asset;

    switch (cube.color) {
      case CubeColor.Blue:
        asset = 'B';
        break;
      case CubeColor.Green:
        asset = 'W';
        break;
      case CubeColor.Orange:
        asset = 'O';
        break;
      case CubeColor.Purple:
        asset = 'L';
        break;
      case CubeColor.Red:
        asset = 'R';
        break;
      case CubeColor.Yellow:
        asset = 'G';
        break;
    }

    switch (cube.shape) {
      case Shape.circle:
        asset += '2';
        break;
      case Shape.diamond:
        asset += '5';
        break;
      case Shape.plus:
        asset += '1';
        break;
      case Shape.spade:
        asset += '4';
        break;
      case Shape.square:
        asset += '3';
        break;
      case Shape.star:
        asset += '6';
        break;
      case Shape.none:
        throw UnimplementedError();
    }

    return Image.asset('images/symbols/$asset.png', width: width);
  }
}
