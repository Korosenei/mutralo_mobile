import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/scanner_api.dart';
import '../../models/scanner_models.dart';
import '../../theme/colors.dart';

class ConsommationsScreen extends StatefulWidget {
  const ConsommationsScreen({super.key});

  @override
  State<ConsommationsScreen> createState() => _ConsommationsScreenState();
}

class _ConsommationsScreenState extends State<ConsommationsScreen> {
  ConsommationsResponse? _data;
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _charger([String? search]) async {
    try {
      final res = await ScannerApi.getConsommations(search: search);
      if (mounted) setState(() => _data = res);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _charger(_searchCtrl.text),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 110),
            children: [
              const Text('Consommations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.md),
              if (_data != null)
                Row(
                  children: [
                    _StatBox(label: "Aujourd'hui", value: _data!.aujourdHui),
                    const SizedBox(width: AppSpacing.sm),
                    _StatBox(label: 'Cette semaine', value: _data!.cetteSemaine),
                    const SizedBox(width: AppSpacing.sm),
                    _StatBox(label: 'Ce mois', value: _data!.ceMois),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(hintText: 'Rechercher un client, matricule, ticket…'),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => _charger(value),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_data == null || _data!.resultats.isEmpty)
                if (!_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xl),
                    child: Center(child: Text('Aucune consommation trouvée.', style: TextStyle(color: AppColors.textMuted))),
                  )
                else
                  const SizedBox()
              else
                ..._data!.resultats.map((item) => _ConsommationRow(item: item)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _ConsommationRow extends StatelessWidget {
  final ConsommationItem item;
  const _ConsommationRow({required this.item});

  String _formatTime(String iso) {
    try {
      return DateFormat('HH:mm').format(DateTime.parse(iso));
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.client, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('${item.matricule} · ${item.agence}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.numeroTicket, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(_formatTime(item.dateConsommation), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
