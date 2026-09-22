import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../api/auth_api_service.dart';
import '../api/business_api_service.dart';
import '../api/category_api_service.dart';
import '../models/category_model.dart';
import '../services/auth_storage_service.dart';
import 'business_dashboard_page.dart';

class BusinessLoginPage extends StatefulWidget {
  const BusinessLoginPage({super.key});

  @override
  State<BusinessLoginPage> createState() => _BusinessLoginPageState();
}

class _BusinessLoginPageState extends State<BusinessLoginPage> {
  final _authApiService = AuthApiService();
  final _authStorageService = AuthStorageService();

  final _formKey = GlobalKey<FormState>();

  // Login
  final _loginMobileController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Registration
  final _ownerNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _registerMobileController = TextEditingController();
  final _registerWhatsappController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<CategoryModel> _categories = [];

  // Business image
  Uint8List? _businessImageBytes;
  String? _businessImageName;

  bool _isRegistering = false;
  bool _loading = false;
  bool _uploadingImage = false;

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;

  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _loginMobileController.dispose();
    _loginPasswordController.dispose();

    _ownerNameController.dispose();
    _businessNameController.dispose();
    _registerMobileController.dispose();
    _registerWhatsappController.dispose();
    _registerPasswordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryApiService.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
      });
    } catch (e) {
      debugPrint('CATEGORY LOAD ERROR: $e');
    }
  }

  // ----------------------------------------------------------
  // IMAGE PICKER
  // ----------------------------------------------------------

  Future<void> _pickBusinessImage() async {
    if (_loading) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'webp',
        ],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.single;
      final imageBytes = pickedFile.bytes;

      if (imageBytes == null) {
        _showMessage(
          'Unable to read selected image.',
          isError: true,
        );
        return;
      }

      if (imageBytes.length > 1024 * 1024) {
        _showMessage(
          'Image size must be 1 MB or less.',
          isError: true,
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _businessImageBytes = imageBytes;
        _businessImageName = pickedFile.name;
      });
    } catch (e) {
      _showMessage(
        'Unable to select image.',
        isError: true,
      );
    }
  }

  // ----------------------------------------------------------
  // LOGIN
  // ----------------------------------------------------------

  Future<void> _login() async {
    final mobile = _loginMobileController.text.trim();
    final password = _loginPasswordController.text;

    if (!_validateMobile(mobile)) {
      _showMessage(
        'Please enter a valid 10-digit mobile number.',
        isError: true,
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage(
        'Please enter your password.',
        isError: true,
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final result = await _authApiService.login(
        mobile: mobile,
        password: password,
      );

      if (result.role != 'BUSINESS_ADMIN') {
        _showMessage(
          'This login is only for business owners.',
          isError: true,
        );
        return;
      }

      await _authStorageService.saveLogin(
        token: result.token,
        userId: result.userId,
        businessId: result.businessId,
        role: result.role,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BusinessDashboardPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String message =
          'Login failed. Please check your details.';

      final error = e.toString();

      if (error.contains('Invalid') ||
          error.contains('invalid') ||
          error.contains('password')) {
        message = 'Invalid mobile number or password.';
      }

      _showMessage(
        message,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ----------------------------------------------------------
  // REGISTRATION
  // ----------------------------------------------------------

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      _showMessage(
        'Please select a business category.',
        isError: true,
      );
      return;
    }

    if (_businessImageBytes == null) {
      _showMessage(
        'Please select your main business image.',
        isError: true,
      );
      return;
    }

    final password = _registerPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showMessage(
        'Passwords do not match.',
        isError: true,
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // 1. CREATE BUSINESS ACCOUNT
      final result = await _authApiService.registerBusiness(
        ownerName: _ownerNameController.text.trim(),
        mobile: _registerMobileController.text.trim(),
        password: password,
        businessName: _businessNameController.text.trim(),
        location: _locationController.text.trim(),
        whatsapp:
            _registerWhatsappController.text.trim().isEmpty
                ? null
                : _registerWhatsappController.text.trim(),
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
      );

      if (result.role != 'BUSINESS_ADMIN') {
        _showMessage(
          'Registration completed, but business access could not be created.',
          isError: true,
        );
        return;
      }

      // 2. SAVE LOGIN
      await _authStorageService.saveLogin(
        token: result.token,
        userId: result.userId,
        businessId: result.businessId,
        role: result.role,
      );

      // 3. CHECK BUSINESS ID
      if (result.businessId == null) {
        throw Exception(
          'Business created, but business ID was not returned.',
        );
      }

      // 4. UPLOAD BUSINESS IMAGE
      setState(() {
        _uploadingImage = true;
      });

      final imageUrl =
          await BusinessApiService.uploadBusinessImageBytes(
        businessId: result.businessId!,
        token: result.token,
        imageBytes: _businessImageBytes!,
        fileName:
            _businessImageName ?? 'business_image.jpg',
      );

      // 5. SAVE IMAGE URL TO BUSINESS
      await BusinessApiService.updateBusiness(
        businessId: result.businessId!,
        token: result.token,
        name: _businessNameController.text.trim(),
        mobile: _registerMobileController.text.trim(),
        whatsapp:
            _registerWhatsappController.text.trim().isEmpty
                ? null
                : _registerWhatsappController.text.trim(),
        location: _locationController.text.trim(),
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        imageUrl: imageUrl,
        categoryId: _selectedCategoryId!,
      );

      if (!mounted) return;

      setState(() {
        _uploadingImage = false;
      });

      _showMessage(
        'Business account created successfully.',
      );

      await Future.delayed(
        const Duration(milliseconds: 600),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BusinessDashboardPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _uploadingImage = false;
      });

      String message =
          'Registration failed. Please try again.';

      final error = e.toString();

      if (error.contains('already registered')) {
        message =
            'This mobile number is already registered.';
      } else if (error.contains('Category')) {
        message =
            'Please select a valid business category.';
      } else if (error.contains('Mobile')) {
        message =
            'Please enter a valid mobile number.';
      } else if (error.contains('1 MB')) {
        message =
            'Business image must be 1 MB or less.';
      } else if (error.contains('upload')) {
        message =
            'Business account created, but image upload failed.';
      }

      _showMessage(
        message,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _uploadingImage = false;
        });
      }
    }
  }

  // ----------------------------------------------------------
  // VALIDATION
  // ----------------------------------------------------------

  bool _validateMobile(String value) {
    return RegExp(r'^[6-9][0-9]{9}$').hasMatch(value);
  }

  String? _requiredValidator(
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _mobileValidator(String? value) {
    final mobile = value?.trim() ?? '';

    if (mobile.isEmpty) {
      return 'Mobile number is required';
    }

    if (!_validateMobile(mobile)) {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (confirmPassword !=
        _registerPasswordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  _buildBrandHeader(),
                  const SizedBox(height: 24),
                  _buildModeSwitch(),
                  const SizedBox(height: 18),
                  Form(
                    key: _formKey,
                    child: _isRegistering
                        ? _buildRegisterCard()
                        : _buildLoginCard(),
                  ),
                  const SizedBox(height: 18),
                  _buildBackButton(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x252563EB),
                blurRadius: 22,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          _isRegistering
              ? 'Create Business Account'
              : 'Business Login',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          _isRegistering
              ? 'List your business and let local customers discover you.'
              : 'Manage your business on DealMate.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.5,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _modeButton(
              label: 'Login',
              icon: Icons.login_rounded,
              selected: !_isRegistering,
              onPressed: () {
                if (_loading) return;

                setState(() {
                  _isRegistering = false;
                });
              },
            ),
          ),
          Expanded(
            child: _modeButton(
              label: 'Register',
              icon: Icons.add_business_rounded,
              selected: _isRegistering,
              onPressed: () {
                if (_loading) return;

                setState(() {
                  _isRegistering = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 46,
      decoration: BoxDecoration(
        color: selected
            ? Colors.white
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: selected
              ? const Color(0xFF2563EB)
              : const Color(0xFF64748B),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected
                ? const Color(0xFF2563EB)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Sign in to manage your business listing.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 25),
          _field(
            controller: _loginMobileController,
            label: 'Mobile Number',
            hint: 'Enter 10-digit mobile number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: _mobileValidator,
          ),
          const SizedBox(height: 17),
          _field(
            controller: _loginPasswordController,
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureLoginPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureLoginPassword =
                      !_obscureLoginPassword;
                });
              },
              icon: Icon(
                _obscureLoginPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            onSubmitted: (_) => _login(),
          ),
          const SizedBox(height: 25),
          _primaryButton(
            label: 'Login',
            loadingText: 'Signing in...',
            onPressed: _login,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Details',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Create your DealMate business profile.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 23),

          _buildBusinessImagePicker(),

          const SizedBox(height: 22),

          _field(
            controller: _ownerNameController,
            label: 'Owner Name *',
            hint: 'Enter owner name',
            icon: Icons.person_outline_rounded,
            validator: (value) =>
                _requiredValidator(
              value,
              'Owner name',
            ),
          ),
          const SizedBox(height: 16),

          _field(
            controller: _businessNameController,
            label: 'Business Name *',
            hint: 'Enter business name',
            icon: Icons.storefront_outlined,
            validator: (value) =>
                _requiredValidator(
              value,
              'Business name',
            ),
          ),
          const SizedBox(height: 16),

          _field(
            controller: _registerMobileController,
            label: 'Mobile Number *',
            hint: 'Enter 10-digit mobile number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: _mobileValidator,
          ),
          const SizedBox(height: 16),

          _field(
            controller: _registerWhatsappController,
            label: 'WhatsApp Number',
            hint: 'Optional',
            icon: Icons.chat_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return null;
              }

              if (!_validateMobile(
                value.trim(),
              )) {
                return 'Enter a valid 10-digit WhatsApp number';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),

          _field(
            controller: _registerPasswordController,
            label: 'Password *',
            hint: 'Minimum 6 characters',
            icon: Icons.lock_outline_rounded,
            obscureText:
                _obscureRegisterPassword,
            validator: _passwordValidator,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureRegisterPassword =
                      !_obscureRegisterPassword;
                });
              },
              icon: Icon(
                _obscureRegisterPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          const SizedBox(height: 16),

          _field(
            controller: _confirmPasswordController,
            label: 'Confirm Password *',
            hint: 'Re-enter password',
            icon: Icons.lock_reset_outlined,
            obscureText:
                _obscureConfirmPassword,
            validator:
                _confirmPasswordValidator,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword =
                      !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          const SizedBox(height: 16),

          _categoryDropdown(),

          const SizedBox(height: 16),

          _field(
            controller: _locationController,
            label: 'Location *',
            hint: 'e.g. Khammam',
            icon: Icons.location_on_outlined,
            validator: (value) =>
                _requiredValidator(
              value,
              'Location',
            ),
          ),
          const SizedBox(height: 16),

          _field(
            controller: _addressController,
            label: 'Address',
            hint: 'Business address (optional)',
            icon: Icons.home_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          _field(
            controller: _descriptionController,
            label: 'Business Description',
            hint: 'Tell customers about your business',
            icon: Icons.description_outlined,
            maxLines: 4,
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Your business will start with a free DealMate listing. You can manage your profile and products after registration.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          _primaryButton(
            label: 'Create Business Account',
            loadingText: _uploadingImage
                ? 'Uploading Business Image...'
                : 'Creating Account...',
            onPressed: _register,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessImagePicker() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Main Business Image *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Add your shop, office or business image. Maximum 1 MB.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _loading
              ? null
              : _pickBusinessImage,
          child: Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: _businessImageBytes != null
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
                width:
                    _businessImageBytes != null
                        ? 1.5
                        : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _businessImageBytes != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        _businessImageBytes!,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          decoration:
                              BoxDecoration(
                            color: Colors.black
                                .withOpacity(0.55),
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: IconButton(
                            onPressed: _loading
                                ? null
                                : _pickBusinessImage,
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip:
                                'Change image',
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.black
                                .withOpacity(0.6),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons
                                    .check_circle_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Image selected',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : InkWell(
                    onTap: _loading
                        ? null
                        : _pickBusinessImage,
                    child: const Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons
                              .add_photo_alternate_outlined,
                          size: 42,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Add Business Image',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'JPG, PNG or WEBP • Max 1 MB',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _categoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      isExpanded: true,
      validator: (value) {
        if (value == null) {
          return 'Please select a business category';
        }

        return null;
      },
      decoration: _inputDecoration(
        'Business Category *',
        Icons.category_outlined,
      ),
      hint: const Text(
        'Select your category',
        style: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
        ),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<int>(
          value: category.id,
          child: Text(
            category.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _loading
          ? null
          : (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    int? maxLength,
    Widget? suffixIcon,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines:
          obscureText ? 1 : maxLines,
      maxLength: maxLength,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: _inputDecoration(
        label,
        icon,
        hint: hint,
        suffixIcon: suffixIcon,
        counterText:
            maxLength != null ? '' : null,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
    Widget? suffixIcon,
    String? counterText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      counterText: counterText,
      prefixIcon: Icon(
        icon,
        size: 20,
        color: const Color(0xFF64748B),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _primaryButton({
    required String label,
    required String loadingText,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
            _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF93C5FD),
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(13),
          ),
        ),
        child: _loading
            ? Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      loadingText,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style:
                    const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: _loading
          ? null
          : () {
              Navigator.pop(context);
            },
      icon: const Icon(
        Icons.arrow_back_rounded,
        size: 18,
      ),
      label: const Text(
        'Back to DealMate',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}