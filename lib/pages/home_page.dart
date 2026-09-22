import 'package:flutter/material.dart';

import '../api/business_api_service.dart';
import '../api/category_api_service.dart';
import '../models/business_model.dart';
import '../models/category_model.dart';
import '../widgets/footer.dart';
import '../widgets/navbar.dart';
import '../widgets/home/home_hero.dart';
import '../widgets/home/home_categories.dart';
import '../widgets/home/home_businesses.dart';
import '../widgets/home/home_how_it_works.dart';
import '../widgets/home/home_customer_business.dart';
import '../widgets/home/home_bottom_cta.dart';
import '../widgets/hs_promo_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> categories = [];
  List<BusinessModel> businesses = [];

  bool isLoadingCategories = true;
  bool isLoadingBusinesses = true;

  @override
  void initState() {
    super.initState();

    _loadCategories();
    _loadBusinesses();
  }

  Future<void> _loadCategories() async {
    try {
      final result =
          await CategoryApiService.getCategories();

      if (!mounted) return;

      setState(() {
        categories = result;
        isLoadingCategories = false;
      });
    } catch (e) {
      debugPrint('CATEGORY API ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadBusinesses() async {
    try {
      final result =
          await BusinessApiService.getBusinesses();

      if (!mounted) return;

      setState(() {
        businesses = result;
        isLoadingBusinesses = false;
      });
    } catch (e) {
      debugPrint('BUSINESS API ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoadingBusinesses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width;

    final isMobile = width < 700;
    final isTablet =
        width >= 700 && width < 1100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Navbar(isMobile: isMobile),
              const HsPromoBanner(),
            HomeHero(
              isMobile: isMobile,
            ),

            HomeCategories(
              categories: categories,
              isLoading: isLoadingCategories,
              isMobile: isMobile,
              isTablet: isTablet,
            ),

            HomeBusinesses(
              businesses: businesses,
              isLoading: isLoadingBusinesses,
              isMobile: isMobile,
              isTablet: isTablet,
            ),

            HomeHowItWorks(
              isMobile: isMobile,
            ),

            HomeCustomerBusiness(
              isMobile: isMobile,
            ),

            HomeBottomCta(
              isMobile: isMobile,
            ),

            const Footer(),
          ],
        ),
      ),
    );
  }
}