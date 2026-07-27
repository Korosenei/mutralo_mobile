import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../api/scanner_api.dart';
import '../../models/scanner_models.dart';
import '../../theme/colors.dart';

class VerificationScreen extends StatefulWidget {
  final String code;
  final ScannerVerifierResponse result;

  const VerificationScreen({super.key, required this.code, required this.result});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  PlatDuJour? _platChoisi;
  bool _validating = false;
  String? _erreur;
  String? _succes;

  @override
  void initState() {
    super.initState();
    final resa = widget.result.reservation;
    if (resa != null) {
      _platChoisi = PlatDuJour(id: resa.menuId, nom: resa.menuNom);
    }
  }

  Future<void> _handleValider() async {
    if (widget.result.platsDuJour.isNotEmpty && _platChoisi == null) {
      setState(() => _erreur = "Veuillez choisir un plat avant de valider.");
      return;
    }
    setState(() {
      _erreur = null;
      _validating = true;
    });
    try {
      final res = await ScannerApi.validerQRCode(widget.code, menuId: _platChoisi?.id);
      if (res.valide) {
        setState(() => _succes = res.message ?? "Ticket validé avec succès.");
      } else {
        setState(() => _erreur = res.error ?? "La validation a échoué.");
      }
    } on DioException catch (e) {
      setState(() => _erreur = e.response?.data?['error'] ?? "Erreur réseau lors de la validation.");
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    if (!result.valide) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vérification du ticket')),
        body: _CenterMessage(
          icon: Icons.close,
          iconColor: AppColors.danger,
          title: 'Code invalide',
          message: result.error ?? '',
          buttonLabel: 'Nouveau scan',
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
    }

    if (_succes != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vérification du ticket')),
        body: _CenterMessage(
          icon: Icons.check,
          iconColor: AppColors.success,
          title: 'Ticket validé',
          message: _succes!,
          buttonLabel: 'Scanner un autre ticket',
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification du ticket')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.client ?? '', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    'Matricule : ${result.matricule} · Agence : ${result.agence}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ticket ${result.ticketNumero} · ${result.ticketsRestants} restant(s)',
                    style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (result.reservation != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6EE),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Réservation existante : ${result.reservation!.menuNom}',
                  style: const TextStyle(color: AppColors.primaryDark, fontSize: 13),
                ),
              ),
            if (result.platsDuJour.isNotEmpty) ...[
              const Text('Plat consommé', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              ...result.platsDuJour.map((plat) {
                final selected = _platChoisi?.id == plat.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    onTap: () => setState(() => _platChoisi = plat),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFEAF6EE) : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plat.nom,
                            style: TextStyle(
                              fontSize: 14,
                              color: selected ? AppColors.primaryDark : AppColors.text,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                            ),
                          ),
                          if (plat.quantiteDisponible != null)
                            Text(
                              '${plat.quantiteDisponible} restant(s)',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
            if (_erreur != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_erreur!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ],
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _validating ? null : _handleValider,
              child: _validating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Valider le ticket'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterMessage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _CenterMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
