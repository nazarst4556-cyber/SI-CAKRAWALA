class TelemetryMetric {
  final String name;
  final double value;
  final String unit;
  final double maxValue;
  final String status;
  final String icon; // material icon codepoint as string, unused here but kept for compat
  final List<double> history; // 60-point sparkline history

  const TelemetryMetric({
    required this.name,
    required this.value,
    required this.unit,
    this.maxValue = 100.0,
    required this.status,
    this.icon = '',
    this.history = const [],
  });

  TelemetryMetric copyWith({
    String? name,
    double? value,
    String? unit,
    double? maxValue,
    String? status,
    String? icon,
    List<double>? history,
  }) {
    return TelemetryMetric(
      name: name ?? this.name,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      maxValue: maxValue ?? this.maxValue,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      history: history ?? this.history,
    );
  }
}
