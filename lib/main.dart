import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:offline_mbtiles/DataProcessing.dart';
import 'package:offline_mbtiles/simplifyjson/dauglas_peucker.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'TileProvider.dart';

// Future<void> parseLargeGeoJson(String filePath) async {
//   final file = File(filePath);
//   final inputStream = file.openRead();
//
//   String buffer = '';
//
//   // Track if we've encountered the "features" array
//   bool featuresStarted = false;
//
//   await for (var chunk in inputStream) {
//     final decodedChunk = utf8.decode(chunk);
//     buffer += decodedChunk;
//
//     while (buffer.isNotEmpty) {
//       if (!featuresStarted && buffer.contains('"features": [')) {
//         featuresStarted = true;
//         buffer = buffer.substring(buffer.indexOf('"features": [') + '"features": ['.length);
//       }
//
//       final closingBracketIndex = buffer.indexOf('},');
//       if (closingBracketIndex != -1) {
//         final featureChunk = buffer.substring(0, closingBracketIndex + 1);
//         buffer = buffer.substring(closingBracketIndex + 2);
//
//         try {
//           final feature = jsonDecode(featureChunk);
//           if (feature is Map && feature['type'] == 'Feature') {
//             final properties = feature['properties'];
//             final geometry = feature['geometry'];
//             print('ID: ${properties['ID']}, Elevation: ${properties['elevation']}');
//             print('Coordinates: ${geometry['coordinates']}');
//           }
//         } catch (e) {
//           print('Failed to parse feature: $e');
//         }
//       } else {
//         break;
//       }
//     }
//   }
//
//   if (buffer.isNotEmpty) {
//     try {
//       final lastFeature = jsonDecode(buffer);
//       if (lastFeature is Map && lastFeature['type'] == 'Feature') {
//         final properties = lastFeature['properties'];
//         final geometry = lastFeature['geometry'];
//         print('ID: ${properties['ID']}, Elevation: ${properties['elevation']}');
//         print('Coordinates: ${geometry['coordinates']}');
//       }
//     } catch (e) {
//       print('Error parsing leftover data: $e');
//     }
//   }
// }

Future<void> requestStoragePermission() async {
  if (await Permission.storage.isGranted) {
    print("Storage permission already granted");
  } else {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      print("Storage permission granted");
    } else if (status.isDenied) {
      openAppSettings();
      print("Storage permission denied");
    } else if (status.isPermanentlyDenied) {
      print("Storage permission permanently denied. Please enable it from settings.");
    }
  }
}

Future<void> _openGeoJsonFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.any,
    // allowedExtensions: ['geojson', 'ndjson'],
    allowMultiple: false,
    withData: false,
  );

  if (result != null && result.files.single.path != null) {
    final filePath = result.files.single.path!;
    print('Final File Path of Selected file $filePath');
    // parseLargeGeoJson(filePath);
    parseNdjson(filePath);
  } else {
    print('No file selected');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure proper initialization
  runApp(const PlaceholderApp());
}


class PlaceholderApp extends StatelessWidget {
  const PlaceholderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("GeoJSON Processing")),
        body:  const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Hello 123 checking"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _openGeoJsonFile,
                child:  Text("Select GeoJson File"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> loadGeoJson(String path) async {
  final data = await rootBundle.loadString(path);
  return jsonDecode(data);
}

void simplify() {
  GeoJSON geoJson = GeoJSON([
    Point(0, 0),
    Point(1, 0.1),
    Point(2, -0.1),
    Point(3, 5),
    Point(4, 6),
    Point(5, 7),
    Point(6, 8.1),
    Point(7, 9),
    Point(8, 9),
    Point(9, 9)
  ]);

  double epsilon = 1.0;
  GeoJSON simplifiedGeoJson = simplifyGeoJSON(geoJson, epsilon);

  print('Original: ${geoJson.coordinates.length} points');
  print('Simplified: ${simplifiedGeoJson.coordinates.length} points');
}

// class MyApp extends StatelessWidget {
//   final Map<String, dynamic> geojson;
//
//   const MyApp({super.key, required this.geojson});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home:  TurfMap(geojson: geojson),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
