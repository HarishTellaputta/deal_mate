import 'package:flutter/material.dart';

import '../api/product_api_service.dart';
import '../models/product_model.dart';
import '../services/auth_storage_service.dart';
import 'business_add_product_page.dart';

class BusinessProductsPage extends StatefulWidget {
  const BusinessProductsPage({super.key});

  @override
  State<BusinessProductsPage> createState() => _BusinessProductsPageState();
}

class _BusinessProductsPageState extends State<BusinessProductsPage> {
  final _authStorageService = AuthStorageService();

  List<ProductModel> _products = [];
  bool _loading = true;
  String? _error;

  static const String backendUrl = 'http://10.51.231.80:8080';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final businessId = await _authStorageService.getBusinessId();

      if (businessId == null) {
        throw Exception('Business information not found.');
      }

      final products = await ProductApiService.getProductsByBusiness(
        businessId,
      );

      if (!mounted) return;

      setState(() {
        _products = products;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to load products.';
      });

      debugPrint('PRODUCT LOAD ERROR: $e');
    }
  }

  Future<void> _openAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BusinessAddProductPage()),
    );

    _loadProducts();
  }

  Future<void> _openEditProduct(ProductModel product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessAddProductPage(product: product),
      ),
    );

    _loadProducts();
  }

  String? _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return null;
    }

    final value = imageUrl.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    return '$backendUrl${value.startsWith('/') ? '' : '/'}$value';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Products',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Manage your products and services',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Add Product',
              onPressed: _openAddProduct,
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF2563EB),
                size: 27,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProduct,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 5,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: _loadProducts,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final isMobile = width < 700;
          final isTablet = width >= 700 && width < 1100;

          final columns = isMobile
              ? 1
              : isTablet
              ? 2
              : 3;

          return GridView.builder(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 16 : 28,
              22,
              isMobile ? 16 : 28,
              110,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: isMobile ? 1.65 : 0.92,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return _productCard(_products[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We could not load your products.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _loadProducts();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Your catalogue is empty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Add products or services to showcase your business on DealMate.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _openAddProduct,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add Your First Product',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    final imageUrl = _getImageUrl(product.imageUrl);

    debugPrint('IMAGE URL: $imageUrl');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('IMAGE LOAD ERROR: $error');

                              return _imagePlaceholder();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return _imageLoading();
                            },
                          )
                        : _imagePlaceholder(),
                  ),

                  Positioned(
                    top: 12,
                    right: 12,
                    child: _statusBadge(product.active),
                  ),

                  // EDIT BUTTON
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(11),
                        onTap: () => _openEditProduct(product),
                        child: const Padding(
                          padding: EdgeInsets.all(9),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 19,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // EDIT ICON
                        IconButton(
                          tooltip: 'Edit Product',
                          onPressed: () => _openEditProduct(product),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    _priceSection(product),

                    if (product.description != null &&
                        product.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        product.description!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceSection(ProductModel product) {
    if (product.offerPrice != null) {
      return Row(
        children: [
          Text(
            '₹${product.offerPrice!.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${product.price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(7),
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
      );
    }

    return Text(
      '₹${product.price.toStringAsFixed(0)}',
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: Color(0xFF2563EB),
      ),
    );
  }

  Widget _statusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEFFDF4) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            active ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: active ? const Color(0xFF15803D) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _imageLoading() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }
}
