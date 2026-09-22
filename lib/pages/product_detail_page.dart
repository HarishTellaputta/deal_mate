import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/business_api_service.dart';
import '../api/product_api_service.dart';
import '../models/business_model.dart';
import '../models/product_model.dart';
import 'requirement_page.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}

class _ProductDetailPageState
    extends State<ProductDetailPage> {
  static const String _baseUrl =
      'http://10.51.231.80:8080';

  ProductModel? product;
  BusinessModel? business;

  bool isLoading = true;
  bool isBusinessLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final result =
          await ProductApiService.getProductById(
        widget.productId,
      );

      if (!mounted) return;

      setState(() {
        product = result;
        isLoading = false;
      });

      _loadBusiness(result.businessId);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Failed to load product';
        isLoading = false;
      });
    }
  }

  Future<void> _loadBusiness(
      int businessId) async {
    try {
      final result =
          await BusinessApiService.getBusinessById(
        businessId,
      );

      if (!mounted) return;

      setState(() {
        business = result;
        isBusinessLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isBusinessLoading = false;
      });
    }
  }

  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null ||
        imageUrl.trim().isEmpty) {
      return '';
    }

    final value = imageUrl.trim();

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    return '$_baseUrl$value';
  }

  Future<void> _callBusiness(
      String mobile) async {
    final Uri url =
        Uri.parse('tel:$mobile');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

Future<void> _openWhatsApp(
    String whatsapp) async {
  final number = whatsapp.replaceAll(
    RegExp(r'[^0-9]'),
    '',
  );

  final Uri url =
      Uri.parse('https://wa.me/$number');

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
      backgroundColor:
          const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF0F172A),
        elevation: 0,
        title: Text(
          product?.name ?? 'Product',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(1),
          child: Container(
            height: 1,
            color:
                const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2563EB),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: _buildStateCard(
          icon:
              Icons.error_outline_rounded,
          title:
              'Something went wrong',
          message: errorMessage!,
        ),
      );
    }

    if (product == null) {
      return Center(
        child: _buildStateCard(
          icon:
              Icons.inventory_2_outlined,
          title:
              'Product not found',
          message:
              'This product may no longer be available.',
        ),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 1180,
          ),
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              20,
              18,
              50,
            ),
            child:
                _buildProductWebsite(),
          ),
        ),
      ),
    );
  }

  Widget _buildProductWebsite() {
    final item = product!;

    final bool hasOffer =
        item.offerPrice != null &&
        item.offerPrice! < item.price;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildProductHero(
          item,
          hasOffer,
        ),

        const SizedBox(height: 22),

        _buildBusinessBanner(),

        const SizedBox(height: 22),

        _buildInformationSections(item),

        const SizedBox(height: 22),

        _buildContactSection(),
      ],
    );
  }

  Widget _buildProductHero(
    ProductModel item,
    bool hasOffer,
  ) {
    final imageUrl =
        _getImageUrl(item.imageUrl);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(26),
        border: Border.all(
          color:
              const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x10000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias,
      child: LayoutBuilder(
        builder:
            (context, constraints) {
          final bool isMobile =
              constraints.maxWidth < 760;

          if (isMobile) {
            return Column(
              children: [
                _buildHeroImage(
                  imageUrl,
                  hasOffer,
                ),
                Padding(
                  padding:
                      const EdgeInsets.all(22),
                  child:
                      _buildHeroInformation(
                    item,
                    hasOffer,
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              Expanded(
                flex: 5,
                child:
                    _buildHeroImage(
                  imageUrl,
                  hasOffer,
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding:
                      const EdgeInsets.all(34),
                  child:
                      _buildHeroInformation(
                    item,
                    hasOffer,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroImage(
    String imageUrl,
    bool hasOffer,
  ) {
    return SizedBox(
      height: 480,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder:
                  (context,
                      child,
                      progress) {
                if (progress == null) {
                  return child;
                }

                return const Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        Color(0xFF2563EB),
                  ),
                );
              },
              errorBuilder:
                  (_, __, ___) {
                return _imageFallback();
              },
            )
          else
            _imageFallback(),

          if (hasOffer)
            Positioned(
              top: 18,
              left: 18,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFF16A34A),
                  borderRadius:
                      BorderRadius.circular(
                    30,
                  ),
                ),
                child: const Text(
                  'SPECIAL OFFER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color:
          const Color(0xFFF1F5F9),
      child: const Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .image_outlined,
              size: 75,
              color:
                  Color(0xFF94A3B8),
            ),
            SizedBox(height: 8),
            Text(
              'Product image',
              style: TextStyle(
                color:
                    Color(0xFF94A3B8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroInformation(
    ProductModel item,
    bool hasOffer,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        if (business != null)
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 18,
                color:
                    Color(0xFF2563EB),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  business!.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 14),

        Text(
          item.name,
          style: const TextStyle(
            fontSize: 34,
            height: 1.15,
            fontWeight:
                FontWeight.w900,
            color:
                Color(0xFF0F172A),
            letterSpacing: -.8,
          ),
        ),

        const SizedBox(height: 22),

        _buildPrice(
          item,
          hasOffer,
        ),

        const SizedBox(height: 26),

        if (item.description != null &&
            item.description!
                .trim()
                .isNotEmpty)
          Text(
            item.description!,
            maxLines: 5,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color:
                  Color(0xFF475569),
            ),
          ),

        const SizedBox(height: 26),

        _buildHeroContactButtons(),
      ],
    );
  }

  Widget _buildPrice(
    ProductModel item,
    bool hasOffer,
  ) {
    if (!hasOffer) {
      return Text(
        '₹${item.price.toStringAsFixed(0)}',
        style: const TextStyle(
          fontSize: 34,
          fontWeight:
              FontWeight.w900,
          color:
              Color(0xFF2563EB),
        ),
      );
    }

    final saving =
        item.price -
            item.offerPrice!;

    final percentage =
        ((saving / item.price) * 100)
            .round();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              '₹${item.offerPrice!.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 34,
                fontWeight:
                    FontWeight.w900,
                color:
                    Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 4,
              ),
              child: Text(
                '₹${item.price.toStringAsFixed(0)}',
                style:
                    const TextStyle(
                  fontSize: 16,
                  color:
                      Color(0xFF94A3B8),
                  decoration:
                      TextDecoration
                          .lineThrough,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'Save ₹${saving.toStringAsFixed(0)}  •  $percentage% off',
          style:
              const TextStyle(
            color:
                Color(0xFF16A34A),
            fontSize: 13,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroContactButtons() {
    if (isBusinessLoading) {
      return const SizedBox(
        height: 48,
        child: Center(
          child:
              CircularProgressIndicator(
            strokeWidth: 2,
            color:
                Color(0xFF2563EB),
          ),
        ),
      );
    }

    if (business == null) {
      return const SizedBox();
    }

    final canCall =
        business!.showMobile &&
        business!.mobile != null &&
        business!.mobile!
            .trim()
            .isNotEmpty;

    final canWhatsapp =
        business!.showWhatsapp &&
        business!.whatsapp != null &&
        business!.whatsapp!
            .trim()
            .isNotEmpty;

    if (!canCall &&
        !canWhatsapp) {
      return const SizedBox();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (canCall)
          ElevatedButton.icon(
            onPressed: () {
              _callBusiness(
                business!.mobile!,
              );
            },
            icon: const Icon(
              Icons.phone_rounded,
              size: 18,
            ),
            label:
                const Text('Call'),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                0xFF2563EB,
              ),
              foregroundColor:
                  Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),
        if (canWhatsapp)
          ElevatedButton.icon(
            onPressed: () {
              _openWhatsApp(
                business!.whatsapp!,
              );
            },
            icon: const Icon(
              Icons.chat_rounded,
              size: 18,
            ),
            label:
                const Text('WhatsApp'),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                0xFF16A34A,
              ),
              foregroundColor:
                  Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBusinessBanner() {
    if (isBusinessLoading ||
        business == null) {
      return const SizedBox();
    }

    final imageUrl =
        _getImageUrl(
      business!.imageUrl,
    );

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            clipBehavior:
                Clip.antiAlias,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFEFF6FF),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) {
                      return const Icon(
                        Icons
                            .storefront_rounded,
                        color:
                            Color(
                          0xFF2563EB,
                        ),
                      );
                    },
                  )
                : const Icon(
                    Icons
                        .storefront_rounded,
                    color:
                        Color(0xFF2563EB),
                  ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sold / offered by',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  business!.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons
                          .location_on_outlined,
                      size: 14,
                      color:
                          Color(0xFF64748B),
                    ),
                    const SizedBox(
                        width: 3),
                    Expanded(
                      child: Text(
                        business!.location,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              Color(
                            0xFF64748B,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSections(
    ProductModel item,
  ) {
    final hasDescription =
        item.description != null &&
        item.description!
            .trim()
            .isNotEmpty;

    final hasSpecifications =
        item.specifications != null &&
        item.specifications!
            .trim()
            .isNotEmpty;

    if (!hasDescription &&
        !hasSpecifications) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Information',
          style: TextStyle(
            fontSize: 25,
            fontWeight:
                FontWeight.w900,
            color:
                Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Everything you need to know about this product.',
          style: TextStyle(
            fontSize: 14,
            color:
                Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 18),

        if (hasDescription)
          _contentCard(
            icon:
                Icons.description_outlined,
            title:
                'About this product',
            content:
                item.description!,
          ),

        if (hasDescription &&
            hasSpecifications)
          const SizedBox(height: 14),

        if (hasSpecifications)
          _contentCard(
            icon:
                Icons.tune_rounded,
            title:
                'Specifications',
            content:
                item.specifications!,
          ),
      ],
    );
  }

  Widget _contentCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x05000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF1F5FF,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(
                    0xFF2563EB,
                  ),
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w900,
                  color:
                      Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style:
                const TextStyle(
              fontSize: 14,
              height: 1.7,
              color:
                  Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    if (isBusinessLoading) {
      return const SizedBox();
    }

    final canCall =
        business?.showMobile == true &&
        business?.mobile != null &&
        business!.mobile!
            .trim()
            .isNotEmpty;

    final canWhatsapp =
        business?.showWhatsapp == true &&
        business?.whatsapp != null &&
        business!.whatsapp!
            .trim()
            .isNotEmpty;

    if (canCall || canWhatsapp) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color:
                const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Interested in this product?',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.w900,
                color:
                    Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Contact the business directly for price and product details.',
              style: TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (canCall)
                  ElevatedButton.icon(
                    onPressed: () {
                      _callBusiness(
                        business!.mobile!,
                      );
                    },
                    icon: const Icon(
                      Icons.call_rounded,
                    ),
                    label:
                        const Text('Call Business'),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF2563EB,
                      ),
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                if (canWhatsapp)
                  OutlinedButton.icon(
                    onPressed: () {
                      _openWhatsApp(
                        business!.whatsapp!,
                      );
                    },
                    icon: const Icon(
                      Icons.chat_rounded,
                    ),
                    label:
                        const Text('WhatsApp'),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(
                        0xFF16A34A,
                      ),
                      side:
                          const BorderSide(
                        color:
                            Color(0xFFBBF7D0),
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            const Color(0xFFEFF6FF),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFDBEAFE),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color:
                    Color(0xFF2563EB),
              ),
              SizedBox(width: 9),
              Text(
                'Want more details?',
                style:
                    TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w900,
                  color:
                      Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Submit your requirement and DealMate will help you explore this option.',
            style:
                TextStyle(
              fontSize: 13,
              height: 1.5,
              color:
                  Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child:
                ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const RequirementPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.arrow_forward_rounded,
              ),
              label: const Text(
                'Get Details',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF2563EB,
                ),
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      margin:
          const EdgeInsets.all(24),
      padding:
          const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color:
                const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w900,
              color:
                  Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 13,
              color:
                  Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}