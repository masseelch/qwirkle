import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'models/cube.dart';
import 'models/game.dart';
import 'models/pos.dart';
import 'widgets/field.dart';
import 'widgets/opponents.dart';

const _title = 'Qwirkle';

class MyApp extends StatelessWidget {
  MyApp({this.url});

  final String url;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      home: MyHomePage(
        url: url,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.url}) : super(key: key);

  final String url;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebSocketChannel _channel;
  StreamController _broadcast;

  String _nickname;

  Game _game;

  @override
  void dispose() {
    _broadcast?.close();
    _channel?.sink?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
        actions: _nickname == 'schlumpfmeister'
            ? [
                IconButton(
                  icon: const Icon(Icons.cached),
                  onPressed: () async {
                    await http.get(
                        'http://${widget.url.replaceAll("-ws", "")}/reboot');
                  },
                ),
              ]
            : null,
      ),
      body: Builder(
        builder: (context) {
          if (_channel == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Nickname'),
                      autofocus: true,
                      onChanged: (v) => _nickname = v,
                      onSubmitted: (v) {
                        if (_nickname.isNotEmpty) {
                          _connect();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  RaisedButton(
                    padding: const EdgeInsets.all(24),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    child: const Text('Spielen'),
                    onPressed: () {
                      _connect();
                    },
                  ),
                ],
              ),
            );
          }

          if (_game == null) {
            return const Center(
              child: const CircularProgressIndicator(),
            );
          }

          const _size = 6;

          return Row(
            children: [
              Opponents(opponents: _game.players.values.toList()),
              Field(
                player: _game.players[_nickname],
                placed: Map.fromIterables(
                  List.generate(_size, (index) => Pos(index + 5, index - 10))
                    ..addAll(List.generate(_size, (index) => Pos(index, 0))),
                  List.generate(2 * _size, _randomCube),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _connect() {
    final url = 'ws://${widget.url}/$_nickname';

    setState(() {
      _channel = kIsWeb
          ? HtmlWebSocketChannel.connect(url)
          : IOWebSocketChannel.connect(url);
    });

    _broadcast = StreamController.broadcast();
    _broadcast.addStream(_channel.stream);

    // The first event received after registering is the whole game.
    _broadcast.stream.first.then((event) {
      setState(() {
        _game = Game.fromJson(jsonDecode(event)["game"]);
      });
    });

    // All events except the first do only contain a player.
    _broadcast.stream.skip(1).listen((event) {
      print(event);
      // final player = Player.fromJson(jsonDecode(event));
      //
      // setState(() {
      //   _game.players[player.nickname] = player;
      // });
    });
  }
}

// todo - remove debug
var _rand = Random(DateTime.now().millisecondsSinceEpoch);
// todo - remove debug
Cube _randomCube([dynamic _]) => Cube(
      color: CubeColor.values[_rand.nextInt(CubeColor.values.length)],
      shape: Shape.values[_rand.nextInt(Shape.values.length - 1) + 1],
      locked: true,
    );
