import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/mobile_unit.dart';

class EmergencyDispatchModal extends StatefulWidget {
  final List<MobileUnit> units;
  final Function(String target, String directive, String message)? onDispatchSent;

  const EmergencyDispatchModal({
    super.key,
    required this.units,
    this.onDispatchSent,
  });

  @override
  State<EmergencyDispatchModal> createState() => _EmergencyDispatchModalState();
}

class _EmergencyDispatchModalState extends State<EmergencyDispatchModal> {
  String _selectedTarget = 'SELURUH ARMADA (BROADCAST)';
  String _selectedDirective = 'KONTRAMEASUR SIBER DEFCON-1';
  final TextEditingController _messageController = TextEditingController(
    text: 'PRIORITAS UTAMA: Seluruh unit segera aktifkan mode isolasi frekuensi dan karantina gateway pamtas seketika!',
  );
  bool _isDispatched = false;

  final List<String> _directives = [
    'KONTRAMEASUR SIBER DEFCON-1',
    'MODE SENYAP FREKUENSI (RADIO SILENCE)',
    'PERKUATAN GELEMBUNG PERTAHANAN MABES',
    'INTERSEPSI TRAFIK ANOMALI SEGERA',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _executeDispatch() {
    setState(() {
      _isDispatched = true;
    });

    if (widget.onDispatchSent != null) {
      widget.onDispatchSent!(
        _selectedTarget,
        _selectedDirective,
        _messageController.text,
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final targets = ['SELURUH ARMADA (BROADCAST)', ...widget.units.map((u) => u.code)];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.merahVibrant, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.merahVibrant.withValues(alpha: 0.25),
              blurRadius: 36,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.merahVibrant,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emergency_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PROTOKOL PERINTAH DARURAT MILITER",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          "Pusat Komando Operasi Lapangan TNI AD • Hak Akses Komandan",
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: _isDispatched
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.tniGreenNeon, size: 54),
                          const SizedBox(height: 16),
                          const Text(
                            "PERINTAH DARURAT BERHASIL DITRANSMISIKAN",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Target: $_selectedTarget\nKode Direktif: $_selectedDirective\nEnkripsi Kuantum Kyber-1024 diterapkan ke seluruh simpul radio.",
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace'),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Target Selector
                        const Text(
                          "SASARAN DISPATCH UNIT",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.4)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTarget,
                              isExpanded: true,
                              items: targets.map((t) {
                                return DropdownMenuItem(
                                  value: t,
                                  child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedTarget = val);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Directive Selector
                        const Text(
                          "DIREKTIF TAKTIS OTORISASI",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.4)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDirective,
                              isExpanded: true,
                              items: _directives.map((d) {
                                return DropdownMenuItem(
                                  value: d,
                                  child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.merahVibrant)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedDirective = val);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Directive Text Message
                        const Text(
                          "PESAN SUARA / ENKRIPSI RADIOGRAM",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _messageController,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.merahVibrant, width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Execute Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.merahVibrant,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text(
                              "TRANSMISIKAN PERINTAH DARURAT",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            onPressed: _executeDispatch,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
