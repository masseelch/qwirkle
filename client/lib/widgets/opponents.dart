import 'package:client/widgets/cube.dart';
import 'package:flutter/material.dart';

import '../models/player.dart';

class Opponents extends StatefulWidget {
  Opponents({@required this.opponents}) : assert(opponents != null);

  final List<Player> opponents;

  @override
  _OpponentsState createState() => _OpponentsState();
}

class _OpponentsState extends State<Opponents> {
  List<Player> _opponents;

  @override
  void initState() {
    super.initState();
    _playersChanged();
  }

  @override
  void didUpdateWidget(Opponents oldWidget) {
    super.didUpdateWidget(oldWidget);
    _playersChanged();
  }

  void _playersChanged() {
    _opponents = widget.opponents;
    _opponents.sort((a, b) => a.score.compareTo(b.score));
    _opponents.forEach((player) {
      player.cubes.sort((a, b) => a.color.toString().compareTo(b.color.toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(right: BorderSide())),
      child: Column(
        children: ListTile.divideTiles(
          color: Colors.black,
          tiles: _opponents.map((player) {
            return Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${player.id} ',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        TextSpan(
                          text: '(${player.score} Punkte)',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: player.cubes
                        .map((cube) => CubeWidget(
                              cube: cube,
                              width: 36,
                            ))
                        .toList(),
                  ),
                ],
              ),
            );
          }),
        ).toList(),
      ),
    );
  }
}
