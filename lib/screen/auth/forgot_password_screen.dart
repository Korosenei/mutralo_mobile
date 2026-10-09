import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _demandeEnvoyee = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    final auth = context.read<AuthProvider>();
    final succes =
        await auth.demanderReinitialisationMotDePasse(_emailCtrl.text.trim());
    if (succes && mounted) setState(() => _demandeEnvoyee = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      // Pas d'AppBar ici : sur un thème où le fond de l'AppBar diffère
      // du fond du Scaffold, la réservation de hauteur peut mal se
      // combiner avec le logo positionné juste en dessous et le
      // chevaucher. Un simple bouton retour dans le flux normal du
      // body élimine ce risque, quel que soit le thème global.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.text,
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/images/logo_mutralo.png',
                            fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text('MUTRALO RESTO',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text)),
                    const Text('Gestion de la Cantine MUTRALO',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textMuted)),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child:
                          _demandeEnvoyee ? _confirmation() : _formulaire(auth),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulaire(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Mot de passe oublié',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          "Renseignez l'adresse email de votre compte. Si un compte existe, "
          "un nouveau mot de passe vous sera envoyé par email.",
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
              labelText: 'Email', hintText: 'votre.email@lonab.bf'),
        ),
        if (auth.derniereErreur != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(auth.derniereErreur!.message,
              style: const TextStyle(color: AppColors.danger, fontSize: 13)),
        ],
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: auth.enCours ? null : _envoyer,
            child: auth.enCours
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Envoyer le lien'),
          ),
        ),
      ],
    );
  }

  Widget _confirmation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mark_email_read_outlined,
            color: AppColors.primary, size: 56),
        const SizedBox(height: AppSpacing.md),
        const Text('Email envoyé',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Si un compte existe pour ${_emailCtrl.text.trim()}, un nouveau mot de passe "
          "vient de lui être envoyé par email.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retour à la connexion')),
        ),
      ],
    );
  }
}
