import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:geojson/geojson.dart';

// class GeoJsonProcessor {
//
//
// /// Fetch renderable GeoJSON data within the current viewport.
// Future<List<GeoJsonFeature>> fetchRenderableData(
//     double zoom, double centerLng, double centerLat) async {
//   // Load your GeoJSON data (replace with your asset or data source)
//   final geojsonString = await rootBundle.loadString('assets/large.geojson');
//   final geojson = GeoJson();
//   final features = <GeoJsonFeature>[];
//
//   // Calculate the visible bounding box based on zoom and center coordinates.
//   final boundingBox = _calculateBoundingBox(zoom, centerLng, centerLat);
//
//   // Filter features based on bounding box
//   geojson.processedStream.listen((GeoJsonFeature feature) {
//     if (_isFeatureWithinBounds(feature, boundingBox)) {
//       features.add(feature);
//     }
//   });
//
//   await geojson.parse(geojsonString);
//   return features;
// }
//
// /// Calculate the visible bounding box for the given zoom level and center.
// LatLngBounds _calculateBoundingBox(double zoom, double centerLng, double centerLat) {
//   // Approximate calculations, these need fine-tuning based on actual screen size and map projection
//   double lngDiff = 360.0 / (1 << zoom);
//   double latDiff = 170.1022 / (1 << zoom); // Adjust this value to get correct latitude span
//
//   return LatLngBounds(
//     LatLng(centerLat - latDiff, centerLng - lngDiff),
//     LatLng(centerLat + latDiff, centerLng + lngDiff),
//   );
// }
//
// /// Check if a feature is within the given bounding box.
// bool _isFeatureWithinBounds(GeoJsonFeature feature, LatLngBounds bounds) {
//   // This is a basic example that checks if the centroid of the feature is within bounds.
//   // You may want to refine this to check for intersection with the bounding box.
//   if (feature.type == GeoJsonFeatureType.point) {
//     final point = feature.geometry as GeoJsonPoint;
//     return bounds.contains(LatLng(point.geoPoint.latitude, point.geoPoint.longitude));
//   } else if (feature.type == GeoJsonFeatureType.polygon) {
//     final polygon = feature.geometry as GeoJsonPolygon;
//     for (final ring in polygon.geoSeries) {
//       for (final point in ring.geoPoints) {
//         if (bounds.contains(LatLng(point.latitude, point.longitude))) {
//           return true;
//         }
//       }
//     }
//   }
//   return false;
// }
// }
