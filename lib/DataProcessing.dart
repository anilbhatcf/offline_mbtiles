import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:path/path.dart';

final recorder = ui.PictureRecorder();
final canvas = Canvas(recorder);

Future<void> parseNdjson(String filePath) async {
  final file = File(filePath);
  final lines = file.openRead().transform(utf8.decoder).transform(const LineSplitter());

  await for (var line in lines) {
    final feature = jsonDecode(line) as Map<String, dynamic>;
    await processFeature(feature);
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(512, 512);

  await showGeneratedCanvas(image);
}

Offset _convertToCanvasCoordinates(double lon, double lat, double canvasWidth, double canvasHeight) {
  final normalizedX = double.parse(((lon + 180.0) / 360.0).toStringAsFixed(8));
  // print(lat);
  final normalizedY = double.parse(((90.0 - lat) / 180.0).toStringAsFixed(8));

  return Offset(
    normalizedX * canvasWidth,
    normalizedY * canvasHeight,
  );
}


Future<void> processFeature(Map<String, dynamic> feature) async {
  try {
    final id = feature['properties']?['DN'] ?? 'Unknown';
    final type = feature['geometry']?['type'] ?? 'Unknown';
    print('Processing Feature ID: $id, Type: $type');

    final geoJson = GeoJson();
    await geoJson.parse(jsonEncode({'type': 'FeatureCollection', 'features': [feature]}));

    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    for (var geoFeature in geoJson.features) {
      if (geoFeature.type == GeoJsonFeatureType.polygon) {
        final polygon = geoFeature.geometry as GeoJsonPolygon;

        for (final ring in polygon.geoSeries) {
          for (int i = 0; i < ring.geoPoints.length; i++) {
            final point = ring.geoPoints[i];
            final offset = _convertToCanvasCoordinates(
              point.longitude,
              point.latitude,
              256,
              256,
            );
            print(offset);
            if (i == 0) {
              path.moveTo(offset.dx, offset.dy);
            } else {
              path.lineTo(offset.dx, offset.dy);
            }
          }
          print(path.getBounds().center.toString());
          path.close();
          canvas.drawPath(path, paint);
        }
      }
    }

  } catch (e) {
    print('Error processing feature: $e');
  }
}


Future<void> showGeneratedCanvas(ui.Image image) async {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Generated Feature Canvas')),
      body: Center(
        child: Container(
          color: Colors.blue,
          child: CustomPaint(
            painter: ImagePainter(image),
            size: const Size(512, 512), // Match the tile size
          ),
        ),
      ),
    ),
  ));
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset(0, 3), Paint());
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) {
    // return image != oldDelegate.image;
    return false;
  }
}
// class CanvasImageDraw extends CustomPainter {
//   ui.Image image;
//
//   CanvasImageDraw(this.image);
//
//   @override
//   void paint(ui.Canvas canvas, ui.Size size) {
//     // simple aspect fit for the image
//     var hr = size.height / image.height;
//     var wr = size.width / image.width;
//
//     double ratio;
//     double translateX;
//     double translateY;
//     if (hr < wr) {
//       ratio = hr;
//       translateX = (size.width - (ratio * image.width)) / 2;
//       translateY = 0.0;
//     } else {
//       ratio = wr;
//       translateX = 0.0;
//       translateY = (size.height - (ratio * image.height)) / 2;
//     }
//
//     canvas.translate(translateX, translateY);
//     canvas.scale(ratio, ratio);
//     canvas.drawImage(image, new Offset(0.5, 0.5), new Paint());
//   }
//
//   @override
//   bool shouldRepaint(CanvasImageDraw oldDelegate) {
//     return image != oldDelegate.image;
//   }
// }
// void parseLargeGeoJson(String filePath) async {
//   try {
//     final file = File(filePath);
//     final geoJsonStream = file.openRead(); // Create a stream from the file
//
//     // Initialize the JSON stream parser
//     final jsonStream = JsonStreamParser(geoJsonStream.transform(utf8.decoder));
//
//     await for (final token in jsonStream) {
//       // Navigate to the 'features' array and parse one feature at a time
//       if (token.path.startsWith('features') && token.value != null) {
//         final feature = token.value as Map<String, dynamic>;
//         print("Processing feature: ${feature['id']}"); // Replace with actual processing logic
//       }
//     }
//   } catch (e, s) {
//     print("Not able to parse");
//     print(e);
//     print(s);
//   }
// }


// Future<void> processLargeGeoJson(String filePath, int chunk) async {
//   try {
//     final file = File(filePath);
//     if (!(await file.exists())) {
//       print('File not found: $filePath');
//       return;
//     }
//
//     final fileStream = file.openRead();
//     final utf8Stream = fileStream.transform(utf8.decoder);
//     final jsonStream = const JsonDecoder().bind(utf8Stream);
//     bool foundFeatureCollection = false;
//
//     await for (var jsonChunk in jsonStream) {
//       if (jsonChunk is Map && jsonChunk['type'] == 'FeatureCollection') {
//         foundFeatureCollection = true;
//
//         final features = jsonChunk['features'] as List<dynamic>;
//
//         for (final feature in features) {
//           await processFeature(feature);
//         }
//       }
//     }
//
//     if (!foundFeatureCollection) {
//       print('No valid GeoJSON FeatureCollection found.');
//     } else {
//       print('GeoJSON processing complete.');
//     }
//   } catch (e) {
//     print('Error processing GeoJSON: $e');
//   }
// }


