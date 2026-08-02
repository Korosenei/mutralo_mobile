import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/tickets_api.dart';
import '../../models/ticket.dart';
import '../../theme/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Notif> _notifs = [];
  bool _loading = true;

  static const _prioriteColors = {
    'BASSE': AppColors.textMuted,
    'MOYENNE': AppColors.primary,
    'HAUTE': AppColors.warning,
    'URGENTE': AppColors.danger,
  };

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final (_, notifs) = await TicketsApi.getNotificationsNonLues();
      if (mounted) setState(() => _notifs = notifs);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _marquerLu(int id) async {
    await TicketsApi.marquerNotificationLue(id);
    setState(() => _notifs.removeWhere((n) => n.id == id));
  }

  Future<void> _toutMarquer() async {
    await TicketsApi.marquerToutesLues();
    setState(() => _notifs = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifs.isNotEmpty)
            TextButton(
              onPressed: _toutMarquer,
              child: const Text('Tout marquer comme lu', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _charger,
                child: _notifs.isEmpty && !_loading
                    ? ListView(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: AppSpacing.xl),
                            child: Center(
                              child: Text("Aucune notification non lue.", style: TextStyle(color: AppColors.textMuted)),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        itemCount: _notifs.length,
                        itemBuilder: (context, index) {
                          final n = _notifs[index];
                          return InkWell(
                            onTap: () => _marquerLu(n.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 6, right: AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: _prioriteColors[n.priorite] ?? AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(n.titre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text(n.message, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(n.creeLe),
                                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}
