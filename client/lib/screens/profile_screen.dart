import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final explorerName = AppState.explorerName.isEmpty
        ? 'Explorer'
        : AppState.explorerName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    const _CircleIconButton(icon: Icons.arrow_back_rounded),
                    const Spacer(),
                    Text(
                      'Profile',
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                        fontFeatures: const [FontFeature.enable('kern')],
                      ),
                    ),
                    const Spacer(),
                    const _CircleIconButton(icon: Icons.close_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.statCard,
                      border: Border.all(color: AppColors.gold, width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        '\u{1F9D9}',
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Lv${AppState.level}',
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.background,
                          fontFeatures: const [FontFeature.enable('kern')],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                explorerName,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  fontFeatures: const [FontFeature.enable('kern')],
                ),
              ),
              Text(
                AppState.email,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.secondary,
                  fontFeatures: const [FontFeature.enable('kern')],
                ),
              ),
              const _DharmaScorecard(),
              const _LevelProgress(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DharmaScorecard extends StatelessWidget {
  const _DharmaScorecard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                'Dharma Scorecard',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  fontFeatures: const [FontFeature.enable('kern')],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _ScoreCell(
                icon: Icons.local_fire_department_rounded,
                value: '0%',
                label: 'Dharma Score',
              ),
              _ScoreCell(
                icon: Icons.token_rounded,
                value: '0',
                label: 'Tokens',
              ),
              _ScoreCell(
                icon: Icons.location_on_rounded,
                value: '0',
                label: 'Trips',
              ),
              _ScoreCell(
                icon: Icons.star_outline_rounded,
                value: '0',
                label: 'Memories',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreCell extends StatelessWidget {
  const _ScoreCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
              fontFeatures: const [FontFeature.enable('kern')],
            ),
          ),
          Text(
            label,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.secondary,
              fontFeatures: const [FontFeature.enable('kern')],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelProgress extends StatelessWidget {
  const _LevelProgress();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Level Progress',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.text,
                  fontFeatures: const [FontFeature.enable('kern')],
                ),
              ),
              const Spacer(),
              Text(
                '0%',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                  fontFeatures: const [FontFeature.enable('kern')],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 8,
              backgroundColor: AppColors.statCard,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '100 points to Level 2',
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.secondary,
              fontFeatures: const [FontFeature.enable('kern')],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.statCard,
      ),
      child: Icon(icon, color: AppColors.text, size: 20),
    );
  }
}
