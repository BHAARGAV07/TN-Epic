import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class ArFilterScreen extends StatefulWidget {
  const ArFilterScreen({super.key});

  @override
  State<ArFilterScreen> createState() => _ArFilterScreenState();
}

class _ArFilterScreenState extends State<ArFilterScreen> {
  int _selectedFilter = 0;

  static const List<({String icon, String label, bool locked})> _filters = [
    (icon: '\u{1F3DB}\uFE0F', label: 'Temple Glow', locked: false),
    (icon: '\u{1F4DC}', label: 'Scroll', locked: true),
    (icon: '\u{1F305}', label: 'Sunset', locked: true),
    (icon: '\u{1F5FF}', label: 'Ancient', locked: true),
    (icon: '\u{1F451}', label: 'Crown', locked: true),
    (icon: '\u{1F48E}', label: 'Relic', locked: true),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: _CircleIconButton(icon: Icons.arrow_back_rounded),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: _CircleIconButton(icon: Icons.close_rounded),
          ),
        ],
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Container(
              width: screenWidth * 0.82,
              height: screenWidth * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A2E),
                border: Border.all(color: AppColors.gold, width: 2.5),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.secondary,
                size: 48,
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            child: Text(
              _filters[_selectedFilter].label,
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.text,
                fontFeatures: const [FontFeature.enable('kern')],
              ),
            ),
          ),
          Positioned(
            bottom: 88,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = index;
                      });
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.gold : AppColors.statCard,
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.fieldBorder),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              filter.icon,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          if (filter.locked)
                            const Positioned(
                              right: 2,
                              bottom: 2,
                              child: Icon(
                                Icons.lock_rounded,
                                color: AppColors.secondary,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.background,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.statCard,
                  ),
                  child: const Icon(
                    Icons.flip_camera_ios_rounded,
                    color: AppColors.text,
                    size: 22,
                  ),
                ),
              ],
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
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.statCard,
        ),
        child: Icon(icon, color: AppColors.text, size: 20),
      ),
    );
  }
}
