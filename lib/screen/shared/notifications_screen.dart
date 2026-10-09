import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification.dart';
import '../../providers/notification_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/state_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<NotificationProvider>().charger());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop())
            : null,
        title: const Text('Notifications'),
        actions: [
          if (provider.notifications.isNotEmpty)
            TextButton(
              onPressed: () =>
                  context.read<NotificationProvider>().toutMarquerLu(),
              child: const Text('Tout marquer lu'),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<NotificationProvider>().charger(),
          child: provider.notifications.isEmpty
              ? const VideWidget(
                  icone: Icons.notifications_none_outlined,
                  message: "Vous n'avez aucune notification pour le moment.",
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: provider.notifications.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final notif = provider.notifications[index];
                    return Dismissible(
                      key: ValueKey(notif.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => context
                          .read<NotificationProvider>()
                          .supprimer(notif.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: const Icon(Icons.delete_outline,
                            color: AppColors.danger),
                      ),
                      child: _CarteNotification(
                        notification: notif,
                        onTap: () => context
                            .read<NotificationProvider>()
                            .marquerCommeLue(notif.id),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _CarteNotification extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _CarteNotification({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.lue ? AppColors.surface : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
              color: notification.priorite == PrioriteNotification.urgente
                  ? AppColors.danger
                  : AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icone(notification.type), color: AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.titre,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(notification.message,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(_formatDate(notification.date),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.disabled)),
                ],
              ),
            ),
            if (!notification.lue)
              Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                      color: AppColors.danger, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  IconData _icone(TypeNotification type) {
    switch (type) {
      case TypeNotification.compte:
        return Icons.person_outline;
      case TypeNotification.achat:
        return Icons.shopping_cart_outlined;
      case TypeNotification.consommation:
        return Icons.restaurant_outlined;
      case TypeNotification.programmation:
        return Icons.calendar_month_outlined;
      case TypeNotification.menu:
        return Icons.restaurant_menu_outlined;
      case TypeNotification.reservation:
        return Icons.event_note_outlined;
      case TypeNotification.caisse:
        return Icons.point_of_sale_outlined;
      case TypeNotification.rappel:
        return Icons.alarm_outlined;
      case TypeNotification.systeme:
        return Icons.info_outline;
    }
  }

  String _formatDate(DateTime d) {
    final maintenant = DateTime.now();
    final diff = maintenant.difference(d);
    if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Il y a ${diff.inHours} h";
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }
}
