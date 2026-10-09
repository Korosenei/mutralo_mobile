import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/ticket_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/countdown_timer.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<TicketProvider>().charger());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TicketProvider>();
    final qr = provider.codeQR;

    return Scaffold(
      appBar: const AppHeader(titre: Text('Mon QR code')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 110),
          children: [
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
              child: provider.chargement && qr == null
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : (qr != null && !qr.estExpire)
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            QrImageView(data: qr.code, size: 220),
                            const SizedBox(height: AppSpacing.md),
                            CountdownTimer(expireLe: qr.expireLe, onExpire: () => context.read<TicketProvider>().charger()),
                          ],
                        )
                      : const Text('Aucun QR code actif', style: TextStyle(color: AppColors.textMuted)),
            ),
            if (provider.erreur != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(provider.erreur!.message, style: const TextStyle(color: AppColors.danger), textAlign: TextAlign.center),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.generationEnCours ? null : () => context.read<TicketProvider>().genererCodeQR(),
                child: provider.generationEnCours
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(qr != null ? 'Régénérer le code' : 'Générer mon QR code'),
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
