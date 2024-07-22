import 'dart:ui';

class MapModel {
    final List<MapAreaModel> areas = [];
    double width = 0, height = 0, centerX = 0, centerY = 0, dockX = 0, dockY = 0, dockHeading = 0;
}

class MapAreaModel {
  final Path outline;
  final int area_type;

  MapAreaModel(this.outline, this.area_type);
}