import 'package:flutter/material.dart';

import '../api/requirement_api_service.dart';
import '../core/app_colors.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';

class RequirementPage extends StatefulWidget {
  const RequirementPage({super.key});

  @override
  State<RequirementPage> createState() => _RequirementPageState();
}

class _RequirementPageState extends State<RequirementPage> {
  final _formKey = GlobalKey<FormState>();

  final productController = TextEditingController();
  final budgetController = TextEditingController();
  final locationController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  String purchaseTime = 'Within 30 days';

  bool isSubmitting = false;

  @override
  void dispose() {
    productController.dispose();
    budgetController.dispose();
    locationController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> submitRequirement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await RequirementApiService.submitRequirement(
        product: productController.text.trim(),
        budget: budgetController.text.trim(),
        location: locationController.text.trim(),
        purchaseTime: purchaseTime,
        name: nameController.text.trim(),
        mobile: phoneController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Your requirement has been submitted successfully.',
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      productController.clear();
      budgetController.clear();
      locationController.clear();
      nameController.clear();
      phoneController.clear();

      setState(() {
        purchaseTime = 'Within 30 days';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to submit requirement. Please try again.',
          ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Navbar(
              isMobile: isMobile,
            ),
            _formSection(
              isMobile: isMobile,
              isTablet: isTablet,
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _formSection({
    required bool isMobile,
    required bool isTablet,
  }) {
    final horizontalPadding = isMobile
        ? 18.0
        : isTablet
            ? 30.0
            : 60.0;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 48 : 72,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1000,
          ),
          child: Column(
            children: [
              _buildHero(isMobile),

              SizedBox(
                height: isMobile ? 28 : 38,
              ),

              _buildFormCard(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(bool isMobile) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFDBEAFE),
            ),
          ),
          child: const Icon(
            Icons.shopping_cart_checkout_rounded,
            color: Color(0xFF2563EB),
            size: 28,
          ),
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFDBEAFE),
            ),
          ),
          child: const Text(
            'PERSONALIZED BUYING REQUEST',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: Color(0xFF2563EB),
            ),
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Tell Us What You Want to Buy',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 29 : 42,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 12),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 650,
          ),
          child: const Text(
            'Share a few details about what you are looking for, '
            'and DealMate can help you explore suitable buying options.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF64748B),
            ),
          ),
        ),

        const SizedBox(height: 18),

        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 17,
              color: Color(0xFF16A34A),
            ),
            SizedBox(width: 6),
            Text(
              'No customer service fee',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isMobile ? 20 : 32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              icon: Icons.shopping_bag_outlined,
              title: 'Purchase Details',
              subtitle: 'Tell us what you are looking for.',
            ),

            const SizedBox(height: 24),

            _label('What do you want to buy?'),

            _textField(
              controller: productController,
              hint: 'Example: Bike, TV, Laptop, Furniture...',
              icon: Icons.shopping_bag_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter what you want to buy';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _label('Approximate Budget'),

            _textField(
              controller: budgetController,
              hint: 'Example: ₹50,000',
              icon: Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your approximate budget';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _label('Your Location'),

            _textField(
              controller: locationController,
              hint: 'City / Area',
              icon: Icons.location_on_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your location';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _label('When are you planning to buy?'),

            DropdownButtonFormField<String>(
              initialValue: purchaseTime,
              isExpanded: true,
              decoration: _dropdownDecoration(
                Icons.calendar_today_outlined,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Within 7 days',
                  child: Text('Within 7 days'),
                ),
                DropdownMenuItem(
                  value: 'Within 30 days',
                  child: Text('Within 30 days'),
                ),
                DropdownMenuItem(
                  value: 'Within 3 months',
                  child: Text('Within 3 months'),
                ),
                DropdownMenuItem(
                  value: 'Just researching',
                  child: Text('Just researching'),
                ),
              ],
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          purchaseTime = value;
                        });
                      }
                    },
            ),

            const SizedBox(height: 30),

            _buildDivider(),

            const SizedBox(height: 28),

            _sectionTitle(
              icon: Icons.person_outline_rounded,
              title: 'Your Contact Details',
              subtitle: 'We need your details to follow up on your request.',
            ),

            const SizedBox(height: 24),

            _label('Name'),

            _textField(
              controller: nameController,
              hint: 'Your name',
              icon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _label('Mobile Number'),

            _textField(
              controller: phoneController,
              hint: '10-digit mobile number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your mobile number';
                }

                if (value.trim().length != 10) {
                  return 'Enter a valid 10-digit number';
                }

                return null;
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : submitRequirement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  disabledBackgroundColor:
                      const Color(0xFF93C5FD),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            size: 19,
                          ),
                          SizedBox(width: 9),
                          Text(
                            'Submit My Requirement',
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
                'Your information is used only to process your requirement.',
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

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2563EB),
            size: 21,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 13.5,
          color: Color(0xFF94A3B8),
        ),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: const Color(0xFF64748B),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 16,
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
      ),
    );
  }

  InputDecoration _dropdownDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        size: 20,
        color: const Color(0xFF64748B),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
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
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'CONTACT',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }
}