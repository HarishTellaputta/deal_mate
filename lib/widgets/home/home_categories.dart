import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../pages/search_page.dart';

class HomeCategories extends StatelessWidget {
  final List<CategoryModel> categories;
  final bool isLoading;
  final bool isMobile;
  final bool isTablet;

  const HomeCategories({
    super.key,
    required this.categories,
    required this.isLoading,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
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
                  'EXPLORE',
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
                'Explore Categories',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 10),

              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: const Text(
                  'Discover businesses, products and services across different categories.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 34),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: Color(0xFF2563EB),
                  ),
                )
              else if (categories.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  child: const Text(
                    'No categories available',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double spacing = isMobile ? 12 : 18;

                    final int columns = isMobile
                        ? 2
                        : isTablet
                            ? 3
                            : 4;

                    final double itemWidth =
                        (constraints.maxWidth -
                                (spacing * (columns - 1))) /
                            columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: categories.map((category) {
                        return SizedBox(
                          width: itemWidth,
                          child: _CategoryCard(
                            category: category,
                            isMobile: isMobile,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isMobile;

  const _CategoryCard({
    required this.category,
    required this.isMobile,
  });

  String _getImage(String name) {
    final value = name.toLowerCase();

    if (value.contains('real estate')) {
      return 'assets/images/categories/real_estate.webp';
    }

    if (value.contains('home') || value.contains('electronics')) {
      return 'assets/images/categories/home_electronics.webp';
    }

    if (value.contains('vehicle')) {
      return 'assets/images/categories/vehicles.webp';
    }

    if (value.contains('tile') || value.contains('material')) {
      return 'assets/images/categories/tiles_home.webp';
    }

    if (value.contains('solar')) {
      return 'assets/images/categories/solar.webp';
    }

    if (value.contains('digital') || value.contains('technology')) {
      return 'assets/images/categories/digital_technology.webp';
    }

    return 'assets/images/categories/other_services.webp';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchPage(
                categoryId: category.id,
                categoryName: category.name,
              ),
            ),
          );
        },
        child: Container(
          height: isMobile ? 185 : 205,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Category image
              Positioned.fill(
                child: Image.asset(
                  _getImage(category.name),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(
                          Icons.category_outlined,
                          size: 42,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom gradient
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: isMobile ? 82 : 92,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.78),
                      ],
                    ),
                  ),
                ),
              ),

              // Category name
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
              ),

              // Arrow
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}