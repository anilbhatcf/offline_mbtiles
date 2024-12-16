// import 'package:turf/along.dart';
//
// Map<String, dynamic> bboxClip(Map<String, dynamic> geojson, BBox bbox) {
//   final clippedFeatures = <Map<String, dynamic>>[];
//
//   // Iterate over the features
//   for (var feature in geojson['features']) {
//     final geometry = feature['geometry'];
//     final type = geometry['type'];
//
//     if (type == 'Point') {
//       final coordinates = geometry['coordinates'];
//       if (isPointInBBox(coordinates, bbox)) {
//         clippedFeatures.add(feature);
//       }
//     } else if (type == 'LineString') {
//       final clippedLine = clipLine(geometry['coordinates'], bbox);
//       if (clippedLine.isNotEmpty) {
//         geometry['coordinates'] = clippedLine;
//         clippedFeatures.add(feature);
//       }
//     } else if (type == 'Polygon') {
//       final clippedPolygon = clipPolygon(geometry['coordinates'], bbox);
//       if (clippedPolygon.isNotEmpty) {
//         geometry['coordinates'] = clippedPolygon;
//         clippedFeatures.add(feature);
//       }
//     }
//   }
//
//   return {
//     'type': 'FeatureCollection',
//     'features': clippedFeatures,
//   };
// }
//
// bool isPointInBBox(List<dynamic> point, BBox bbox) {
//   return point[0] >= bbox.minX &&
//       point[0] <= bbox.maxX &&
//       point[1] >= bbox.minY &&
//       point[1] <= bbox.maxY;
// }
//
// List<List<double>> clipLine(List<dynamic> coordinates, BBox bbox) {
//   final clippedCoordinates = <List<double>>[];
//
//   for (int i = 0; i < coordinates.length - 1; i++) {
//     final p1 = coordinates[i];
//     final p2 = coordinates[i + 1];
//
//     // Add point if it is within the bbox
//     if (isPointInBBox(p1, bbox)) {
//       clippedCoordinates.add(List<double>.from(p1));
//     }
//
//     // Check if the line segment intersects the bbox
//     final intersection = getIntersection(p1, p2, bbox);
//     if (intersection != null) {
//       clippedCoordinates.add(intersection);
//     }
//   }
//
//   // Add the last point if it is within the bbox
//   if (isPointInBBox(coordinates.last, bbox)) {
//     clippedCoordinates.add(List<double>.from(coordinates.last));
//   }
//
//   return clippedCoordinates;
// }
//
// List<List<List<double>>> clipPolygon(List<dynamic> rings, BBox bbox) {
//   final clippedRings = <List<List<double>>>[];
//
//   for (var ring in rings) {
//     final clippedRing = clipLine(ring, bbox);
//     if (clippedRing.isNotEmpty) {
//       clippedRings.add(clippedRing);
//     }
//   }
//
//   return clippedRings;
// }
//
// List<double>? getIntersection(List<dynamic> p1, List<dynamic> p2, BBox bbox) {
//   // Check each edge of the bbox and return the intersection point if it exists
//   final edges = [
//     [bbox.minX, bbox.minY, bbox.maxX, bbox.minY], // bottom edge
//     [bbox.maxX, bbox.minY, bbox.maxX, bbox.maxY], // right edge
//     [bbox.maxX, bbox.maxY, bbox.minX, bbox.maxY], // top edge
//     [bbox.minX, bbox.maxY, bbox.minX, bbox.minY], // left edge
//   ];
//
//   for (var edge in edges) {
//     final intersection = lineIntersection(p1, p2, edge.sublist(0, 2), edge.sublist(2, 4));
//     if (intersection != null) {
//       return intersection;
//     }
//   }
//   return null;
// }
//
// List<double>? lineIntersection(
//     List<dynamic> p1, List<dynamic> p2, List<double> p3, List<double> p4) {
//   final double denominator = (p4[1] - p3[1]) * (p2[0] - p1[0]) -
//       (p4[0] - p3[0]) * (p2[1] - p1[1]);
//
//   if (denominator == 0) return null; // Lines are parallel or coincident
//
//   final double ua = ((p4[0] - p3[0]) * (p1[1] - p3[1]) -
//       (p4[1] - p3[1]) * (p1[0] - p3[0])) /
//       denominator;
//   final double ub = ((p2[0] - p1[0]) * (p1[1] - p3[1]) -
//       (p2[1] - p1[1]) * (p1[0] - p3[0])) /
//       denominator;
//
//   if (ua < 0 || ua > 1 || ub < 0 || ub > 1) return null; // No intersection
//
//   return [
//     p1[0] + ua * (p2[0] - p1[0]),
//     p1[1] + ua * (p2[1] - p1[1]),
//   ];
// }
//
