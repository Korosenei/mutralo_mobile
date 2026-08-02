import 'package:flutter/material.dart';
import '../../api/transactions_api.dart';
import '../../models/transaction.dart';
import '../../theme/colors.dart';
import '../../widgets/transaction_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final data = await TransactionsApi.getMesTransactions();
      if (mounted) setState(() => _transactions = data);
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
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Text('Historique des transactions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : RefreshIndicator(
                      onRefresh: _charger,
                      child: _transactions.isEmpty
                          ? ListView(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(top: AppSpacing.xl),
                                  child: Center(
                                    child: Text(
                                        "Aucune transaction dans l'historique.",
                                        style: TextStyle(
                                            color: AppColors.textMuted)),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                110,
                              ),
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) => TransactionCard(
                                  transaction: _transactions[index]),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
