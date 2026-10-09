import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket.dart';
import '../../providers/ticket_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/state_widgets.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<TicketProvider>().charger());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TicketProvider>();

    return Scaffold(
      appBar: const AppHeader(titre: Text('Mes tickets')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => context.read<TicketProvider>().charger(),
          child: provider.chargement && provider.disponibles.isEmpty
              ? const ChargementWidget()
              : provider.disponibles.isEmpty
                  ? const VideWidget(icone: Icons.confirmation_number_outlined, message: "Vous n'avez aucun ticket disponible.")
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 110),
                      itemCount: provider.disponibles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) => _CarteTicket(ticket: provider.disponibles[index]),
                    ),
        ),
      ),
    );
  }
}

class _CarteTicket extends StatelessWidget {
  final Ticket ticket;
  const _CarteTicket({required this.ticket});

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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppRadius.sm)),
            alignment: Alignment.center,
            child: const Icon(Icons.confirmation_number, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.numeroTicket, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('${ticket.prixPaye} FCFA', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: const Text('Disponible', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
