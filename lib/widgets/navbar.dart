import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../pages/requirement_page.dart';
import '../pages/business_login_page.dart';

class Navbar extends StatelessWidget {
  final bool isMobile;

  const Navbar({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 70 : 82,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // LOGO
          GestureDetector(
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Row(
              children: [
                Container(
                  width: isMobile ? 36 : 42,
                  height: isMobile ? 36 : 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(isMobile ? 9 : 11),
                  ),
                  child: Icon(
                    Icons.handshake_rounded,
                    color: Colors.white,
                    size: isMobile ? 20 : 23,
                  ),
                ),

                SizedBox(width: isMobile ? 8 : 12),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Deal',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Mate',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    if (!isMobile)
                      const Text(
                        'Better Buying. Better Deals.',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.muted,
                          letterSpacing: 0.2,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // DESKTOP NAVIGATION
          if (!isMobile) ...[
            TextButton(
              onPressed: () {},
              child: const Text(
                'How It Works',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(width: 10),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BusinessLoginPage()),
                );
              },
              child: const Text(
                'For Businesses',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(width: 25),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RequirementPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'Submit Requirement',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],

          // MOBILE MENU
          if (isMobile)
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded, color: AppColors.dark),
              onSelected: (value) {
                if (value == 'requirement') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RequirementPage()),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'how', child: Text('How It Works')),
                PopupMenuItem(value: 'business', child: Text('For Businesses')),
                PopupMenuItem(
                  value: 'requirement',
                  child: Text('Submit Requirement'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
