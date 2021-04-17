@JS()
library javascript_bundler;

// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'package:test_web_app/bloc.dart';
import 'package:universal_echarts/universal_echarts.dart';

@JS('openCamera')
external void openCamera();

@JS('drawChart')
external void drawChart();

@JS('changeTextColor')
external set _changeTextColor(void Function(String text) f);

final Bloc _bloc = Bloc();

void _changeColor(String text) {
  if (text == 'red') {
    _bloc.add(Colors.red);
  } else {
    _bloc.add(Colors.blue);
  }
}

@JS('display')
external set display(void Function(String text) f);

void _displayText(String text) {
  _bloc.addText(text);
}

@JS('sendImage')
external set _sendImage(void Function(String text) f);

void _handleImageString(String text) {
  final imageBytes = base64Decode(text);
  _bloc.addImage(imageBytes);
}

void main() {
  _changeTextColor = allowInterop(_changeColor);
  _sendImage = allowInterop(_handleImageString);
  display = allowInterop(_displayText);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final option = '''
  {
            title: {
                text: 'ECharts entry example'
            },
            tooltip: {},
            legend: {
                data:['Sales']
            },
            xAxis: {
                data: ["shirt","cardign","chiffon shirt","pants","heels","socks"]
            },
            yAxis: {},
            series: [{
                name: 'Sales',
                type: 'bar',
                data: [5, 20, 36, 10, 10, 20]
            }]
        }
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Web Demo'),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<Color>(
                  initialData: Colors.black,
                  stream: _bloc.colorStream,
                  builder: (context, snapshot) {
                    return Text(
                      "This text will change color based on button click from App",
                      style: TextStyle(color: snapshot.data),
                    );
                  }),
              SizedBox(height: 30),
              Text("The below text will change content based on App's input:"),
              SizedBox(height: 10),
              StreamBuilder<String>(
                  initialData:
                      "This text will change content based on App's input"
                          .toUpperCase(),
                  stream: _bloc.textStream,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data,
                      style: TextStyle(color: Colors.teal),
                    );
                  }),
              SizedBox(height: 30),
              Container(
                width: 300,
                height: 500,
                color: Colors.grey.withOpacity(0.5),
                child: StreamBuilder<Uint8List>(
                    stream: _bloc.imageStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Container(
                            child: Center(child: Text('No image chosen')));
                      return Image.memory(snapshot.data);
                    }),
              ),
              SizedBox(height: 20),
              Container(
                width: 200,
                child: TextButton(
                    onPressed: () => openCamera(),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    child: Text(
                      'Choose image from phone',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              SizedBox(height: 20),
              Container(
                  width: 400,
                  height: 400,
                  alignment: Alignment.center,
                  child: UniversalEcharts.drawChart(option)),
            ],
          ),
        ),
      ),
    );
  }
}
