import 'package:flutter/material.dart';
import '../../api/tickets_api.dart';
import '../../models/ticket.dart';
import '../../theme/colors.dart';
import '../../widgets/ticket_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Ticket> _tickets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final data = await TicketsApi.getTousMesTickets();
      if (mounted) setState(() => _tickets = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Text('Historique des tickets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _charger,
                child: _tickets.isEmpty && !_loading
                    ? ListView(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: AppSpacing.xl),
                            child: Center(
                              child: Text("Aucun ticket dans l'historique.", style: TextStyle(color: AppColors.textMuted)),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        itemCount: _tickets.length,
                        itemBuilder: (context, index) => TicketCard(ticket: _tickets[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
