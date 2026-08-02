import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../api/restaurants_api.dart';
import '../../models/restaurant_models.dart';
import '../../theme/colors.dart';
import 'reservations_screen.dart';

class MenusScreen extends StatefulWidget {
  const MenusScreen({super.key});

  @override
  State<MenusScreen> createState() => _MenusScreenState();
}

class _MenusScreenState extends State<MenusScreen> {
  List<MenuJour> _menus = [];
  bool _loading = true;
  int? _reservingId;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final data = await RestaurantsApi.getMenusDuJour();
      if (mounted) setState(() => _menus = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reserver(MenuJour menu) async {
    setState(() => _reservingId = menu.id);
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await RestaurantsApi.creerReservation(menuId: menu.id, dateReservation: today);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Réservation envoyée pour "${menu.nom}".')),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ??
          e.response?.data?.toString() ??
          "Impossible de réserver ce plat.";
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Réservation impossible'),
            content: Text(msg.toString()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reservingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Regroupement par restaurant pour un affichage plus lisible.
    final Map<String, List<MenuJour>> parRestaurant = {};
    for (final m in _menus) {
      parRestaurant.putIfAbsent(m.restaurantNom.isEmpty ? 'Restaurant' : m.restaurantNom, () => []).add(m);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menus du jour'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note_outlined),
            tooltip: 'Mes réservations',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReservationsScreen()),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _charger,
              child: parRestaurant.isEmpty
                  ? ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: AppSpacing.xl),
                          child: Center(
                            child: Text(
                              "Aucun menu disponible aujourd'hui.",
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: parRestaurant.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.storefront, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    entry.key,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ...entry.value.map((menu) => _MenuCard(
                                    menu: menu,
                                    loading: _reservingId == menu.id,
                                    onReserver: () => _reserver(menu),
                                  )),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuJour menu;
  final bool loading;
  final VoidCallback onReserver;

  const _MenuCard({required this.menu, required this.loading, required this.onReserver});

  @override
  Widget build(BuildContext context) {
    final epuise = !menu.estDisponible || (menu.quantiteDisponible == 0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menu.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                if (menu.description != null && menu.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      menu.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                if (menu.quantiteDisponible != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      epuise ? 'Épuisé' : '${menu.quantiteDisponible} restant(s)',
                      style: TextStyle(
                        fontSize: 11,
                        color: epuise ? AppColors.danger : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: epuise || loading ? null : onReserver,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              child: loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Réserver'),
            ),
          ),
        ],
      ),
    );
  }
}
