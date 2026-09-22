import 'package:flutter/material.dart';

class HomeHowItWorks extends StatelessWidget {
  final bool isMobile;

  const HomeHowItWorks({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 52 : 72,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Column(
            children: [
              // Section label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FF),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFE0E7FF),
                  ),
                ),
                child: const Text(
                  'SIMPLE PROCESS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'How DealMate Works',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Find what you need and connect with the right business in three simple steps.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 36),

              if (isMobile)
                const Column(
                  children: [
                    _HowItWorksStep(
                      number: '01',
                      icon: Icons.search_rounded,
                      title: 'Search',
                      description:
                          'Search for a business, product or service you need.',
                    ),
                    SizedBox(height: 16),
                    _HowItWorksStep(
                      number: '02',
                      icon: Icons.storefront_outlined,
                      title: 'Explore',
                      description:
                          'View business details, products, offers and reviews.',
                    ),
                    SizedBox(height: 16),
                    _HowItWorksStep(
                      number: '03',
                      icon: Icons.phone_in_talk_outlined,
                      title: 'Connect',
                      description:
                          'Contact the business directly or send an enquiry.',
                    ),
                  ],
                )
              else
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _HowItWorksStep(
                        number: '01',
                        icon: Icons.search_rounded,
                        title: 'Search',
                        description:
                            'Search for a business, product or service you need.',
                      ),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: _HowItWorksStep(
                        number: '02',
                        icon: Icons.storefront_outlined,
                        title: 'Explore',
                        description:
                            'View business details, products, offers and reviews.',
                      ),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: _HowItWorksStep(
                        number: '03',
                        icon: Icons.phone_in_talk_outlined,
                        title: 'Connect',
                        description:
                            'Contact the business directly or send an enquiry.',
                      ),
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

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _HowItWorksStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                  size: 25,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}