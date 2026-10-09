import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ancienCtrl = TextEditingController();
  final _nouveauCtrl = TextEditingController();
  final _confirmationCtrl = TextEditingController();

  bool _ancienVisible = false;
  bool _nouveauVisible = false;
  bool _confirmationVisible = false;

  @override
  void dispose() {
    _ancienCtrl.dispose();
    _nouveauCtrl.dispose();
    _confirmationCtrl.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();
    final succes = await provider.changerMotDePasse(
      ancienMotDePasse: _ancienCtrl.text,
      nouveauMotDePasse: _nouveauCtrl.text,
      confirmationMotDePasse: _confirmationCtrl.text,
    );

    if (!mounted) return;

    if (succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe modifié avec succès.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final erreur = provider.derniereErreur?.message ??
          'Impossible de modifier le mot de passe.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erreur),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final enCours = context.watch<AuthProvider>().enCours;

    return Scaffold(
      appBar: AppBar(title: const Text('Changer le mot de passe')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const _Intro(),
              const SizedBox(height: AppSpacing.xl),

              _ChampMotDePasse(
                controleur: _ancienCtrl,
                label: 'Mot de passe actuel',
                visible: _ancienVisible,
                onToggleVisible: () =>
                    setState(() => _ancienVisible = !_ancienVisible),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Champ obligatoire.'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),

              _ChampMotDePasse(
                controleur: _nouveauCtrl,
                label: 'Nouveau mot de passe',
                visible: _nouveauVisible,
                onToggleVisible: () =>
                    setState(() => _nouveauVisible = !_nouveauVisible),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ obligatoire.';
                  if (v.length < 4) {
                    return 'Au moins 4 caractères.';
                  }
                  if (v == _ancienCtrl.text) {
                    return 'Doit être différent de l\'ancien.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              _ChampMotDePasse(
                controleur: _confirmationCtrl,
                label: 'Confirmer le nouveau mot de passe',
                visible: _confirmationVisible,
                onToggleVisible: () => setState(
                    () => _confirmationVisible = !_confirmationVisible),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ obligatoire.';
                  if (v != _nouveauCtrl.text) {
                    return 'Les mots de passe ne correspondent pas.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: enCours ? null : _soumettre,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: enCours
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Enregistrer',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              const _NotePolitique(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sous-widgets ────────────────────────────────────────────────────────

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Text(
              'Pour votre sécurité, choisissez un mot de passe '
              'que vous n\'utilisez nulle part ailleurs.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChampMotDePasse extends StatelessWidget {
  final TextEditingController controleur;
  final String label;
  final bool visible;
  final VoidCallback onToggleVisible;
  final String? Function(String?) validator;

  const _ChampMotDePasse({
    required this.controleur,
    required this.label,
    required this.visible,
    required this.onToggleVisible,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controleur,
      obscureText: !visible,
      validator: validator,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: onToggleVisible,
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
          tooltip: visible ? 'Masquer' : 'Afficher',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

class _NotePolitique extends StatelessWidget {
  const _NotePolitique();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Le mot de passe doit contenir au moins 4 caractères. '
      'Les comptes de type « Numérique » n\'acceptent que des chiffres.',
      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
    );
  }
}