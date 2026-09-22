import 'package:flutter/material.dart';

import '../api/business_api_service.dart';
import '../api/product_api_service.dart';
import '../api/review_api_service.dart';
import '../models/business_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import 'product_detail_page.dart';
import '../pages/write_review_page.dart';
import 'requirement_page.dart';

import 'package:url_launcher/url_launcher.dart';

class BusinessDetailPage extends StatefulWidget {
  final int businessId;

  const BusinessDetailPage({
    super.key,
    required this.businessId,
  });

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  BusinessModel? business;

  List<ProductModel> products = [];
  List<ReviewModel> reviews = [];

  double averageRating = 0;
  int reviewCount = 0;

  bool isLoading = true;
  bool isProductsLoading = true;
  bool isReviewsLoading = true;

  @override
  void initState() {
    super.initState();

    _loadBusiness();
    _loadProducts();
    _loadReviews();
  }

  Future<void> _loadBusiness() async {
    try {
      final result = await BusinessApiService.getBusinessById(
        widget.businessId,
      );

      if (!mounted) return;

      setState(() {
        business = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final result = await ProductApiService.getProductsByBusiness(
        widget.businessId,
      );

      if (!mounted) return;

      setState(() {
        products = result;
        isProductsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isProductsLoading = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    try {
      final results = await Future.wait([
        ReviewApiService.getReviewsByBusiness(widget.businessId),
        ReviewApiService.getReviewSummary(widget.businessId),
      ]);

      final reviewList = results[0] as List<ReviewModel>;
      final summary = results[1] as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        reviews = reviewList;

        averageRating =
            (summary['averageRating'] as num?)?.toDouble() ?? 0;

        reviewCount =
            (summary['reviewCount'] as num?)?.toInt() ??
                reviews.length;

        isReviewsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isReviewsLoading = false;
      });
    }
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

  Future<void> _callBusiness(String mobile) async {
    final Uri url = Uri.parse('tel:$mobile');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openWhatsApp(String whatsapp) async {
    final number = whatsapp.replaceAll(RegExp(r'[^0-9]'), '');

    final Uri url = Uri.parse('https://wa.me/$number');

   if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(
          business?.name ?? 'Business',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            )
          : business == null
              ? const Center(
                  child: Text(
                    'Business not found',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final businessData = business!;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1180,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(businessData),

                const SizedBox(height: 22),

                _buildQuickInfo(businessData),

                const SizedBox(height: 22),

                _buildAboutSection(businessData),

                const SizedBox(height: 22),

                _buildProductsSection(),

                const SizedBox(height: 28),

                _buildReviewsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BusinessModel businessData) {
    final imageUrl = _getImageUrl(businessData.imageUrl);

    return Container(
      width: double.infinity,
      height: 420,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _heroFallback();
                    },
                  )
                : _heroFallback(),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.18),
                    Colors.black.withOpacity(0.82),
                  ],
                  stops: const [
                    0.0,
                    0.45,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 24,
            top: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                businessData.categoryName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessData.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.7,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        businessData.location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _buildHeroRating(),

                const SizedBox(height: 18),

                _buildHeroActions(businessData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroFallback() {
    return Container(
      color: const Color(0xFFEFF6FF),
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          size: 90,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }

  Widget _buildHeroRating() {
    if (isReviewsLoading) {
      return const SizedBox(
        height: 22,
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );
    }

    if (reviewCount == 0) {
      return const Text(
        'No reviews yet',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
      );
    }

    return Row(
      children: [
        const Icon(
          Icons.star_rounded,
          color: Colors.amber,
          size: 21,
        ),
        const SizedBox(width: 5),
        Text(
          averageRating.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$reviewCount reviews',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroActions(BusinessModel businessData) {
    final hasMobile =
        businessData.showMobile &&
        businessData.mobile != null &&
        businessData.mobile!.isNotEmpty;

    final hasWhatsapp =
        businessData.showWhatsapp &&
        businessData.whatsapp != null &&
        businessData.whatsapp!.isNotEmpty;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (hasMobile)
          ElevatedButton.icon(
            onPressed: () {
              _callBusiness(businessData.mobile!);
            },
            icon: const Icon(Icons.phone_rounded, size: 18),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2563EB),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        if (hasWhatsapp)
          ElevatedButton.icon(
            onPressed: () {
              _openWhatsApp(businessData.whatsapp!);
            },
            icon: const Icon(Icons.chat_rounded, size: 18),
            label: const Text('WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickInfo(BusinessModel businessData) {
    final hasAddress =
        businessData.address != null &&
        businessData.address!.trim().isNotEmpty;

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _infoCard(
          icon: Icons.location_on_outlined,
          title: 'Location',
          value: businessData.location,
        ),
        if (hasAddress)
          _infoCard(
            icon: Icons.home_work_outlined,
            title: 'Address',
            value: businessData.address!,
          ),
        _infoCard(
          icon: Icons.category_outlined,
          title: 'Category',
          value: businessData.categoryName,
        ),
        _infoCard(
          icon: Icons.star_outline_rounded,
          title: 'Rating',
          value: reviewCount == 0
              ? 'New Business'
              : '${averageRating.toStringAsFixed(1)} / 5',
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BusinessModel businessData) {
    final description =
        businessData.description?.trim() ?? '';

    return _sectionCard(
      title: 'About ${businessData.name}',
      subtitle: 'Know more about this business',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.7,
                color: Color(0xFF475569),
              ),
            )
          else
            const Text(
              'Business information will be updated soon.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
              ),
            ),

          const SizedBox(height: 20),

          _buildContactArea(businessData),
        ],
      ),
    );
  }

  Widget _buildContactArea(BusinessModel businessData) {
    final hasMobile =
        businessData.showMobile &&
        businessData.mobile != null &&
        businessData.mobile!.isNotEmpty;

    final hasWhatsapp =
        businessData.showWhatsapp &&
        businessData.whatsapp != null &&
        businessData.whatsapp!.isNotEmpty;

    if (hasMobile || hasWhatsapp) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          if (hasMobile)
            OutlinedButton.icon(
              onPressed: () {
                _callBusiness(businessData.mobile!);
              },
              icon: const Icon(Icons.phone_outlined),
              label: const Text('Call Business'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(
                  color: Color(0xFFD7E3FF),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
              ),
            ),
          if (hasWhatsapp)
            OutlinedButton.icon(
              onPressed: () {
                _openWhatsApp(businessData.whatsapp!);
              },
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Chat on WhatsApp'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF16A34A),
                side: const BorderSide(
                  color: Color(0xFFBBF7D0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
              ),
            ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Want to know more about this business?',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RequirementPage(),
                ),
              );
            },
            child: const Text('Get Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Products & Services',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Explore what this business offers.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 18),

        if (isProductsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(35),
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            ),
          )
        else if (products.isEmpty)
          _emptyCard('No products or services available yet.')
        else
          LayoutBuilder(
            builder: (context, constraints) {
              int columns = 1;

              if (constraints.maxWidth >= 900) {
                columns = 3;
              } else if (constraints.maxWidth >= 600) {
                columns = 2;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  return _buildProductCard(products[index]);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final hasOffer =
        product.offerPrice != null &&
        product.offerPrice! < product.price;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(product),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 9),

                  if (hasOffer)
                    Row(
                      children: [
                        Text(
                          '₹${product.offerPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            decoration:
                                TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2563EB),
                      ),
                    ),

                  const SizedBox(height: 8),

                  if (product.description != null &&
                      product.description!.trim().isNotEmpty)
                    Text(
                      product.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailPage(
                              productId: product.id,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF2563EB),
                        side: const BorderSide(
                          color: Color(0xFFD7E3FF),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(11),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 17,
                          ),
                        ],
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

  Widget _buildProductImage(ProductModel product) {
    if (product.imageUrl == null ||
        product.imageUrl!.trim().isEmpty) {
      return Container(
        height: 190,
        width: double.infinity,
        color: const Color(0xFFF1F5F9),
        child: const Icon(
          Icons.image_outlined,
          size: 55,
          color: Color(0xFF94A3B8),
        ),
      );
    }

    String imageUrl = product.imageUrl!;

    if (!imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://')) {
      imageUrl =
          'http://10.51.231.80:8080$imageUrl';
    }

    return Image.network(
      imageUrl,
      height: 190,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          height: 190,
          width: double.infinity,
          color: const Color(0xFFF1F5F9),
          child: const Icon(
            Icons.broken_image_outlined,
            size: 50,
            color: Color(0xFF94A3B8),
          ),
        );
      },
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Reviews',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'What customers are saying about this business.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 18),

        if (isReviewsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            ),
          )
        else ...[
          _buildReviewSummary(),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WriteReviewPage(
                      businessId: widget.businessId,
                      businessName:
                          business?.name ?? '',
                    ),
                  ),
                );

                if (result == true) {
                  _loadReviews();
                }
              },
              icon: const Icon(
                Icons.rate_review_outlined,
              ),
              label: const Text(
                'Write a Review',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (reviews.isEmpty)
            _emptyCard(
              'No reviews yet. Be the first to review this business.',
            )
          else
            ...reviews.map(
              (review) => _buildReviewCard(review),
            ),
        ],
      ],
    );
  }

  Widget _buildReviewSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                reviewCount == 0
                    ? 'New'
                    : averageRating
                        .toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                reviewCount == 0
                    ? 'No reviews yet'
                    : '$reviewCount customer reviews',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor:
                    const Color(0xFFEFF6FF),
                child: Text(
                  review.name.isNotEmpty
                      ? review.name[0]
                          .toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment != null &&
              review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: const TextStyle(
                color: Color(0xFF475569),
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}