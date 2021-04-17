import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Bloc {
  final StreamController _controller = StreamController<Color>();

  Stream<Color> get colorStream => _controller.stream;

  add(Color color) => _controller.add(color);

  final StreamController _imageController = StreamController<Uint8List>();

  Stream<Uint8List> get imageStream => _imageController.stream;

  addImage(Uint8List bytes) => _imageController.add(bytes);

  final StreamController _textController = StreamController<String>();

  Stream<String> get textStream => _textController.stream;

  addText(String text) => _textController.add(text);

  dispose() {
    _controller.close();
    _imageController.close();
    _textController.close();
  }
}
