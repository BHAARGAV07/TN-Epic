import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/quest_node.dart';

/// Premium reward notification with glitch effects and particle bursts
/// CRITICAL: Non-blocking - never covers the golden path (uses IgnorePointer)
class RewardNotification extends StatefulWidget {
  final QuestNode node;
  final VoidCallback onDismiss;
  final Duration displayDuration;

  const RewardNotification({
    Key? key,
    required this.node,
    required this.onDismiss,
    this.displayDuration = const Duration(milliseconds: 2800),
  }) : super(key: key);

  @override
  State<RewardNotification> createState() => _RewardNotificationState();
}

class _RewardNotificationState extends State<RewardNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.12, curve: Curves.elasticOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_slideAnimation.value, 0),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
          );
        },
        child: _buildRewardCard(),
      ),
    );
  }

  Widget _buildRewardCard() {
    final isPositive =
        widget.node.type == 'coin' || widget.node.type == 'beacon';
    final glowColor = isPositive ? AppColors.gold : Colors.cyanAccent;
    final bgGradient = isPositive
        ? [AppColors.gold.withOpacity(0.15), AppColors.gold.withOpacity(0.03)]
        : [Colors.cyan.withOpacity(0.15), Colors.cyan.withOpacity(0.03)];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgGradient,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: glowColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with glow
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glowColor.withOpacity(0.3),
                  glowColor.withOpacity(0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(_getRewardIcon(), color: glowColor, size: 22),
            ),
          ),

          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getRewardTitle(),
                  style: GoogleFonts.inter(
                    color: glowColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.node.name,
                  style: GoogleFonts.inter(
                    color: AppColors.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Value chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: glowColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: glowColor.withOpacity(0.3), width: 0.8),
            ),
            child: Text(
              '+${widget.node.value}',
              style: GoogleFonts.jetBrainsMono(
                color: glowColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRewardIcon() {
    switch (widget.node.type) {
      case 'coin':
        return Icons.monetization_on_rounded;
      case 'beacon':
        return Icons.flag_rounded;
      case 'save_point':
        return Icons.security_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  String _getRewardTitle() {
    switch (widget.node.type) {
      case 'coin':
        return 'COIN COLLECTED';
      case 'beacon':
        return 'BEACON REACHED';
      case 'save_point':
        return 'CHECKPOINT';
      default:
        return 'COLLECTED';
    }
  }
}

/// Manages multiple reward notifications in a stack
class RewardNotificationManager extends StatefulWidget {
  final List<QuestNode> collectedNodes;

  const RewardNotificationManager({Key? key, required this.collectedNodes})
    : super(key: key);

  @override
  State<RewardNotificationManager> createState() =>
      _RewardNotificationManagerState();
}

class _RewardNotificationManagerState extends State<RewardNotificationManager> {
  final List<QuestNode> _activeNotifications = [];

  @override
  void didUpdateWidget(RewardNotificationManager oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Find newly collected nodes
    for (final node in widget.collectedNodes) {
      if (!_activeNotifications.contains(node) && node.isCollected) {
        setState(() {
          _activeNotifications.add(node);
        });
      }
    }
  }

  void _removeNotification(QuestNode node) {
    setState(() {
      _activeNotifications.remove(node);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = 0; i < _activeNotifications.length; i++)
          Positioned(
            top: 100 + (i * 76),
            left: 0,
            right: 0,
            child: RewardNotification(
              node: _activeNotifications[i],
              onDismiss: () => _removeNotification(_activeNotifications[i]),
            ),
          ),
      ],
    );
  }
}
