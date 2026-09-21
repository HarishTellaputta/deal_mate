
import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Container(
      width: double.infinity,
      color: AppColors.dark,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 22 : 60,
        vertical: isMobile ? 35 : 45,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _brandSection(),
                    const SizedBox(height: 30),
                    _customersSection(),
                    const SizedBox(height: 28),
                    _businessSection(),
                    const SizedBox(height: 28),
                    _contactSection(),
                  ],
                )
              else
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _brandSection(),
                    ),
                    Expanded(
                      child: _customersSection(),
                    ),
                    Expanded(
                      child: _businessSection(),
                    ),
                    Expanded(
                      child: _contactSection(),
                    ),
                  ],
                ),

              const SizedBox(height: 35),

              const Divider(
                color: Color(0xFF334155),
              ),

              const SizedBox(height: 20),

              if (isMobile)
                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '© 2026 DealMate. All rights reserved.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Better Buying. Better Deals.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              else
                const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© 2026 DealMate. All rights reserved.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Better Buying. Better Deals.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
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

  Widget _brandSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DealMate',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Better Buying. Better Deals.',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _customersSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Submit Requirement',
          style: TextStyle(
            color: Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 9),
        Text(
          'How It Works',
          style: TextStyle(
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _businessSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Businesses',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Partner With Us',
          style: TextStyle(
            color: Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Sales Support',
          style: TextStyle(
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _contactSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Get in touch with DealMate',
          style: TextStyle(
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
