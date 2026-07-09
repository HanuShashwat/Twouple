import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/celestial_background.dart';
  final String reason;
  final IconData icon;
  final Color color;

  const InteractiveMetricTile({
    required this.title,
    required this.score,
    required this.reason,
    required this.icon,
    required this.color,
  });

  @override
  State<InteractiveMetricTile> createState() => InteractiveMetricTileState();
}


class InteractiveMetricTileState extends State<InteractiveMetricTile> {
  bool _showReason = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showReason = !_showReason;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _showReason ? widget.color.withValues(alpha: 0.1) : AppColors.elevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.color.withValues(alpha: 0.2)),
        ),
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showReason ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
            return Stack(
               alignment: Alignment.center,
               children: [
                  Positioned(
                    key: bottomChildKey,
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: bottomChild,
                  ),
                  Positioned(
                    key: topChildKey,
                    child: topChild,
                  ),
               ],
            );
          },
          firstChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 16),
                  ),
                  Text(widget.score, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: widget.color)),
                ]
              ),
              Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary, letterSpacing: 0.5)),
            ]
          ),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text('${widget.title} Insights', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.color)),
               const SizedBox(height: 8),
               Text(widget.reason, style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textPrimary)),
            ],
          ),
        )
      )
    );
  }
}

