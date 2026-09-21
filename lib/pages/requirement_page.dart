
import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    productController.dispose();
    budgetController.dispose();
    locationController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void submitRequirement() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Your requirement has been submitted successfully.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
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
        ? 16.0
        : isTablet
            ? 28.0
            : 30.0;

    final verticalPadding = isMobile ? 45.0 : 70.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 850,
          ),
          child: Column(
            children: [
              Text(
                'Tell Us What You Want to Buy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 29 : 40,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Share a few details and let DealMate explore '
                'suitable buying options for you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 14.5 : 17,
                  height: 1.6,
                  color: AppColors.muted,
                ),
              ),

              SizedBox(height: isMobile ? 28 : 40),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  isMobile ? 18 : 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    isMobile ? 16 : 22,
                  ),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _label(
                        'What do you want to buy?',
                      ),

                      _textField(
                        controller: productController,
                        hint:
                            'Example: Bike, TV, Laptop, Furniture...',
                        icon:
                            Icons.shopping_bag_outlined,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter what you want to buy';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 22),

                      _label(
                        'Approximate Budget',
                      ),

                      _textField(
                        controller: budgetController,
                        hint: 'Example: ₹50,000',
                        icon:
                            Icons.currency_rupee_rounded,
                        keyboardType:
                            TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your approximate budget';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 22),

                      _label(
                        'Your Location',
                      ),

                      _textField(
                        controller: locationController,
                        hint: 'City / Area',
                        icon:
                            Icons.location_on_outlined,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your location';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 22),

                      _label(
                        'When are you planning to buy?',
                      ),

                      DropdownButtonFormField<String>(
                        initialValue: purchaseTime,
                        isExpanded: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                          ),
                          filled: true,
                          fillColor:
                              AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Within 7 days',
                            child:
                                Text('Within 7 days'),
                          ),
                          DropdownMenuItem(
                            value: 'Within 30 days',
                            child:
                                Text('Within 30 days'),
                          ),
                          DropdownMenuItem(
                            value: 'Within 3 months',
                            child:
                                Text('Within 3 months'),
                          ),
                          DropdownMenuItem(
                            value: 'Just researching',
                            child:
                                Text('Just researching'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              purchaseTime = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 30),

                      const Divider(
                        color: AppColors.border,
                      ),

                      const SizedBox(height: 25),

                      Text(
                        'Your Contact Details',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                      ),

                      const SizedBox(height: 18),

                      _label('Name'),

                      _textField(
                        controller: nameController,
                        hint: 'Your name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 22),

                      _label('Mobile Number'),

                      _textField(
                        controller: phoneController,
                        hint: '10-digit mobile number',
                        icon: Icons.phone_outlined,
                        keyboardType:
                            TextInputType.phone,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your mobile number';
                          }

                          if (value.trim().length !=
                              10) {
                            return 'Enter a valid 10-digit number';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              submitRequirement,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary,
                            foregroundColor:
                                Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 18,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                            ),
                          ),
                          child: Text(
                            'Submit My Requirement',
                            style: TextStyle(
                              fontSize:
                                  isMobile ? 15 : 16,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Center(
                        child: Text(
                          'DealMate does not charge customers a service fee.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}