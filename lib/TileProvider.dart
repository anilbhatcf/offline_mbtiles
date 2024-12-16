// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:offline_mbtiles/simplifyjson/SimplifyingJson.dart';
// import 'package:turf/bbox.dart';
// import 'package:turf/helpers.dart';
// import 'BboxClip.dart';
//
//
// class TurfTileProvider extends TileProvider {
//   final Map<String, dynamic> geojson;
//
//   TurfTileProvider(this.geojson);
//
//   Map<String, dynamic> preprocessGeoJson(Map<String, dynamic> geojson, List<double> tileBounds, double simplifyTolerance) {
//     final bbox = BBox.fromJson(tileBounds); // [minX, minY, maxX, maxY]
//     final clippedGeoJson = bboxClip(geojson, bbox);
//
//     // Simplify the clipped features
//     final simplifiedGeoJson = simplifyGeometry(clippedGeoJson, tolerance: simplifyTolerance, highQuality: true);
//
//     return simplifiedGeoJson;
//   }
//
//   @override
//   ImageProvider getImage(Coords coords, TileLayerOptions options) {
//     // Calculate the tile's bounding box
//     final double tileSize = 256.0;
//     final scale = 1 << coords.z.toInt();
//     final minX = coords.x.toDouble() * tileSize / scale - 180.0;
//     final maxX = (coords.x.toDouble() + 1) * tileSize / scale - 180.0;
//     final minY = 90.0 - (coords.y.toDouble() + 1) * tileSize / scale;
//     final maxY = 90.0 - coords.y.toDouble() * tileSize / scale;
//     final tileBounds = [minX, minY, maxX, maxY];
//
//     // Preprocess GeoJSON
//     final processedGeoJson = preprocessGeoJson(geojson, tileBounds, 0.001);
//
//     // Render the tile
//     return _renderTile(processedGeoJson);
//   }
//
//   MemoryImage _renderTile(Map<String, dynamic> geojson) {
//     const tileSize = 256; // Standard tile size
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, tileSize.toDouble(), tileSize.toDouble()));
//
//     final paint = Paint()
//       ..color = Colors.blue
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;
//
//     for (var feature in geojson['features']) {
//       final geometry = feature['geometry'];
//       final type = feature['type'];
//
//       if (type == "Point") {
//         // Draw points
//         final point = geometry['coordinates'];
//         final offset = Offset(
//           (point[0] + 180) * tileSize / 360,
//           (90 - point[1]) * tileSize / 180,
//         );
//         canvas.drawCircle(offset, 5.0, paint);
//       } else if (type == "LineString") {
//         // Draw lines
//         final line = geometry['coordinates'];
//         final path = Path();
//         for (var i = 0; i < line.length; i++) {
//           final point = line[i];
//           final offset = Offset(
//             (point[0] + 180) * tileSize / 360,
//             (90 - point[1]) * tileSize / 180,
//           );
//           if (i == 0) {
//             path.moveTo(offset.dx, offset.dy);
//           } else {
//             path.lineTo(offset.dx, offset.dy);
//           }
//         }
//         canvas.drawPath(path, paint);
//       }
//     }
//
//     final picture = recorder.endRecording();
//     final image = picture.toImage(tileSize.toInt(), tileSize.toInt());
//
//     return Future<MemoryImage>(() async {
//       final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       return MemoryImage(byteData!.buffer.asUint8List());
//     }).then((imageProvider) => imageProvider);
//   }
// }
//
// class TurfMap extends StatelessWidget {
//   final Map<String, dynamic> geojson;
//
//   const TurfMap({super.key, required this.geojson});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Turf.dart Map')),
//       body: FlutterMap(
//         options: MapOptions(
//           center: LatLng(0, 0),
//           zoom: 2.0,
//         ),
//         children: [
//           TileLayerWidget(
//             options: TileLayerOptions(
//               tileProvider: TurfTileProvider(geojson),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
