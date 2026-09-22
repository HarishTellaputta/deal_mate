import 'package:flutter/material.dart';
import 'package:deal_mate/pages/search_page.dart';

class HomeHero extends StatelessWidget {
  final bool isMobile;

  const HomeHero({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 48 : 72,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5FAFF),
            Color(0xFFF8FAFC),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Column(
            children: [
              // TOP BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFDBEAFE),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Discover khammam Local Businesses',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // MAIN HEADING
              Text(
                'మన ఖమ్మం చౌరస్తా.\nDiscover Products.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 34 : 52,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  height: 1.08,
                  letterSpacing: -1.2,
                ),
              ),

              const SizedBox(height: 12),

              // HIGHLIGHTED LINE
              Text(
                'Connect Directly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 27 : 42,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2563EB),
                  height: 1.1,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 18),

              // DESCRIPTION
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 680,
                ),
                child: Text(
                  'Explore local businesses, products and services, compare your options and connect directly with the right business.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    color: const Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // SEARCH BAR
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 700,
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.08),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: isMobile ? 58 : 64,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),

                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF64748B),
                            size: 24,
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Text(
                              'Search businesses, products or services...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),

                          Container(
                            width: isMobile ? 44 : 48,
                            height: isMobile ? 44 : 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 21,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // TRUST POINTS
              Wrap(
                alignment: WrapAlignment.center,
                spacing: isMobile ? 14 : 28,
                runSpacing: 12,
                children: const [
                  _HeroTrustItem(
                    icon: Icons.search_rounded,
                    text: 'Easy Discovery',
                  ),
                  _HeroTrustItem(
                    icon: Icons.storefront_outlined,
                    text: 'Local Businesses',
                  ),
                  _HeroTrustItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    text: 'Direct Connection',
                  ),
                  _HeroTrustItem(
                    icon: Icons.currency_rupee_rounded,
                    text: 'No Customer Fee',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroTrustItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroTrustItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 15,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}