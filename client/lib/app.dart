import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:client/models/message.dart';
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
const _admin = 'schlumpfmeister';

class MyApp extends StatelessWidget {
  MyApp({this.url, this.dev = false});

  final String url;
  final bool dev;

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
        dev: dev,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.url, this.dev}) : super(key: key);

  final String url;
  final bool dev;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();
  WebSocketChannel _channel;
  StreamController _broadcast;

  Game _game;

  @override
  void initState() {
    super.initState();
    if (widget.dev) {
      _controller.text = _admin;
      _connect();
    }
  }

  @override
  void dispose() {
    _broadcast?.close();
    _channel?.sink?.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
        actions: _controller.text == _admin
            ? [
                if (_game != null && _game.activePlayer == null)
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                    onPressed: () async {
                      await http.get(
                          'http://${widget.url.replaceAll("-ws", "")}/start');
                    },
                  ),
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
                      controller: _controller,
                      decoration: const InputDecoration(labelText: 'Nickname'),
                      autofocus: true,
                      onSubmitted: (v) {
                        if (_controller.text.isNotEmpty) {
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
              Opponents(opponents: _game.players, active: _game.activePlayer),
              Field(
                player:
                    _game.players.firstWhere((p) => p.id == _controller.text),
                placed: Map.fromIterables(
                  List.generate(_size, (index) => Pos(index + 5, index - 10))
                    ..addAll(List.generate(_size, (index) => Pos(index, 0))),
                  List.generate(2 * _size, _randomCube),
                ),
                onPlacedLocked: (placedCubes) {
                  _channel.sink.add(jsonEncode(Message(
                    type: MessageType.placeCubes,
                    meta: {'for': _controller.text},
                    data: placedCubes,
                  ).toJson()));
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _connect() {
    final url = 'ws://${widget.url}/${_controller.text}';

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

    // Skip the first event since it is fired directly after registering a player.
    _broadcast.stream.skip(1).listen((event) {
      final json = jsonDecode(event);

      if (json['game'] != null) {
        print(json['game']);
        setState(() {
          _game = Game.fromJson(json['game']);
        });
      }
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
