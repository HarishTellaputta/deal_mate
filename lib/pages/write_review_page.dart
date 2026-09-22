import 'package:flutter/material.dart';

import '../api/review_api_service.dart';

class WriteReviewPage extends StatefulWidget {
  final int businessId;
  final String businessName;

  const WriteReviewPage({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final commentController = TextEditingController();

  int selectedRating = 0;
  bool isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a rating'),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await ReviewApiService.createReview(
        name: nameController.text.trim(),
        mobile: mobileController.text.trim(),
        rating: selectedRating,
        comment: commentController.text.trim().isEmpty
            ? null
            : commentController.text.trim(),
        businessId: widget.businessId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Review submitted successfully'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to submit review'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Write a Review',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 620,
              ),
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.rate_review_outlined,
                color: Color(0xFFF59E0B),
                size: 28,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Review ${widget.businessName}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                height: 1.2,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Share your experience and help other customers make better decisions.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.55,
              ),
            ),

            const SizedBox(height: 30),

            // Rating section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Rating',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: List.generate(
                      5,
                      (index) {
                        final rating = index + 1;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating = rating;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 7,
                            ),
                            child: Icon(
                              rating <= selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 36,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (selectedRating > 0) ...[
                    const SizedBox(height: 5),
                    Text(
                      _ratingText(selectedRating),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildLabel('Your Name'),

            const SizedBox(height: 8),

            TextFormField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                hint: 'Enter your name',
                icon: Icons.person_outline_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            _buildLabel('Mobile Number'),

            const SizedBox(height: 8),

            TextFormField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              maxLength: 10,
              decoration: _inputDecoration(
                hint: 'Enter your mobile number',
                icon: Icons.phone_outlined,
              ).copyWith(
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Mobile number is required';
                }

                final mobile = value.trim();

                if (mobile.length != 10) {
                  return 'Enter a valid 10-digit mobile number';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            _buildLabel('Your Review'),

            const SizedBox(height: 8),

            TextFormField(
              controller: commentController,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: _inputDecoration(
                hint: 'Tell others about your experience...',
                icon: Icons.chat_bubble_outline_rounded,
                alignIconTop: true,
              ),
            ),

            const SizedBox(height: 26),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  disabledBackgroundColor: const Color(0xFF93C5FD),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 21,
                        width: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            size: 19,
                          ),
                          SizedBox(width: 9),
                          Text(
                            'Submit Review',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 14),

            const Center(
              child: Text(
                'Your feedback helps other customers discover better businesses.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool alignIconTop = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFF94A3B8),
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          top: alignIconTop ? 14 : 0,
        ),
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xFF64748B),
        ),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
          width: 1.5,
        ),
      ),
    );
  }

  String _ratingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor experience';
      case 2:
        return 'Needs improvement';
      case 3:
        return 'Good experience';
      case 4:
        return 'Great experience';
      case 5:
        return 'Excellent experience';
      default:
        return '';
    }
  }
}