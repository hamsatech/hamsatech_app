import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthNumpad extends StatelessWidget {
  const AuthNumpad({
    super.key,
    required this.onDigit,
    required this.onDelete,
  });

  final void Function(String digit) onDigit;
  final VoidCallback onDelete;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5FDFF),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            ..._rows.map((row) => Row(
                  children: row
                      .map((d) => _NumKey(
                          digit: d,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onDigit(d);
                          }))
                      .toList(),
                )),
            Row(
              children: [
                const Expanded(child: SizedBox()),
                _NumKey(
                  digit: '0',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onDigit('0');
                  },
                ),
                Expanded(
                  child: _DeleteKey(onTap: () {
                    HapticFeedback.selectionClick();
                    onDelete();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({required this.digit, required this.onTap});

  final String digit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: const Color(0xFF2F7E8F).withValues(alpha: 0.12),
            highlightColor: const Color(0xFF2F7E8F).withValues(alpha: 0.06),
            child: SizedBox(
              height: 64,
              child: Center(
                child: Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000F12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteKey extends StatelessWidget {
  const _DeleteKey({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 64,
            child: Center(
              child: Icon(
                Icons.backspace_outlined,
                size: 24,
                color: const Color(0xFF000F12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
