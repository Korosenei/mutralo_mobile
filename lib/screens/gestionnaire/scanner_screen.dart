import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';
import '../../api/scanner_api.dart';
import '../../theme/colors.dart';
import 'verification_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _locked = false;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_locked) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    _locked = true;
    setState(() => _loading = true);
    await _controller.stop();

    try {
      final result = await ScannerApi.verifierQRCode(code);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerificationScreen(code: code, result: result),
        ),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ??
          "Erreur lors de la vérification du code. Vérifiez votre connexion.";
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Erreur"),
            content: Text(msg),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Réessayer")),
            ],
          ),
        );
      }
    } finally {
      _locked = false;
      if (mounted) {
        setState(() => _loading = false);
        await _controller.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleDetect),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 3),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  _loading ? "Vérification en cours…" : "Placez le QR code du client dans le cadre",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
