import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dio/dio.dart';
import '../../api/tickets_api.dart';
import '../../models/ticket.dart';
import '../../theme/colors.dart';
import '../../widgets/countdown_timer.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  CodeQR? _qr;
  bool _loading = true;
  bool _generating = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() => _erreur = null);
    try {
      final actif = await TicketsApi.getCodeQRActif();
      if (mounted) setState(() => _qr = actif);
    } catch (_) {
      if (mounted) setState(() => _erreur = "Impossible de charger le QR code.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGenerer() async {
    setState(() {
      _generating = true;
      _erreur = null;
    });
    try {
      final nouveau = await TicketsApi.genererCodeQR();
      if (mounted) setState(() => _qr = nouveau);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ??
          "Impossible de générer un QR code. Vérifiez que vous avez un ticket disponible.";
      if (mounted) {
        setState(() => _erreur = msg);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Génération impossible"),
            content: Text(msg),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 110,
                ),
                children: [
                    const Text(
                      'Mon QR code',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Présentez ce code au gestionnaire du restaurant pour consommer votre ticket du jour.",
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 300),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _qr != null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                QrImageView(data: _qr!.code, size: 220),
                                const SizedBox(height: AppSpacing.md),
                                CountdownTimer(
                                  expireLe: _qr!.expireLe,
                                  onExpire: () => setState(() => _qr = null),
                                ),
                              ],
                            )
                          : const Text('Aucun QR code actif', style: TextStyle(color: AppColors.textMuted)),
                    ),
                    if (_erreur != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(_erreur!, style: const TextStyle(color: AppColors.danger), textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _generating ? null : _handleGenerer,
                        child: _generating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(_qr != null ? 'Régénérer le code' : 'Générer mon QR code'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      "Générer un nouveau code invalide automatiquement le précédent.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
    );
  }
}
