class BlockchainBlock {
  final int height;
  final String hash;
  final String prevHash;
  final int transactionsCount;
  final String validator;
  final String timestamp;
  final bool isImmutable;
  final String merkleRoot;
  final int nonce;
  final String dilithiumSignature;
  final String kyberTag;
  final List<String> tacticalLogs;

  const BlockchainBlock({
    required this.height,
    required this.hash,
    required this.prevHash,
    required this.transactionsCount,
    required this.validator,
    required this.timestamp,
    this.isImmutable = true,
    this.merkleRoot = "0x7F4A89C1D2E3B4A5C6D7E8F90A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F8A9B",
    this.nonce = 1849204,
    this.dilithiumSignature = "DILITHIUM5:8F2E4A...91C0B3 (NIST FIPS 204 Validated)",
    this.kyberTag = "KYBER-1024-ENCAP-SESSION-OK",
    this.tacticalLogs = const [
      "ISOLASI_ANCAMAN: APT-29 hash payload 0x415054 terisolasi di Kodam VI/Mlw",
      "KONTRAMAUSUR_DNS: 890 kueri anomali di-sinkhole dari Sektor Natuna",
      "AUTHENTIKASI_PANGLIMA: Perintah status ELEVATED tervalidasi tanda tangan digital",
    ],
  });
}
