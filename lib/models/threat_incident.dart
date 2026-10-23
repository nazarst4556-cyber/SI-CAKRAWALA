enum ThreatSeverity { low, medium, high, critical }

class ThreatIncident {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final ThreatSeverity severity;
  final String sourceIp;
  final String targetSector;
  final bool isMitigated;

  const ThreatIncident({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    required this.sourceIp,
    required this.targetSector,
    this.isMitigated = false,
  });
}
