import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:isolate';
import 'dart:math' as math;
import 'package:file/src/interface/file.dart';
import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:offline_mbtiles/tiledata.dart';

import 'TileCacheManager.dart';

void main() {
  runApp(MaterialApp(home: TileRenderer()));
}

class TileRenderer extends StatefulWidget {
  @override
  _TileRendererState createState() => _TileRendererState();
}

class _TileRendererState extends State<TileRenderer> {
  static const int tileSize = 256;
  final TileCacheManager cacheManager = TileCacheManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tile Renderer')),
      body: Center(
        child: FutureBuilder<ui.Image?>(
          future: _getTile(10, 1000, 1000),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data != null) {
                return CustomPaint(
                  painter: ImagePainter(snapshot.data!),
                  size: Size(tileSize.toDouble(), tileSize.toDouble()),
                );
              } else {
                return Text('Error generating tile');
              }
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<ui.Image?> _getTile(int zoomLevel, int x, int y) async {
    final String tileKey = "${zoomLevel}_${x}_$y";

    // Check if the tile is already cached
    // final fileInfo = await cacheManager(tileKey);
    // if (fileInfo != null) {
    //   final bytes = await fileInfo.file.readAsBytes();
    //   final codec = await ui.instantiateImageCodec(bytes);
    //   final frame = await codec.getNextFrame();
    //   return frame.image;
    // }

    // Generate tile in an isolate if not cached
    final tileData = TileData(_exampleGeoJson(), tileSize, zoomLevel, x, y);
    final receivePort = ReceivePort();
    await Isolate.spawn(_processTileInIsolate, [tileData, receivePort.sendPort]);
    final generatedImage = await receivePort.first as ui.Image;

    // Cache the generated tile
    final byteData = await generatedImage.toByteData(format: ui.ImageByteFormat.png);
    // if (byteData != null) {
    //   await cacheManager.putFile(tileKey, byteData.buffer.asUint8List());
    // }

    return generatedImage;
  }

  static String _exampleGeoJson() {
    return """{
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "Polygon",
            "coordinates": [[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0]]]
          },
          "properties": {}
        }
      ]
    }""";
  }

  static void _processTileInIsolate(List<dynamic> args) async {
    final TileData data = args[0];
    final SendPort sendPort = args[1];

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final geoJson = GeoJson();
    await geoJson.parse(data.geoJson);

    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0;

    for (var feature in geoJson.features) {
      if (feature.type == GeoJsonFeatureType.polygon) {
        final polygon = feature.geometry as GeoJsonPolygon;
        for (final ring in polygon.geoSeries) {
          final path = Path();
          for (int i = 0; i < ring.geoPoints.length; i++) {
            final point = ring.geoPoints[i];
            final offset = _convertCoordinatesToOffset(
                point.longitude, point.latitude, data.tileX, data.tileY, data.zoomLevel, data.tileSize);
            if (i == 0) {
              path.moveTo(offset.dx, offset.dy);
            } else {
              path.lineTo(offset.dx, offset.dy);
            }
          }
          path.close();
          canvas.drawPath(path, paint);
        }
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(data.tileSize, data.tileSize);
    sendPort.send(image);
  }
  static Rect _calculateTileBoundingBox(int tileX, int tileY, int zoom) {
    final n = math.pow(2.0, zoom);
    final lon1 = tileX / n * 360.0 - 180.0;
    final lat1 = math.atan(math.sin(math.pi * (1 - 2 * tileY / n))) * 180.0 / math.pi;
    final lon2 = (tileX + 1) / n * 360.0 - 180.0;
    final lat2 = math.atan(math.sin(math.pi * (1 - 2 * (tileY + 1) / n))) * 180.0 / math.pi;
    return Rect.fromLTRB(lon1, lat1, lon2, lat2);
  }

  static Offset _convertCoordinatesToOffset(double lon, double lat, int tileX, int tileY, int zoom, int tileSize) {
    final n = math.pow(2.0, zoom);
    final x = ((lon + 180.0) / 360.0 * n * tileSize) - (tileX * tileSize);
    final y = ((1.0 - math.log(math.tan(lat * math.pi / 180.0) + 1.0 / math.cos(lat * math.pi / 180.0)) / math.pi) / 2.0 * n * tileSize) - (tileY * tileSize);

    return Offset(x, y);
  }
}



class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


