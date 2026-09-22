import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../api/business_api_service.dart';
import '../api/category_api_service.dart';
import '../models/business_model.dart';
import '../models/category_model.dart';
import '../services/auth_storage_service.dart';

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key});

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final _authStorageService = AuthStorageService();

  BusinessModel? _business;
  List<CategoryModel> _categories = [];

  bool _loading = true;
  bool _saving = false;
  bool _editing = false;
  bool _uploadingImage = false;

  String? _error;
  String? _selectedImageUrl;

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadBusiness();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadBusiness() async {
    try {
      final businessId = await _authStorageService.getBusinessId();

      if (businessId == null) {
        throw Exception('Business information not found.');
      }

      final results = await Future.wait([
        BusinessApiService.getBusinessById(businessId),
        CategoryApiService.getCategories(),
      ]);

      final business = results[0] as BusinessModel;
      final categories = results[1] as List<CategoryModel>;

      if (!mounted) return;

      _setFormValues(business);

      setState(() {
        _business = business;
        _categories = categories;
        _selectedImageUrl = business.imageUrl;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to load business profile.';
      });
    }
  }

  void _setFormValues(BusinessModel business) {
    _nameController.text = business.name;
    _mobileController.text = business.mobile ?? '';
    _whatsappController.text = business.whatsapp ?? '';
    _locationController.text = business.location ?? '';
    _addressController.text = business.address ?? '';
    _descriptionController.text = business.description ?? '';
    _selectedCategoryId = business.categoryId;
    _selectedImageUrl = business.imageUrl;
  }

  void _startEditing() {
    final business = _business;

    if (business == null) return;

    _setFormValues(business);

    setState(() {
      _editing = true;
    });
  }

  void _cancelEditing() {
    final business = _business;

    if (business != null) {
      _setFormValues(business);
    }

    setState(() {
      _editing = false;
    });
  }

  Future<void> _pickAndUploadImage() async {
    if (_business == null || _uploadingImage) return;

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

      if (result == null || result.files.isEmpty) {
        return;
      }

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

      setState(() {
        _uploadingImage = true;
      });

      final token = await _authStorageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Login session expired.');
      }

      final imageUrl =
          await BusinessApiService.uploadBusinessImageBytes(
        businessId: _business!.id,
        token: token,
        imageBytes: imageBytes,
        fileName: pickedFile.name,
      );

      final updatedBusiness =
          await BusinessApiService.updateBusiness(
        businessId: _business!.id,
        token: token,
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        whatsapp: _whatsappController.text.trim().isEmpty
            ? null
            : _whatsappController.text.trim(),
        location: _locationController.text.trim(),
        address: _addressController.text.trim().isEmpty
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
        _business = updatedBusiness;
        _selectedImageUrl = updatedBusiness.imageUrl;
        _uploadingImage = false;
      });

      _showMessage(
        'Business image updated successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _uploadingImage = false;
      });

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  Future<void> _saveBusiness() async {
    final business = _business;

    if (business == null) return;

    if (_nameController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _selectedCategoryId == null) {
      _showMessage(
        'Please fill all required fields.',
        isError: true,
      );
      return;
    }

    try {
      setState(() {
        _saving = true;
      });

      final token = await _authStorageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Login session expired.');
      }

      final updatedBusiness =
          await BusinessApiService.updateBusiness(
        businessId: business.id,
        token: token,
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        whatsapp: _whatsappController.text.trim().isEmpty
            ? null
            : _whatsappController.text.trim(),
        location: _locationController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        imageUrl: _selectedImageUrl,
        categoryId: _selectedCategoryId!,
      );

      if (!mounted) return;

      setState(() {
        _business = updatedBusiness;
        _editing = false;
        _saving = false;
        _selectedImageUrl = updatedBusiness.imageUrl;
      });

      _setFormValues(updatedBusiness);

      _showMessage(
        'Business profile updated successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

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

  String? _fullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return null;
    }

    final value = imageUrl.trim();

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    return 'http://10.51.231.80:8080$value';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Business',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF0F172A),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_business == null) {
      return const Center(
        child: Text('Business profile not found.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1050,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              const SizedBox(height: 22),
              if (_editing)
                _buildEditForm()
              else
                _buildProfileView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(
          maxWidth: 450,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 52,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _loadBusiness();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    final business = _business!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB)
                .withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 650;

          final content = Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _heroBusinessImage(business),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.name,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight:
                                FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          business.categoryName ??
                              'Business',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _heroBadge(
                    Icons.location_on_outlined,
                    business.location ??
                        'Location not added',
                  ),
                  _heroBadge(
                    business.paid
                        ? Icons.verified_rounded
                        : Icons.store_outlined,
                    business.paid
                        ? 'Paid Business'
                        : 'Free Listing',
                  ),
                ],
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 22),
                _editButton(),
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 20),
              _editButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _heroBusinessImage(
    BusinessModel business,
  ) {
    final imageUrl =
        _fullImageUrl(business.imageUrl);

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 34,
                );
              },
            )
          : const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 34,
            ),
    );
  }

  Widget _editButton() {
    return ElevatedButton.icon(
      onPressed:
          _editing ? null : _startEditing,
      icon: const Icon(
        Icons.edit_rounded,
        size: 18,
      ),
      label: const Text(
        'Edit Profile',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D4ED8),
        disabledBackgroundColor: Colors.white54,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }

  Widget _heroBadge(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    final business = _business!;

    return Column(
      children: [
        _buildBusinessImageCard(
          business,
          showEditButton: false,
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _infoCard(
                title: 'Business Information',
                icon: Icons.business_rounded,
                children: [
                  _infoRow(
                    Icons.phone_outlined,
                    'Mobile',
                    business.mobile ??
                        'Not available',
                  ),
                  _infoRow(
                    Icons.chat_outlined,
                    'WhatsApp',
                    business.whatsapp ??
                        'Not available',
                  ),
                  _infoRow(
                    Icons.location_on_outlined,
                    'Location',
                    business.location ??
                        'Not available',
                  ),
                  _infoRow(
                    Icons.home_outlined,
                    'Address',
                    business.address ??
                        'Not available',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _infoCard(
                title: 'Listing Status',
                icon: Icons.insights_rounded,
                children: [
                  _statusRow(
                    'Business Active',
                    business.active,
                  ),
                  _statusRow(
                    'Mobile Visible',
                    business.showMobile,
                  ),
                  _statusRow(
                    'WhatsApp Visible',
                    business.showWhatsapp,
                  ),
                  _statusRow(
                    'Paid Business',
                    business.paid,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _infoCard(
          title: 'Business Description',
          icon: Icons.description_outlined,
          children: [
            Text(
              business.description?.isNotEmpty == true
                  ? business.description!
                  : 'No business description added yet.',
              style: const TextStyle(
                fontSize: 15,
                height: 1.7,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBusinessImageCard(
    BusinessModel business, {
    required bool showEditButton,
  }) {
    final imageUrl = _fullImageUrl(
      _selectedImageUrl ?? business.imageUrl,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 110,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) {
                      return const Icon(
                        Icons
                            .image_not_supported_outlined,
                        size: 34,
                        color:
                            Color(0xFF94A3B8),
                      );
                    },
                  )
                : const Icon(
                    Icons.storefront_outlined,
                    size: 36,
                    color: Color(0xFF94A3B8),
                  ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Business Image',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  imageUrl != null
                      ? 'This image is displayed on your business listing.'
                      : 'Add a main image to make your business listing more attractive.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (showEditButton) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _uploadingImage
                        ? null
                        : _pickAndUploadImage,
                    icon: _uploadingImage
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons
                                .photo_camera_outlined,
                            size: 18,
                          ),
                    label: Text(
                      _uploadingImage
                          ? 'Uploading...'
                          : imageUrl != null
                              ? 'Change Image'
                              : 'Add Image',
                    ),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(0xFF2563EB),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Edit Business Profile',
          'Update the information customers see on your listing.',
        ),
        const SizedBox(height: 18),
        _buildBusinessImageCard(
          _business!,
          showEditButton: true,
        ),
        const SizedBox(height: 18),
        _infoCard(
          title: 'Business Details',
          icon: Icons.edit_note_rounded,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns =
                    constraints.maxWidth >= 650;

                if (!twoColumns) {
                  return Column(
                    children: [
                      _textField(
                        controller: _nameController,
                        label: 'Business Name *',
                        icon:
                            Icons.storefront_outlined,
                      ),
                      const SizedBox(height: 16),
                      _textField(
                        controller:
                            _mobileController,
                        label: 'Mobile *',
                        icon: Icons.phone_outlined,
                        keyboardType:
                            TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _textField(
                        controller:
                            _whatsappController,
                        label: 'WhatsApp',
                        icon: Icons.chat_outlined,
                        keyboardType:
                            TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _categoryDropdown(),
                      const SizedBox(height: 16),
                      _textField(
                        controller:
                            _locationController,
                        label: 'Location *',
                        icon: Icons
                            .location_on_outlined,
                      ),
                      const SizedBox(height: 16),
                      _textField(
                        controller:
                            _addressController,
                        label: 'Address',
                        icon: Icons.home_outlined,
                        maxLines: 2,
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            controller:
                                _nameController,
                            label:
                                'Business Name *',
                            icon: Icons
                                .storefront_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _textField(
                            controller:
                                _mobileController,
                            label: 'Mobile *',
                            icon: Icons.phone_outlined,
                            keyboardType:
                                TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            controller:
                                _whatsappController,
                            label: 'WhatsApp',
                            icon:
                                Icons.chat_outlined,
                            keyboardType:
                                TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child:
                              _categoryDropdown(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _textField(
                      controller:
                          _locationController,
                      label: 'Location *',
                      icon: Icons
                          .location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    _textField(
                      controller:
                          _addressController,
                      label: 'Address',
                      icon:
                          Icons.home_outlined,
                      maxLines: 2,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _textField(
              controller: _descriptionController,
              label: 'Business Description',
              icon: Icons.description_outlined,
              maxLines: 5,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _infoCard(
          title: 'Contact Visibility',
          icon: Icons.visibility_outlined,
          children: [
            const Text(
              'Contact visibility is controlled by DealMate admin.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            _statusRow(
              'Mobile Number',
              _business!.showMobile,
            ),
            _statusRow(
              'WhatsApp',
              _business!.showWhatsapp,
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed:
                  _saving || _uploadingImage
                      ? null
                      : _cancelEditing,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed:
                  _saving || _uploadingImage
                      ? null
                      : _saveBusiness,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.save_rounded,
                    ),
              label: Text(
                _saving
                    ? 'Saving...'
                    : 'Save Changes',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _categoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: _inputDecoration(
        'Category *',
        Icons.category_outlined,
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<int>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(
        label,
        icon,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        size: 20,
        color: const Color(0xFF64748B),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
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
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEFF6FF),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color:
                      const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(
    String title,
    bool value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            value
                ? Icons.check_circle_rounded
                : Icons
                    .remove_circle_outline_rounded,
            size: 21,
            color: value
                ? const Color(0xFF16A34A)
                : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 7),
          Text(
            value ? 'Yes' : 'No',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: value
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}