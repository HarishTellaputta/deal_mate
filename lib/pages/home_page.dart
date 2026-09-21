import 'package:flutter/material.dart';

import '../widgets/footer.dart';
import 'requirement_page.dart';

import '../core/app_colors.dart';
import '../widgets/navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoint
    final isMobile = screenWidth < 700;

    debugPrint('SCREEN WIDTH: $screenWidth');
    debugPrint('IS MOBILE: $isMobile');

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Navbar(isMobile: isMobile),
            _heroSection(context, isMobile),
            _howItWorks(isMobile),
            _customerBusinessSection(isMobile),
            _bottomCta(context, isMobile),
            const Footer(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO SECTION
  // ============================================================

  Widget _heroSection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 18 : 60,
              vertical: isMobile ? 35 : 75,
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _heroContent(context, true),
                      const SizedBox(height: 40),
                      _heroVisual(true),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _heroContent(context, false),
                      ),
                      const SizedBox(width: 60),
                      Expanded(
                        flex: 4,
                        child: _heroVisual(false),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _heroContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'SHOP LOCAL • SAVE SMART',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),

        const SizedBox(height: 22),

        // Main Heading
        Text(
          'ManaKhammam',
          style: TextStyle(
            fontSize: isMobile ? 38 : 52,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'DealMate',
          style: TextStyle(
            fontSize: isMobile ? 38 : 52,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Find the Best Price',
          style: TextStyle(
            fontSize: isMobile ? 20 : 25,
            fontWeight: FontWeight.w600,
           color: Colors.black87,
          ),
        ),

        const SizedBox(height: 18),

        // Description
        Text(
          'Find local shops, compare available options, '
          'and discover better prices and offers in Khammam.',
          style: TextStyle(
            fontSize: isMobile ? 15 : 17,
            height: 1.6,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 28),

        // Requirement Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAF9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              _heroTextField(
                label: 'What are you looking to buy?',
                icon: Icons.shopping_bag_outlined,
              ),
              const SizedBox(height: 12),
              _heroTextField(
                label: 'Approx. Budget',
                icon: Icons.currency_rupee,
              ),
              const SizedBox(height: 12),
              _heroTextField(
                label: 'Your Location',
                icon: Icons.location_on_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // CTA Button
        SizedBox(
          width: isMobile ? double.infinity : 240,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RequirementPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Find the Best Price',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Trust Text
        Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 7),
            Text(
              'No customer service fee',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // HERO VISUAL
  // ============================================================

  Widget _heroVisual(bool isMobile) {
    return Container(
      height: isMobile ? 330 : 470,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Circle
          Container(
            width: isMobile ? 170 : 220,
            height: isMobile ? 170 : 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.10),
            ),
            child: Icon(
              Icons.handshake_outlined,
              size: isMobile ? 80 : 105,
              color: AppColors.primary,
            ),
          ),

          // Better Rates
          Positioned(
            top: isMobile ? 35 : 65,
            left: isMobile ? 15 : 25,
            child: _floatingCard(
              icon: Icons.currency_rupee,
              title: 'Better Rates',
            ),
          ),

          // More Choices
          Positioned(
            bottom: isMobile ? 35 : 65,
            right: isMobile ? 15 : 25,
            child: _floatingCard(
              icon: Icons.storefront_outlined,
              title: 'More Choices',
            ),
          ),

          // Available Offers
          Positioned(
            bottom: isMobile ? 75 : 110,
            left: isMobile ? 10 : 20,
            child: _floatingCard(
              icon: Icons.local_offer_outlined,
              title: 'Available Offers',
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOW IT WORKS
  // ============================================================

  Widget _howItWorks(bool isMobile) {
    final steps = [
      {
        'number': '01',
        'title': 'Tell Us',
        'description':
            'Tell us what you want to buy, your budget and location.',
        'icon': Icons.edit_note_outlined,
      },
      {
        'number': '02',
        'title': 'We Find Options',
        'description':
            'We explore suitable local shops, showrooms and available offers.',
        'icon': Icons.search_outlined,
      },
      {
        'number': '03',
        'title': 'You Choose',
        'description':
            'Compare the available options and choose what works for you.',
        'icon': Icons.check_circle_outline,
      },
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAF9),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 18 : 60,
              vertical: isMobile ? 55 : 80,
            ),
            child: Column(
              children: [
                Text(
                  'How ManaKhammam DealMate Works',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 27 : 36,
                    fontWeight: FontWeight.w800,
                   color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Find local shops, explore options and choose the deal that works for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                   color: Colors.black87,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                isMobile
                    ? Column(
                        children: steps
                            .map(
                              (step) => Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: _stepCard(step),
                              ),
                            )
                            .toList(),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: steps
                            .map(
                              (step) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: _stepCard(step),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                const SizedBox(height: 30),

                // No fee badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 17,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'No customer service fee',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepCard(Map<String, dynamic> step) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  step['icon'] as IconData,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              Text(
                step['number'] as String,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary.withOpacity(0.18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            step['title'] as String,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
             color: Colors.black87,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            step['description'] as String,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
            color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CUSTOMER / BUSINESS SECTION
  // ============================================================

  Widget _customerBusinessSection(bool isMobile) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 18 : 60,
              vertical: isMobile ? 55 : 80,
            ),
            child: Column(
              children: [
                Text(
                  'Built for Customers & Businesses',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 27 : 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'A simple platform connecting customer requirements with local businesses.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                isMobile
                    ? Column(
                        children: [
                          _customerCard(),
                          const SizedBox(height: 20),
                          _businessCard(),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _customerCard(),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _businessCard(),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customerCard() {
    return _infoCard(
      icon: Icons.person_outline,
      title: 'For Customers',
      description:
          'Looking for a product in Khammam? Explore local shops and available options.',
      items: [
        'Product & buying suggestions',
        'Explore available rates',
        'Available offers & rate differences',
        'No customer service fee',
      ],
    );
  }

  Widget _businessCard() {
    return _infoCard(
      icon: Icons.storefront_outlined,
      title: 'For Businesses',
      description:
          'Get connected with customers who are actively looking to buy.',
      items: [
        'Potential customer enquiries',
        'Multiple customer requirements',
        'Sales support',
        'Commission-based partnership',
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 27,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
             color: Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM CTA
  // ============================================================

  Widget _bottomCta(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 18 : 60,
              vertical: isMobile ? 55 : 70,
            ),
            child: Column(
              children: [
                Text(
                  'Looking for the Best Price?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'Tell us what you are looking for. '
                  'We will help you explore local shops and available offers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RequirementPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit Requirement',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO TEXT FIELD
  // ============================================================

  Widget _heroTextField({
    required String label,
    required IconData icon,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}