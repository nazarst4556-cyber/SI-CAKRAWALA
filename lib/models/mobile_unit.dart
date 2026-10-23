enum MobileUnitStatus {
  deployed,
  standby,
  redeploying,
  emergency,
}

class UnitPersonnel {
  final String name;
  final String rank;
  final String role;
  final String callsign;

  const UnitPersonnel({
    required this.name,
    required this.rank,
    required this.role,
    required this.callsign,
  });
}

class MobileUnit {
  final String id;
  final String code;
  final String name;
  final String location;
  final String coordinates;
  final int personnelCount;
  final List<UnitPersonnel> personnelList;
  final String task;
  final double batteryLevel; // 0.0 to 1.0
  final int signalBars; // 1 to 5
  final String signalDbm;
  final MobileUnitStatus status;
  final String encryptionStandard;
  final String ipAddress;
  final String satcomUplink;

  const MobileUnit({
    required this.id,
    required this.code,
    required this.name,
    required this.location,
    required this.coordinates,
    required this.personnelCount,
    required this.personnelList,
    required this.task,
    required this.batteryLevel,
    required this.signalBars,
    required this.signalDbm,
    required this.status,
    this.encryptionStandard = 'AES-256-GCM / KYBER-1024',
    this.ipAddress = '10.88.1.1',
    this.satcomUplink = 'CAKRAWALA-3A [LOCK]',
  });

  MobileUnit copyWith({
    String? id,
    String? code,
    String? name,
    String? location,
    String? coordinates,
    int? personnelCount,
    List<UnitPersonnel>? personnelList,
    String? task,
    double? batteryLevel,
    int? signalBars,
    String? signalDbm,
    MobileUnitStatus? status,
    String? encryptionStandard,
    String? ipAddress,
    String? satcomUplink,
  }) {
    return MobileUnit(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      personnelCount: personnelCount ?? this.personnelCount,
      personnelList: personnelList ?? this.personnelList,
      task: task ?? this.task,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      signalBars: signalBars ?? this.signalBars,
      signalDbm: signalDbm ?? this.signalDbm,
      status: status ?? this.status,
      encryptionStandard: encryptionStandard ?? this.encryptionStandard,
      ipAddress: ipAddress ?? this.ipAddress,
      satcomUplink: satcomUplink ?? this.satcomUplink,
    );
  }
}
