import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:neural_graph/graph_canvas.dart';
import 'package:neural_graph/layers_menu.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/widgets/resizable.dart';
import 'package:styled_widget/styled_widget.dart';

void main() {
  GetIt.instance.registerSingleton(RootStore());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Resizable(
            defaultWidth: 200,
            horizontal: ResizeHorizontal.right,
            child: LayersMenu(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GraphView().expanded(),
                  Resizable(
                    defaultWidth: 150,
                    horizontal: ResizeHorizontal.left,
                    child: Text("COL2sssss"),
                  ),
                ],
              ).expanded(),
              Resizable(
                defaultHeight: 300,
                vertical: ResizeVertical.top,
                child: Column(
                  children: [
                    Text('You have pushed the button this many times:'),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
              )
            ],
          ).expanded(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
