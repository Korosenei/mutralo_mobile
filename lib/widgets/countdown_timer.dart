import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CountdownTimer extends StatefulWidget {
  final String expireLe; // ISO datetime
  final VoidCallback? onExpire;

  const CountdownTimer({super.key, required this.expireLe, this.onExpire});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    _remaining = _calc();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final r = _calc();
      setState(() => _remaining = r);
      if (r <= 0) {
        _timer.cancel();
        widget.onExpire?.call();
      }
    });
  }

  int _calc() {
    final expire = DateTime.tryParse(widget.expireLe);
    if (expire == null) return 0;
    final diff = expire.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining ~/ 60;
    final seconds = _remaining % 60;
    final isCritical = _remaining <= 30;

    return Text(
      _remaining > 0
          ? 'Expire dans $minutes:${seconds.toString().padLeft(2, '0')}'
          : 'Code expiré',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isCritical ? AppColors.danger : AppColors.textMuted,
      ),
    );
  }
}
