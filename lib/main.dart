import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:neural_graph/graph_canvas/graph_canvas.dart';
import 'package:neural_graph/layers_menu.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/widgets/resizable.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

final theme = ThemeData(
  primaryColor: Colors.blue[900],
  toggleableActiveColor: Colors.blue[900],
  visualDensity: VisualDensity.adaptivePlatformDensity,
  inputDecorationTheme: const InputDecorationTheme(
    isDense: true,
    border: OutlineInputBorder(),
    errorStyle: TextStyle(height: 0),
    contentPadding: EdgeInsets.only(top: 7, bottom: 7, left: 10, right: 10),
    labelStyle: TextStyle(fontSize: 18),
  ),
);

void main() {
  GetIt.instance.registerSingleton(RootStore());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neural Graph',
      theme: theme,
      navigatorObservers: [routeObserver],
      onGenerateRoute: (settings) {
        print(settings);
        if (settings.name == "/fam/m") {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(),
              backgroundColor: Colors.white,
              body: const Center(child: Text("/fam/m")),
            ),
            settings: settings,
          );
        }
        if (settings.name == "/fam") {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(),
              backgroundColor: Colors.white,
              body: const Center(child: Text("/fam")),
            ),
            settings: settings,
          );
        }
        if (settings.name == "/") {
          return MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'Neural Graph'),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final root = RootStore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Row(
        children: [
          const Resizable(
            defaultWidth: 230,
            horizontal: ResizeHorizontal.right,
            child: LayersMenu(),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: GraphView(),
                      ),
                      const Resizable(
                        defaultWidth: 200,
                        horizontal: ResizeHorizontal.left,
                        child: Text("ddw"),
                        // InteractiveViewer(
                        //   constrained: false,
                        //   child: Center(
                        //     child: Image.network(
                        //       "https://www.woodlandtrust.org.uk/media/3817/ash-tree-overall-tree-blue-skies-alamy-bj7mxm-jeremy-inglis.jpg",
                        //     ),
                        //   ),
                        // )
                      ),
                    ],
                  ),
                ),
                const Resizable(
                  defaultHeight: 300,
                  vertical: ResizeVertical.top,
                  child: PropertiesView(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PropertiesView extends HookWidget {
  const PropertiesView({Key key}) : super(key: key);
  @override
  Widget build(BuildContext ctx) {
    final root = useRoot();
    final contoller = useTextEditingController(text: root.selectedNode.name);

    return Observer(
      builder: (context) {
        if (contoller.text != root.selectedNode.name) {
          contoller.text = root.selectedNode.name;
        }

        bool isRepeated(String value) {
          return root.nodes.values.any((element) =>
              element.key != root.selectedNode.key && element.name == value);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Text(
                    root.selectedNode.data.layerId,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    autovalidate: true,
                    controller: contoller,
                    decoration: const InputDecoration(hintText: "Name"),
                    onChanged: (value) {
                      if (!isRepeated(value)) root.selectedNode.name = value;
                    },
                    validator: (value) =>
                        root.selectedNode.name != value ? "" : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: root.deleteSelected,
                )
              ],
            ),
            Expanded(
              child: root.selectedNode.data.form(),
            )
          ],
        );
      },
    );
  }
}
