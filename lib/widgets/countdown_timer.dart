import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime expireLe;
  final VoidCallback? onExpire;

  const CountdownTimer({super.key, required this.expireLe, this.onExpire});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  late Duration _restant;
  bool _expireAppele = false;

  @override
  void initState() {
    super.initState();
    _restant = widget.expireLe.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final restant = widget.expireLe.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _restant = restant);
    if (restant.isNegative && !_expireAppele) {
      _expireAppele = true;
      widget.onExpire?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_restant.isNegative) {
      return const Text('Code expiré', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700));
    }
    final minutes = _restant.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secondes = _restant.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text('Expire dans $minutes:$secondes', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }
}
