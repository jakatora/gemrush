import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Floating coin animation — pojawia się przy zarobku monet (np. po wygranej,
/// po daily reward, po achievement). Wznosi się i znika.
class CoinPickup extends StatefulWidget {
  const CoinPickup({
    super.key,
    required this.amount,
    required this.position,
    this.onComplete,
  });

  final int amount;
  final Offset position;
  final VoidCallback? onComplete;

  @override
  State<CoinPickup> createState() => _CoinPickupState();
}

class _CoinPickupState extends State<CoinPickup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _move;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
    _scale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.2).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 30,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 70),
    ]).animate(_ctrl);
    _move = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -60),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward().whenComplete(() {
      widget.onComplete?.call();
    });
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
      builder: (context, _) {
        return Positioned(
          left: widget.position.dx + _move.value.dx,
          top: widget.position.dy + _move.value.dy,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.accent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '+${widget.amount}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
