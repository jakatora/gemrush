import 'package:flutter/material.dart';

/// Animowany licznik liczbowy — przy zmianie wartości "przewija się" do nowej.
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 600),
    this.style,
  });

  final int value;
  final Duration duration;
  final TextStyle? style;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late int _from;
  late int _to;
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _from = widget.value;
    _to = widget.value;
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _to) {
      _from = _to;
      _to = widget.value;
      _ctrl
        ..reset()
        ..forward();
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
      animation: _ctrl,
      builder: (_, _) {
        final t = Curves.easeOutCubic.transform(_ctrl.value);
        final current = (_from + (_to - _from) * t).round();
        return Text('$current', style: widget.style);
      },
    );
  }
}
