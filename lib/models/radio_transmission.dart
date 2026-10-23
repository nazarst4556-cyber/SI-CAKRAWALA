enum RadioChannel {
  secure,
  broadcast,
  freqHopping,
}

class RadioTransmission {
  final String id;
  final RadioChannel channel;
  final String callsign;
  final String time;
  final String frequency;
  final String message;
  final bool isEncrypted;
  final String cipherAlgorithm;
  final bool isEmergency;

  const RadioTransmission({
    required this.id,
    required this.channel,
    required this.callsign,
    required this.time,
    required this.frequency,
    required this.message,
    this.isEncrypted = true,
    this.cipherAlgorithm = 'KYBER-1024',
    this.isEmergency = false,
  });
}
