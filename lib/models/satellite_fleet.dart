class SatelliteFleet {
  final String code;
  final String type;
  final String altitude;
  final String inclination;
  final String resolution;
  final String status;
  final double health;

  const SatelliteFleet({
    required this.code,
    required this.type,
    required this.altitude,
    required this.inclination,
    required this.resolution,
    required this.status,
    required this.health,
  });
}
