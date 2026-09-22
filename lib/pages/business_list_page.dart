import 'package:flutter/material.dart';

import '../api/business_api_service.dart';
import '../core/app_colors.dart';
import '../models/business_model.dart';

class BusinessListPage extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const BusinessListPage({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<BusinessListPage> createState() => _BusinessListPageState();
}

class _BusinessListPageState extends State<BusinessListPage> {
  List<BusinessModel> businesses = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBusinesses();
  }

  Future<void> loadBusinesses() async {
    try {
      final result = widget.categoryId != null
          ? await BusinessApiService.getBusinessesByCategory(
              widget.categoryId!,
            )
          : await BusinessApiService.getBusinesses();

      if (!mounted) return;

      setState(() {
        businesses = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('BUSINESS LIST ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.categoryName ?? 'Local Businesses',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : businesses.isEmpty
              ? _emptyState()
              : SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1200,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 50,
                          vertical: 35,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.categoryName != null
                                  ? '${widget.categoryName} Businesses'
                                  : 'Local Businesses',
                              style: TextStyle(
                                fontSize: isMobile ? 27 : 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              '${businesses.length} businesses available',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.muted,
                              ),
                            ),

                            const SizedBox(height: 28),

                            GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: businesses.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile
                                    ? 1
                                    : isTablet
                                        ? 2
                                        : 3,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                childAspectRatio:
                                    isMobile ? 1.9 : 1.35,
                              ),
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                return _businessCard(
                                  businesses[index],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _businessCard(BusinessModel business) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // Business details screen will be connected next.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${business.name} selected',
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
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
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      color: AppColors.primary,
                      size: 27,
                    ),
                  ),

                  const Spacer(),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                business.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                business.categoryName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      business.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${business.name} selected',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 18),

            const Text(
              'No businesses found',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'There are no active businesses in this category yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}