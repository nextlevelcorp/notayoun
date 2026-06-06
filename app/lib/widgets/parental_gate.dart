import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/dimens.dart';

/// Ebeveyn kapısı: satın alma / dış bağlantı gibi yetişkin işlemlerinden önce
/// basit bir çarpma sorusuyla çocuğu eler. Doğru cevapta `true` döner.
Future<bool> showParentalGate(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ParentalGateDialog(),
  );
  return result ?? false;
}

class _ParentalGateDialog extends StatefulWidget {
  const _ParentalGateDialog();

  @override
  State<_ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<_ParentalGateDialog> {
  late final int _a;
  late final int _b;
  final _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _a = 2 + rng.nextInt(7); // 2..8
    _b = 2 + rng.nextInt(7);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    final answer = int.tryParse(_controller.text.trim());
    if (answer == _a * _b) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'Yanlış cevap, tekrar dene.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: const Text('Ebeveyn Kontrolü'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Devam etmek için lütfen şu işlemi çöz:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('$_a × $_b = ?',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Cevap',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _check(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Vazgeç'),
        ),
        ElevatedButton(onPressed: _check, child: const Text('Onayla')),
      ],
    );
  }
}
