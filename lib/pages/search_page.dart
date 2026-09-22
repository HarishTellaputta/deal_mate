import 'package:flutter/material.dart';

import '../api/business_api_service.dart';
import '../api/product_api_service.dart';
import '../models/business_model.dart';
import '../models/product_model.dart';
import 'business_detail_page.dart';
import 'product_detail_page.dart';

class SearchPage extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const SearchPage({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();

  List<BusinessModel> businesses = [];
  List<ProductModel> products = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> _search() async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        businesses = [];
        products = [];
        errorMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        BusinessApiService.searchBusinesses(query),
        ProductApiService.searchProducts(query),
      ]);

      if (!mounted) return;

      setState(() {
        businesses = results[0] as List<BusinessModel>;
        products = results[1] as List<ProductModel>;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Search failed. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Search DealMate',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearchBox(),
                  const SizedBox(height: 30),
                  _buildResults(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFDBEAFE),
            ),
          ),
          child: const Text(
            'DISCOVER',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
        const SizedBox(height: 13),
        const Text(
          'Find what you need',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Search businesses, products and services on DealMate.',
          style: TextStyle(
            fontSize: 14.5,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
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
      child: Row(
        children: [
          const SizedBox(width: 10),

          const Icon(
            Icons.search_rounded,
            size: 25,
            color: Color(0xFF64748B),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                hintText: 'Search businesses, products or services...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _search,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                disabledBackgroundColor: const Color(0xFF93C5FD),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Search',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(width: 1),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: CircularProgressIndicator(
            color: Color(0xFF2563EB),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return _buildMessageCard(
        icon: Icons.error_outline_rounded,
        title: 'Something went wrong',
        message: errorMessage!,
      );
    }

    if (businesses.isEmpty &&
        products.isEmpty &&
        searchController.text.trim().isNotEmpty) {
      return _buildMessageCard(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        message:
            'Try searching with a different business, product or service name.',
      );
    }

    if (businesses.isEmpty && products.isEmpty) {
      return _buildInitialState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (businesses.isNotEmpty) ...[
          _buildSectionHeader(
            icon: Icons.storefront_outlined,
            title: 'Businesses',
            count: businesses.length,
          ),
          const SizedBox(height: 14),
          ...businesses.map(
            (business) => _businessCard(business),
          ),
          const SizedBox(height: 30),
        ],

        if (products.isNotEmpty) ...[
          _buildSectionHeader(
            icon: Icons.shopping_bag_outlined,
            title: 'Products',
            count: products.length,
          ),
          const SizedBox(height: 14),
          ...products.map(
            (product) => _productCard(product),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _businessCard(BusinessModel business) {
    final imageUrl = _getImageUrl(business.imageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BusinessDetailPage(
                  businessId: business.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _businessImage(imageUrl),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        business.categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              business.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    final bool hasOffer =
        product.offerPrice != null &&
        product.offerPrice! < product.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(
                  productId: product.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _productImage(product.imageUrl),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 9),

                      Row(
                        children: [
                          Text(
                            '₹${(hasOffer ? product.offerPrice! : product.price).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),

                          if (hasOffer) ...[
                            const SizedBox(width: 8),
                            Text(
                              '₹${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                                decoration:
                                    TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'OFFER',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _businessImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.storefront_rounded,
          size: 31,
          color: Color(0xFF2563EB),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 72,
            height: 72,
            color: const Color(0xFFEFF6FF),
            child: const Icon(
              Icons.storefront_rounded,
              size: 31,
              color: Color(0xFF2563EB),
            ),
          );
        },
      ),
    );
  }

  Widget _productImage(String? imageUrl) {
    final url = _getImageUrl(imageUrl);

    if (url.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.shopping_bag_outlined,
          size: 30,
          color: Color(0xFF64748B),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 72,
            height: 72,
            color: const Color(0xFFF1F5F9),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 30,
              color: Color(0xFF64748B),
            ),
          );
        },
      ),
    );
  }

  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return '';
    }

    if (imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    return 'http://10.51.231.80:8080$imageUrl';
  }

  Widget _buildInitialState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 25,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_rounded,
            size: 48,
            color: Color(0xFFCBD5E1),
          ),
          SizedBox(height: 15),
          Text(
            'Start your search',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF334155),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Search for businesses, products or services.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 25,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 46,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}