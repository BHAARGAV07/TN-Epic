import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/quest_node.dart';
import '../models/vector3.dart';

/// Premium AR HUD overlay for heritage corridor exploration
/// CRITICAL: Uses proper layer hierarchy to ensure golden path is ALWAYS visible
class ARPremiumHUD extends StatefulWidget {
  final bool isFloorDetected;
  final bool isSimulatingWalk;
  final double scanProgress;
  final Vector3 userPosition;
  final List<Vector3> roadWaypoints;
  final int collectedCoins;
  final int dharmaScore;
  final int checkpointsCollected;
  final VoidCallback onStartSimulation;

  const ARPremiumHUD({
    Key? key,
    required this.isFloorDetected,
    required this.isSimulatingWalk,
    required this.scanProgress,
    required this.userPosition,
    required this.roadWaypoints,
    required this.collectedCoins,
    required this.dharmaScore,
    required this.checkpointsCollected,
    required this.onStartSimulation,
  }) : super(key: key);

  @override
  State<ARPremiumHUD> createState() => _ARPremiumHUDState();
}

class _ARPremiumHUDState extends State<ARPremiumHUD>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Auto-trigger slide animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // LAYER 4A: Top Status Bar with VIO & Telemetry
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopStatusBar(context),
        ),

        // LAYER 4B: Left Side Discovery Card (Glassmorphism)
        if (widget.isFloorDetected && !widget.isSimulatingWalk)
          Positioned(
            left: 12,
            top: 120,
            width: 160,
            child: _buildDiscoveryCard(),
          ),

        // LAYER 4C: Right Side Navigation Telemetry
        if (widget.isFloorDetected)
          Positioned(
            right: 12,
            top: 120,
            width: 165,
            child: _buildNavigationTelemetry(),
          ),

        // LAYER 4D: Center Simulation Controls (only when floor detected)
        if (widget.isFloorDetected && !widget.isSimulatingWalk)
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: _buildSimulationControlCenter(),
          ),

        // LAYER 4E: Active Simulation HUD (appears during walk)
        if (widget.isSimulatingWalk)
          Positioned(
            bottom: 28,
            left: 16,
            right: 16,
            child: _buildActiveSimulationHUD(),
          ),

        // LAYER 4F: Checkpoint Achievement Notification (non-blocking)
        if (widget.isSimulatingWalk && widget.checkpointsCollected > 0)
          Positioned(
            top: 140,
            left: 12,
            right: 12,
            child: _buildCheckpointNotification(),
          ),

        // LAYER 4G: Calibration indicator (non-blocking, bottom right)
        if (!widget.isFloorDetected)
          Positioned(
            bottom: 28,
            right: 12,
            child: _buildCalibrationIndicator(),
          ),
      ],
    );
  }

  Widget _buildTopStatusBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withOpacity(0.85),
            AppColors.background.withOpacity(0.35),
            Colors.transparent,
          ],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: Status + Scores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              _buildStatusBadge(),

              // Score Display
              _buildScoreDisplay(),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom row: Telemetry (if detecting)
          if (widget.isFloorDetected)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTelemetryChip('VION', 'Active'),
                _buildTelemetryChip('AR', '60 FPS'),
                _buildTelemetryChip('GPS', 'Indoor'),
                _buildTelemetryChip('PATH', 'Clear'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isFloorDetected ? Colors.cyanAccent : AppColors.gold,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isFloorDetected ? Colors.cyanAccent : AppColors.gold)
                .withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isFloorDetected
                ? Icons.check_circle_rounded
                : Icons.sync_rounded,
            color: widget.isFloorDetected ? Colors.cyanAccent : AppColors.gold,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            widget.isFloorDetected
                ? 'HERITAGE CORRIDOR LOCKED'
                : 'CALIBRATING...',
            style: GoogleFonts.inter(
              color: widget.isFloorDetected
                  ? Colors.cyanAccent
                  : AppColors.gold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navBorder, width: 1.0),
        boxShadow: [
          BoxShadow(color: AppColors.gold.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 14),
          const SizedBox(width: 4),
          Text(
            '${widget.collectedCoins}',
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.offline_bolt_rounded, color: Colors.cyanAccent, size: 14),
          const SizedBox(width: 4),
          Text(
            '${widget.dharmaScore}',
            style: GoogleFonts.jetBrainsMono(
              color: Colors.cyanAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.cyanAccent.withOpacity(0.6),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: Colors.cyanAccent,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -200, end: 0),
      duration: const Duration(milliseconds: 700),
      builder: (context, offset, child) {
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.cyan.withOpacity(0.12),
              Colors.cyan.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.08),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HERITAGE',
              style: GoogleFonts.inter(
                color: Colors.cyanAccent,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Chola Dynasty Corridor',
              style: GoogleFonts.inter(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Walk the golden path through ancient temples',
              style: GoogleFonts.inter(
                color: AppColors.text.withOpacity(0.7),
                fontSize: 9,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTelemetry() {
    final endPoint = widget.roadWaypoints.isNotEmpty
        ? widget.roadWaypoints.last
        : null;
    final distToEnd = endPoint != null
        ? widget.userPosition.distanceTo(endPoint)
        : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 200, end: 0),
      duration: const Duration(milliseconds: 700),
      builder: (context, offset, child) {
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.gold.withOpacity(0.08),
              AppColors.gold.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.08),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NAVIGATION',
              style: GoogleFonts.inter(
                color: AppColors.gold,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.flag_rounded, color: AppColors.gold, size: 12),
                const SizedBox(width: 4),
                Text(
                  '${distToEnd.toStringAsFixed(1)}m',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.security, color: Colors.cyanAccent, size: 12),
                const SizedBox(width: 4),
                Text(
                  '${widget.checkpointsCollected}/2 Found',
                  style: GoogleFonts.inter(
                    color: Colors.cyanAccent,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationControlCenter() {
    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        ),
        child: GestureDetector(
          onTap: widget.onStartSimulation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gold.withOpacity(0.25),
                  AppColors.gold.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.5),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.25),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Icon(
                    Icons.directions_walk_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'START SACRED WALK',
                  style: GoogleFonts.inter(
                    color: AppColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSimulationHUD() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background.withOpacity(0.8),
            AppColors.background.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Walking indicator
          Row(
            children: [
              Icon(
                Icons.directions_walk_rounded,
                color: AppColors.gold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'WALKING SACRED PATH',
                style: GoogleFonts.inter(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),

          // Right: Speed indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(0.4),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.speed_rounded, color: Colors.cyanAccent, size: 14),
                const SizedBox(width: 4),
                Text(
                  '1.2 m/s',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.cyanAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckpointNotification() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
          ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.cyanAccent.withOpacity(0.15),
              Colors.cyan.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.15),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _glowController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Icon(
                Icons.security_rounded,
                color: Colors.cyanAccent,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHECKPOINT DISCOVERED',
                  style: GoogleFonts.inter(
                    color: Colors.cyanAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'Maratha Durbar Heritage Site',
                  style: GoogleFonts.inter(
                    color: AppColors.text,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 12),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: CircularProgressIndicator(
                    value: widget.scanProgress,
                    color: Colors.cyanAccent,
                    backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                    strokeWidth: 2.5,
                  ),
                ),
                Icon(
                  Icons.center_focus_strong_rounded,
                  color: Colors.cyanAccent,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(widget.scanProgress * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.jetBrainsMono(
              color: Colors.cyanAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
