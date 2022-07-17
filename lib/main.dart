import 'package:file_system_access/file_system_access.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/common/extensions.dart';
import 'package:neural_graph/diagram/graph.dart';
import 'package:neural_graph/graph_canvas/graph_canvas.dart';
import 'package:neural_graph/layers/codegen_helper.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/layers_menu.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/rtc/data_channel.dart';
import 'package:neural_graph/tasks/tasks_tab_view.dart';
import 'package:neural_graph/widgets/gesture_listener.dart';
import 'package:neural_graph/widgets/resizable.dart';
import 'package:neural_graph/widgets/scrollable.dart';
import 'package:stack_portal/fields.dart';
import 'package:stack_portal/stack_portal.dart';
import 'package:url_strategy/url_strategy.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

ThemeData get theme {
  return ThemeData(
    primaryColor: Colors.blue[900],
    toggleableActiveColor: Colors.blue[900],
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // inputDecorationTheme: const InputDecorationTheme(
    //   isDense: true,
    //   border: OutlineInputBorder(),
    //   errorStyle: TextStyle(height: 0),
    //   contentPadding: EdgeInsets.only(top: 7, bottom: 7, left: 10, right: 10),
    //   labelStyle: TextStyle(fontSize: 18),
    // ),
    textTheme: GoogleFonts.nunitoSansTextTheme(),
    inputDecorationTheme: const InputDecorationTheme(
      isDense: true,
      filled: true,
      contentPadding: EdgeInsets.only(top: 7, left: 7, right: 7, bottom: 8),
      labelStyle: TextStyle(height: 1),
    ),
    tooltipTheme: const TooltipThemeData(
      textStyle: TextStyle(fontSize: 14, color: Colors.white),
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 5, top: 5),
    ),
    scrollbarTheme: ScrollbarThemeData(
      interactive: true,
      thickness: MaterialStateProperty.all(9),
      mainAxisMargin: 6,
    ),
  );
}

