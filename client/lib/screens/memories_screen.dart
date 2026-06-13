import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Memories',
          softWrap: true,
          overflow: TextOverflow.visible,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
            fontFeatures: const [FontFeature.enable('kern')],
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_album_outlined,
              color: AppColors.secondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No Memories Yet',
              softWrap: true,
              overflow: TextOverflow.visible,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
                fontFeatures: const [FontFeature.enable('kern')],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a trip to\ncreate memories',
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.secondary,
                fontFeatures: const [FontFeature.enable('kern')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
