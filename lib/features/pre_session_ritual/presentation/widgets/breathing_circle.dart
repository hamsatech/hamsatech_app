import 'package:flutter/material.dart';
import '../../bloc/ritual_state.dart';

class BreathingCircle extends StatefulWidget {
  const BreathingCircle({
    required this.phase,
    required this.phaseSeconds,
    super.key,
  });

  final BreathingPhase phase;
  final int phaseSeconds;

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  static const _outerColor = Color(0xFFBFDBFE); // blue-200
  static const _midColor = Color(0xFF93C5FD); // blue-300
  static const _innerColor = Color(0xFF2F7E8F); // blue-600

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.phaseSeconds),
    );
    _scale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _applyPhase(widget.phase);
  }

  @override
  void didUpdateWidget(BreathingCircle old) {
    super.didUpdateWidget(old);
    if (old.phase != widget.phase) {
      _ctrl.duration = Duration(seconds: widget.phaseSeconds);
      _applyPhase(widget.phase);
    }
  }

  void _applyPhase(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.breatheIn:
        _ctrl.forward(from: _ctrl.value);
        break;
      case BreathingPhase.hold:
        _ctrl.stop();
        break;
      case BreathingPhase.breatheOut:
        _ctrl.reverse(from: _ctrl.value);
        break;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) {
        final s = _scale.value;
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Transform.scale(
                scale: s,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: const BoxDecoration(
                    color: _outerColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Middle ring
              Transform.scale(
                scale: s,
                child: Container(
                  width: 212,
                  height: 212,
                  decoration: const BoxDecoration(
                    color: _midColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Inner solid circle with text
              Transform.scale(
                scale: s,
                child: Container(
                  width: 148,
                  height: 148,
                  decoration: const BoxDecoration(
                    color: _innerColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.phase.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
