import 'package:flutter/material.dart';

class LiveHeader extends StatelessWidget {
  const LiveHeader({
    required this.sessionTitle,
    required this.formattedElapsed,
    required this.isPaused,
    super.key,
  });

  final String sessionTitle;
  final String formattedElapsed;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          _LiveBadge(isPaused: isPaused),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              sessionTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000F12),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 15,
                color: const Color(0x99000F12),
              ),
              const SizedBox(width: 4),
              Text(
                formattedElapsed,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF000F12),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.isPaused});

  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final isLive = !isPaused;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLive
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isLive
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFCA8A04),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isLive ? 'Live' : 'Paused',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLive
                  ? const Color(0xFF15803D)
                  : const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}
