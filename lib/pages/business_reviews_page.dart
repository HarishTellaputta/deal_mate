import 'package:flutter/material.dart';

import '../api/review_api_service.dart';
import '../models/review_model.dart';
import '../services/auth_storage_service.dart';

class BusinessReviewsPage extends StatefulWidget {
  const BusinessReviewsPage({super.key});

  @override
  State<BusinessReviewsPage> createState() =>
      _BusinessReviewsPageState();
}

class _BusinessReviewsPageState
    extends State<BusinessReviewsPage> {
  final _authStorageService = AuthStorageService();

  List<ReviewModel> _reviews = [];

  bool _loading = true;
  String? _error;

  double _averageRating = 0;
  int _totalReviews = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final businessId =
          await _authStorageService.getBusinessId();

      if (businessId == null) {
        throw Exception(
          'Business information not found.',
        );
      }

      final reviews =
          await ReviewApiService.getReviewsByBusiness(
        businessId,
      );

      double average = 0;

      if (reviews.isNotEmpty) {
        final total = reviews.fold<double>(
          0,
          (sum, review) => sum + review.rating,
        );

        average = total / reviews.length;
      }

      if (!mounted) return;

      setState(() {
        _reviews = reviews;
        _totalReviews = reviews.length;
        _averageRating = average;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to load reviews.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF0F172A),
        ),
        title: const Text(
          'Customer Reviews',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2563EB),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: _loadReviews,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 650;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 28,
              vertical: 24,
            ),
            children: [
              _pageIntro(isMobile),

              const SizedBox(height: 22),

              _summarySection(isMobile),

              const SizedBox(height: 28),

              _reviewsHeader(),

              const SizedBox(height: 14),

              if (_reviews.isEmpty)
                _emptyReviews()
              else
                ..._reviews.map(_reviewCard),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _pageIntro(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Feedback',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'See what customers are saying about your business.',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            color: const Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _summarySection(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _ratingSummaryCard(),
          const SizedBox(height: 12),
          _reviewCountCard(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _ratingSummaryCard(),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: _reviewCountCard(),
        ),
      ],
    );
  }

  Widget _ratingSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142563EB),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Rating',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                _ratingStars(
                  _averageRating.round(),
                  light: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCountCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              color: Color(0xFF2563EB),
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                '$_totalReviews',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _totalReviews == 1
                    ? 'Customer Review'
                    : 'Customer Reviews',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewsHeader() {
    return Row(
      children: [
        const Text(
          'Recent Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 9),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$_totalReviews',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewCard(ReviewModel review) {
    final String initial = review.name.isNotEmpty
        ? review.name[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _ratingStars(review.rating),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${review.rating}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (review.comment != null &&
              review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Text(
                review.comment!.trim(),
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ratingStars(
    int rating, {
    bool light = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) {
          final filled = index < rating;

          return Icon(
            filled
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            size: light ? 17 : 16,
            color: filled
                ? (light
                    ? Colors.white
                    : const Color(0xFFF59E0B))
                : const Color(0xFFCBD5E1),
          );
        },
      ),
    );
  }

  Widget _emptyReviews() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 42,
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
            Icons.rate_review_outlined,
            size: 52,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 15),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Customer reviews will appear here once customers share their experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 14),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });

                  _loadReviews();
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Retry',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}