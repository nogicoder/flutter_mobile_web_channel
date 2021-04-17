import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

main() {
  runApp(MaterialApp(
    home: WebViewExample(),
  ));
}

class WebViewExample extends StatefulWidget {
  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  WebViewController _controller;
  bool isRed = true;

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _controller.evaluateJavascript(
            'sendImage("${base64Encode(_image.readAsBytesSync())}");');
      } else {
        _controller.evaluateJavascript('display("No image selected.");');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Set<JavascriptChannel> jsChannels = [
      JavascriptChannel(
          name: 'Test',
          onMessageReceived: (JavascriptMessage message) {
            print("APP: ${message.message}");
            if (message.message.startsWith('CAMERA')) {
              getImage();
            }
          }),
    ].toSet();
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: WebView(
                    initialUrl: 'https://nogicoder.github.io',
                    javascriptMode: JavascriptMode.unrestricted,
                    javascriptChannels: jsChannels,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                    },
                  ),
                ),
                Container(
                  color: Colors.deepOrangeAccent,
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 250,
                        height: 50,
                        padding: EdgeInsets.only(left: 10),
                        color: Colors.white,
                        child: TextField(
                          onChanged: (value) {
                            _controller
                                .evaluateJavascript('display("$value");');
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type something for the web',
                          ),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          isRed = !isRed;
                          _controller.evaluateJavascript(
                              'changeTextColor("${isRed ? '' : 'red'}");');
                        },
                        child: Icon(Icons.colorize),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
