import 'dart:math';

class Point {
  final double x, y;

  Point(this.x, this.y);
}

class GeoJSON {
  List<Point> coordinates;

  GeoJSON(this.coordinates);
}

double _perpendicularDistance(Point p, Point lineStart, Point lineEnd) {
  double dx = lineEnd.x - lineStart.x;
  double dy = lineEnd.y - lineStart.y;

  if (dx == 0 && dy == 0) {
    dx = p.x - lineStart.x;
    dy = p.y - lineStart.y;
    return sqrt(dx * dx + dy * dy);
  }

  double t = ((p.x - lineStart.x) * dx + (p.y - lineStart.y) * dy) /
      (dx * dx + dy * dy);

  if (t < 0) {
    dx = p.x - lineStart.x;
    dy = p.y - lineStart.y;
  } else if (t > 1) {
    dx = p.x - lineEnd.x;
    dy = p.y - lineEnd.y;
  } else {
    double closestX = lineStart.x + t * dx;
    double closestY = lineStart.y + t * dy;
    dx = p.x - closestX;
    dy = p.y - closestY;
  }

  return sqrt(dx * dx + dy * dy);
}

List<Point> douglasPeucker(List<Point> points, double epsilon) {
  if (points.length < 3) return points;

  int index = -1;
  double maxDistance = 0;

  for (int i = 1; i < points.length - 1; i++) {
    double distance =
    _perpendicularDistance(points[i], points[0], points.last);
    if (distance > maxDistance) {
      index = i;
      maxDistance = distance;
    }
  }

  if (maxDistance > epsilon) {
    List<Point> left = douglasPeucker(points.sublist(0, index + 1), epsilon);
    List<Point> right = douglasPeucker(points.sublist(index), epsilon);

    return left.sublist(0, left.length - 1) + right;
  } else {
    return [points.first, points.last];
  }
}


GeoJSON simplifyGeoJSON(GeoJSON geoJson, double epsilon) {
  List<Point> simplifiedCoordinates =
  douglasPeucker(geoJson.coordinates, epsilon);
  return GeoJSON(simplifiedCoordinates);
}