void main() {
  setPathUrlStrategy();
  LicenseRegistry.addLicense(() async* {
    final licenseCousine =
        await rootBundle.loadString('google_fonts/LICENSE.txt');
    final licenseNunitoSans =
        await rootBundle.loadString('google_fonts/OFL.txt');

    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseCousine);
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseNunitoSans);
  });

  GetIt.instance.registerSingleton(RootStore());
  mainContext.config = ReactiveConfig(
    writePolicy: ReactiveWritePolicy.never,
    disableErrorBoundaries: true,
  );
  runApp(
    GlobalKeyboardListener.wrapper(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neural Graph',
      theme: theme,
      navigatorObservers: [routeObserver],
      builder: (context, child) {
        return GlobalStack(child: child!);
      },
      onGenerateRoute: (settings) {
        print(settings);
        if (settings.name == '/fam/m') {
          return MaterialPageRoute<Object?>(
            builder: (context) => Scaffold(
              appBar: AppBar(),
              backgroundColor: Colors.white,
              body: const Center(child: Text('/fam/m')),
            ),
            settings: settings,
          );
        }
        if (settings.name == '/fam') {
          return MaterialPageRoute<Object?>(
            builder: (context) => Scaffold(
              appBar: AppBar(),
              backgroundColor: Colors.white,
              body: const Center(child: Text('/fam')),
            ),
            settings: settings,
          );
        }
        if (settings.name == '/') {
          return MaterialPageRoute<Object?>(
            builder: (context) => const GlobalStack(
              child: MyHomePage(title: 'Neural Graph'),
            ),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final root = RootStore.instance;

  int index = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          Text(widget.title!),
          InkWell(
            onTap: () {
              setState(() {
                index = 0;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
              child: const Text('Scheduler'),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                index = 1;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
              child: const Text('Graph'),
            ),
          )
        ],
      )),
      body: IndexedStack(
        index: index,
        children: [
          const TasksTabView(),
          Row(
            children: [
              const Resizable(
                defaultWidth: 210,
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
                            child: Observer(builder: (context) {
                              return GraphView(
                                  graph: root.selectedNetwork.graph);
                            }),
                          ),
                          const Resizable(
                            defaultWidth: 450,
                            horizontal: ResizeHorizontal.left,
                            child: CodeGenerated(),
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
        ],
      ),
    );
  }
}

class CodeGenerated extends HookWidget {
  const CodeGenerated({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final root = useRoot();
    final controller = useMemoized(() => ScrollController());
    useEffect(() => controller.dispose, []);

    return Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(padding: const EdgeInsets.all(14)),
                icon: const Icon(Icons.file_present),
                label: const Text('File'),
                onPressed: () async {
                  if (kIsWeb) {
                    final handles =
                        await FileSystem.instance.showOpenFilePicker();
                    final handle = handles[0];

                    // final file = await handle.getFile();
                    // final contents = await readFileAsText(file);

                    final v = await FileSystem.instance.verifyPermission(
                      handle,
                      mode: FileSystemPermissionMode.readwrite,
                    );
                    print(v);

                    // final writable = await handle.createWritable(
                    //     FileSystemCreateWritableOptions(keepExistingData: true));

                    // await writable.write(
                    //     FileSystemWriteChunkType.string("value" + contents));
                    // // Close the file and write the contents to disk.
                    // await writable.close();
                  }
                },
              ),
              Observer(builder: (context) {
                final sourceCode = root.generatedSourceCode;
                return TextButton.icon(
                  style:
                      TextButton.styleFrom(padding: const EdgeInsets.all(14)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: sourceCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Source code copied'),
                        behavior: SnackBarBehavior.floating,
                        width: 300,
                      ),
                    );
                  },
                  icon: const Icon(Icons.file_copy),
                  label: const Text('Copy'),
                );
              }),
              Observer(builder: (context) {
                return ButtonSelect<ProgrammingLanguage>(
                  options: ProgrammingLanguage.values,
                  selected: root.language,
                  asString: toEnumString,
                  onChange: (v) => root.language = v,
                );
              }),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 12.0,
                left: 12.0,
              ),
              child: MultiScrollable(
                vertical: controller,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Observer(builder: (context) {
                      final sourceCode = root.generatedSourceCode;

                      return SelectableText(
                        sourceCode,
                        style: GoogleFonts.cousine(fontSize: 13),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PropertiesView extends HookWidget {
  const PropertiesView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final selectedGraph = useRoot().selectedNetwork.graph;

    return Row(
      children: [
        Expanded(
          child: NodePropertiesView(
            selectedGraph: selectedGraph,
          ),
        ),
        Resizable(
          horizontal: ResizeHorizontal.left,
          defaultWidth: 150,
          child: Observer(builder: (context) {
            final conn = selectedGraph.selectedConnection;
            if (conn == null) {
              return const Text('No selected connection');
            }
            return Text('${conn.fromData.name} -> ${conn.toData.name}');
          }),
        ),
        const Resizable(
          horizontal: ResizeHorizontal.left,
          defaultWidth: 270,
          child: Center(child: DataChannelSample()),
        )
      ],
    );
  }
}

class NodePropertiesView extends HookWidget {
  const NodePropertiesView({
    Key? key,
    required this.selectedGraph,
  }) : super(key: key);

  final Graph<Layer> selectedGraph;

  @override
  Widget build(BuildContext context) {
    final contoller = useTextEditingController(
      text: selectedGraph.selectedNode!.data.name,
    );

    return Observer(
      builder: (context) {
        final selectedNode = selectedGraph.selectedNode;
        if (selectedNode == null) {
          return const Center(child: Text('No selected node'));
        }
        if (contoller.text != selectedNode.data.name) {
          contoller.text = selectedNode.data.name;
        }

        bool isRepeated(String value) {
          return selectedGraph.nodes.values.any((element) =>
              element.key != selectedNode.key && element.data.name == value);
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
                    selectedNode.data.layerId,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: contoller,
                    decoration: const InputDecoration(hintText: 'Name'),
                    onChanged: (value) {
                      if (!isRepeated(value)) {
                        selectedNode.data.setName(value);
                      }
                    },
                    validator: (value) =>
                        selectedNode.data.name != value ? '' : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: selectedGraph.deleteSelected,
                )
              ],
            ),
            Expanded(
              child: selectedNode.data.form(),
            )
          ],
        );
      },
    );
  }
}
