import 'dart:isolate';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:offline_mbtiles/tiledata.dart';

void main() {
  runApp(MaterialApp(home: TileRenderer()));
}

class TileRenderer extends StatefulWidget {
  @override
  _TileRendererState createState() => _TileRendererState();
}

class _TileRendererState extends State<TileRenderer> {
  static const int tileSize = 256;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tile Renderer')),
      body: Center(
        child: FutureBuilder<List<Offset>>(
          future: _getTile(10, 1000, 1000),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data != null) {
                return CustomPaint(
                  painter: GeoJsonPainter(snapshot.data!),
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

  Future<List<Offset>> _getTile(int zoomLevel, int x, int y) async {
    final tileData = TileData(_exampleGeoJson(), tileSize, zoomLevel, x, y);
    final receivePort = ReceivePort();
    await Isolate.spawn(_processTileInIsolate, [tileData, receivePort.sendPort]);
    final offsets = await receivePort.first as List<Offset>;
    return offsets;
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

    final geoJson = GeoJson();
    await geoJson.parse(data.geoJson);

    List<Offset> offsets = [];

    // Define the visible bounding box in tile coordinates
    final visibleBoundingBox = _calculateTileBoundingBox(data.tileX, data.tileY, data.zoomLevel);

    for (var feature in geoJson.features) {
      if (_featureIntersectsBoundingBox(feature, visibleBoundingBox)) {
        if (feature.type == GeoJsonFeatureType.polygon) {
          final polygon = feature.geometry as GeoJsonPolygon;
          for (final ring in polygon.geoSeries) {
            for (final point in ring.geoPoints) {
              final offset = _convertCoordinatesToOffset(
                  point.longitude, point.latitude, data.tileX, data.tileY, data.zoomLevel, data.tileSize);
              offsets.add(offset);
            }
          }
        }
      }
    }

    sendPort.send(offsets);
  }

  static bool _featureIntersectsBoundingBox(GeoJsonFeature feature, Rect boundingBox) {
    final featureBoundingBox = _getFeatureBoundingBox(feature);
    return boundingBox.overlaps(featureBoundingBox);
  }

  static Rect _getFeatureBoundingBox(GeoJsonFeature feature) {
    // Calculate the bounding box of the feature
    double minLon = double.infinity, maxLon = double.negativeInfinity;
    double minLat = double.infinity, maxLat = double.negativeInfinity;

    if (feature.geometry is GeoJsonPoint) {
      final point = feature.geometry as GeoJsonPoint;
      minLon = maxLon = point.geoPoint.longitude;
      minLat = maxLat = point.geoPoint.latitude;
    } else if (feature.geometry is GeoJsonLine) {
      final lineString = feature.geometry as GeoJsonLine;
      // for (final ring in lineString.geoSerie!) {
      //   for (final point in ring.geoPoints) {
      //     if (point.longitude < minLon) minLon = point.longitude;
      //     if (point.longitude > maxLon) maxLon = point.longitude;
      //     if (point.latitude < minLat) minLat = point.latitude;
      //     if (point.latitude > maxLat) maxLat = point.latitude;
      //   }
      // }
    } else if (feature.geometry is GeoJsonPolygon) {
      final polygon = feature.geometry as GeoJsonPolygon;
      for (final ring in polygon.geoSeries) {
        for (final point in ring.geoPoints) {
          if (point.longitude < minLon) minLon = point.longitude;
          if (point.longitude > maxLon) maxLon = point.longitude;
          if (point.latitude < minLat) minLat = point.latitude;
          if (point.latitude > maxLat) maxLat = point.latitude;
        }
      }
    }

    return Rect.fromLTRB(minLon, minLat, maxLon, maxLat);
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

class GeoJsonPainter extends CustomPainter {
  final List<Offset> offsets;

  GeoJsonPainter(this.offsets);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    Path path = Path();
    if (offsets.isNotEmpty) {
      path.moveTo(offsets.first.dx, offsets.first.dy);
      for (var offset in offsets) {
        path.lineTo(offset.dx, offset.dy);
      }
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
