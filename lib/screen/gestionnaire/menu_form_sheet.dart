import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../providers/gestionnaire_espace_provider.dart';
import '../../theme/colors.dart';

/// Correspondance jour de semaine (int Dart, lundi=1..dimanche=7) -> valeur
/// stockée côté backend (Menu.JOUR_CHOICES). Le gestionnaire choisit une
/// DATE ; le jour_semaine en est dérivé automatiquement, ce qui évite
/// toute incohérence entre les deux (ex: date un mardi mais jour="LUNDI").
const Map<int, String> _joursParWeekday = {
  DateTime.monday: 'LUNDI',
  DateTime.tuesday: 'MARDI',
  DateTime.wednesday: 'MERCREDI',
  DateTime.thursday: 'JEUDI',
  DateTime.friday: 'VENDREDI',
};

const _nomsJoursAffichage = {
  'LUNDI': 'Lundi',
  'MARDI': 'Mardi',
  'MERCREDI': 'Mercredi',
  'JEUDI': 'Jeudi',
  'VENDREDI': 'Vendredi',
};

class MenuFormSheet extends StatefulWidget {
  final Menu? menu;
  const MenuFormSheet({super.key, this.menu});

  @override
  State<MenuFormSheet> createState() => _MenuFormSheetState();
}

class _MenuFormSheetState extends State<MenuFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _prixCtrl;
  late final TextEditingController _quantiteCtrl;

  late DateTime _dateSelectionnee;
  late String _jour;

  bool _envoiEnCours = false;
  String? _erreurGenerale;

  // Nouvelle photo choisie localement (pas encore uploadée). Si null et
  // qu'on est en édition, l'image existante (widget.menu.imageUrl) reste
  // affichée et n'est PAS modifiée côté serveur (on n'envoie 'image' que
  // si l'utilisateur en choisit une nouvelle).
  File? _imageChoisie;
  final _picker = ImagePicker();

  bool get _estEdition => widget.menu != null;

  DateTime get _aujourdhui {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Prochain jour ouvré (lundi-vendredi) à partir d'une date donnée —
  /// utilisé pour choisir une date par défaut sensée un week-end.
  DateTime _prochainJourOuvre(DateTime depuis) {
    var d = depuis;
    while (!_joursParWeekday.containsKey(d.weekday)) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  @override
  void initState() {
    super.initState();
    final m = widget.menu;
    _nomCtrl = TextEditingController(text: m?.nom ?? '');
    _descriptionCtrl = TextEditingController(text: m?.description ?? '');
    _prixCtrl = TextEditingController(text: m?.prix ?? '');
    _quantiteCtrl =
        TextEditingController(text: m?.quantiteDisponible?.toString() ?? '');

    if (m?.date != null) {
      _dateSelectionnee = DateTime(m!.date!.year, m.date!.month, m.date!.day);
    } else {
      _dateSelectionnee = _prochainJourOuvre(_aujourdhui);
    }
    _jour = m?.jourSemaine ??
        (_joursParWeekday[_dateSelectionnee.weekday] ?? 'LUNDI');
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _descriptionCtrl.dispose();
    _prixCtrl.dispose();
    _quantiteCtrl.dispose();
    super.dispose();
  }

  String? _validerObligatoire(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Ce champ est obligatoire.';
    }
    return null;
  }

  String? _validerNombre(String? valeur) {
    final obligatoire = _validerObligatoire(valeur);
    if (obligatoire != null) return obligatoire;
    if (int.tryParse(valeur!.trim()) == null) return 'Nombre invalide.';
    return null;
  }

  String? _validerDecimal(String? valeur) {
    final obligatoire = _validerObligatoire(valeur);
    if (obligatoire != null) return obligatoire;
    final normalise =
        valeur!.trim().replaceAll(',', '.'); // tolère la virgule FR
    if (double.tryParse(normalise) == null) return 'Nombre invalide.';
    return null;
  }

  Future<void> _choisirDate() async {
    final premiereDate = _aujourdhui;
    final derniereDate =
        _aujourdhui.add(const Duration(days: 28)); // 4 semaines à l'avance

    final initiale = _dateSelectionnee.isBefore(premiereDate)
        ? premiereDate
        : _dateSelectionnee;

    final choisie = await showDatePicker(
      context: context,
      initialDate: initiale,
      firstDate: premiereDate, // ← empêche toute date passée
      lastDate: derniereDate,
      selectableDayPredicate: (jour) => _joursParWeekday
          .containsKey(jour.weekday), // lundi→vendredi uniquement
      helpText: 'Choisir la date du plat',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );

    if (choisie != null) {
      setState(() {
        _dateSelectionnee = choisie;
        _jour = _joursParWeekday[choisie.weekday]!;
      });
    }
  }

  Future<void> _choisirImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final fichier = await _picker.pickImage(
        source: source, maxWidth: 1600, imageQuality: 85);
    if (fichier != null) {
      setState(() => _imageChoisie = File(fichier.path));
    }
  }

  Future<void> _enregistrer() async {
    final formValide = _formKey.currentState?.validate() ?? false;
    if (!formValide) return;

    setState(() {
      _envoiEnCours = true;
      _erreurGenerale = null;
    });

    final donnees = {
      'nom': _nomCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'jour_semaine': _jour,
      'prix': _prixCtrl.text.trim(),
      'quantite_disponible': int.parse(_quantiteCtrl.text.trim()),
      'date': _fmtDate(_dateSelectionnee),
    };

    final provider = context.read<GestionnaireEspaceProvider>();
    final succes = _estEdition
        ? await provider.modifierMenu(widget.menu!.id, donnees,
            imagePath: _imageChoisie?.path)
        : await provider.creerMenu(donnees, imagePath: _imageChoisie?.path);

    if (!mounted) return;
    setState(() => _envoiEnCours = false);

    if (succes) {
      Navigator.of(context).pop();
    } else {
      setState(() => _erreurGenerale =
          provider.erreur?.message ?? 'Une erreur est survenue.');
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
        decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: AppSpacing.md),
                Text(_estEdition ? 'Modifier le plat' : 'Ajouter un plat',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                Center(
                    child: _SelecteurImage(
                        fichierLocal: _imageChoisie,
                        urlExistante: widget.menu?.imageUrl,
                        onTap: _choisirImage)),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom du plat'),
                  validator: _validerObligatoire,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Description (optionnel)'),
                ),
                const SizedBox(height: AppSpacing.md),
                // Sélecteur de date — remplace l'ancien dropdown de jour.
                // Le gestionnaire peut désormais planifier des plats pour
                // la semaine en cours ET les semaines suivantes ; le
                // jour_semaine est dérivé automatiquement de la date et
                // aucune date passée n'est sélectionnable.
                InkWell(
                  onTap: _choisirDate,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date du plat',
                      suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                    child: Text(
                      '${_nomsJoursAffichage[_jour]} · '
                      '${_dateSelectionnee.day.toString().padLeft(2, '0')}/'
                      '${_dateSelectionnee.month.toString().padLeft(2, '0')}/'
                      '${_dateSelectionnee.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prixCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Prix (FCFA)'),
                        validator: _validerDecimal, // ← remplace _validerNombre
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _quantiteCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Quantité dispo.'),
                        validator: _validerNombre,
                      ),
                    ),
                  ],
                ),
                if (_erreurGenerale != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_erreurGenerale!,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _envoiEnCours ? null : _enregistrer,
                  child: _envoiEnCours
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_estEdition ? 'Enregistrer' : 'Ajouter le plat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Vignette carrée cliquable : aperçu de la nouvelle photo choisie, sinon
/// l'image existante du plat (édition), sinon un simple bouton "Ajouter".
class _SelecteurImage extends StatelessWidget {
  final File? fichierLocal;
  final String? urlExistante;
  final VoidCallback onTap;

  const _SelecteurImage(
      {required this.fichierLocal,
      required this.urlExistante,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          image: fichierLocal != null
              ? DecorationImage(
                  image: FileImage(fichierLocal!), fit: BoxFit.cover)
              : (urlExistante != null
                  ? DecorationImage(
                      image: NetworkImage(urlExistante!), fit: BoxFit.cover)
                  : null),
        ),
        child: (fichierLocal == null && urlExistante == null)
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: AppColors.primary, size: 22),
                  SizedBox(height: 4),
                  Text('Photo',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
      ),
    );
  }
}
