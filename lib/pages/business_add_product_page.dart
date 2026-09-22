import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../services/auth_storage_service.dart';

class BusinessAddProductPage extends StatefulWidget {
  final ProductModel? product;

  const BusinessAddProductPage({
    super.key,
    this.product,
  });

  bool get isEditMode => product != null;

  @override
  State<BusinessAddProductPage> createState() =>
      _BusinessAddProductPageState();
}

class _BusinessAddProductPageState
    extends State<BusinessAddProductPage> {
  static const String baseUrl =
      'http://10.51.231.80:8080/api/v1';

  static const String backendUrl =
      'http://10.51.231.80:8080';

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _offerPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _specificationsController = TextEditingController();

  final _authStorageService = AuthStorageService();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  String? _existingImageUrl;

  bool _loading = false;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      _loadProductData();
    }
  }

  void _loadProductData() {
    final product = widget.product!;

    _nameController.text = product.name;
    _priceController.text = product.price.toString();

    if (product.offerPrice != null) {
      _offerPriceController.text =
          product.offerPrice!.toString();
    }

    _descriptionController.text =
        product.description ?? '';

    _specificationsController.text =
        product.specifications ?? '';

    _existingImageUrl =
        _getImageUrl(product.imageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _offerPriceController.dispose();
    _descriptionController.dispose();
    _specificationsController.dispose();

    super.dispose();
  }

  // ----------------------------------------------------------
  // IMAGE
  // ----------------------------------------------------------

  Future<void> _pickImage() async {
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

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      if (file.bytes == null) {
        _showMessage(
          'Unable to read selected image.',
        );
        return;
      }

      if (file.size > 1024 * 1024) {
        _showMessage(
          'Image size must be less than 1 MB.',
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _selectedImageBytes = file.bytes;
        _selectedImageName = file.name;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to select image.',
      );
    }
  }

  Future<String> _uploadImage({
    required String token,
    required int businessId,
  }) async {
    if (_selectedImageBytes == null ||
        _selectedImageName == null) {
      throw Exception(
        'Please select a product image.',
      );
    }

    setState(() {
      _uploadingImage = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$baseUrl/products/upload-image'
          '?businessId=$businessId',
        ),
      );

      request.headers['Authorization'] =
          'Bearer $token';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _selectedImageBytes!,
          filename: _selectedImageName!,
        ),
      );

      final streamedResponse =
          await request.send();

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final body = response.body.trim();

        // Backend may return JSON string/object
        try {
          final data = jsonDecode(body);

          if (data is Map<String, dynamic>) {
            final imageUrl = data['imageUrl'];

            if (imageUrl != null &&
                imageUrl.toString().trim().isNotEmpty) {
              return imageUrl.toString().trim();
            }
          }

          if (data is String &&
              data.trim().isNotEmpty) {
            return data.trim();
          }
        } catch (_) {
          // Backend returned plain text URL.
        }

        if (body.isNotEmpty) {
          return body;
        }

        throw Exception(
          'Image URL was not returned.',
        );
      }

      String message =
          'Unable to upload image.';

      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);

          if (data is Map<String, dynamic> &&
              data['message'] != null) {
            message =
                data['message'].toString();
          }
        } catch (_) {}
      }

      throw Exception(message);
    } finally {
      if (mounted) {
        setState(() {
          _uploadingImage = false;
        });
      }
    }
  }

  // ----------------------------------------------------------
  // SAVE PRODUCT
  // ----------------------------------------------------------

  Future<void> _saveProduct() async {
    final name =
        _nameController.text.trim();

    final priceText =
        _priceController.text.trim();

    final offerPriceText =
        _offerPriceController.text.trim();

    if (name.isEmpty ||
        priceText.isEmpty) {
      _showMessage(
        'Product name and price are required.',
      );
      return;
    }

    final price =
        double.tryParse(priceText);

    if (price == null || price < 0) {
      _showMessage(
        'Please enter a valid price.',
      );
      return;
    }

    double? offerPrice;

    if (offerPriceText.isNotEmpty) {
      offerPrice =
          double.tryParse(offerPriceText);

      if (offerPrice == null ||
          offerPrice < 0) {
        _showMessage(
          'Please enter a valid offer price.',
        );
        return;
      }

      if (offerPrice > price) {
        _showMessage(
          'Offer price cannot be greater than the price.',
        );
        return;
      }
    }

    // Image is mandatory only while adding.
    // During edit, existing image can be retained.
    if (!widget.isEditMode &&
        _selectedImageBytes == null) {
      _showMessage(
        'Please select a product image.',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final token =
          await _authStorageService.getToken();

      final businessId =
          await _authStorageService.getBusinessId();

      if (token == null ||
          businessId == null) {
        throw Exception(
          'Login session expired.',
        );
      }

      String? imageUrl =
          _existingImageUrl;

      // Upload only when user selected a new image.
      if (_selectedImageBytes != null) {
        imageUrl = await _uploadImage(
          token: token,
          businessId: businessId,
        );
      }

      final Map<String, dynamic> body = {
        'name': name,
        'price': price,
        'description':
            _descriptionController.text.trim(),
        'specifications':
            _specificationsController.text.trim(),
        'imageUrl': imageUrl,
        'businessId': businessId,
        'active': widget.product?.active ?? true,
      };

      if (offerPrice != null) {
        body['offerPrice'] = offerPrice;
      } else {
        body['offerPrice'] = null;
      }

      final http.Response response;

      if (widget.isEditMode) {
        // EDIT
        response = await http.put(
          Uri.parse(
            '$baseUrl/products/${widget.product!.id}',
          ),
          headers: {
            'Content-Type':
                'application/json',
            'Authorization':
                'Bearer $token',
          },
          body: jsonEncode(body),
        );
      } else {
        // ADD
        response = await http.post(
          Uri.parse('$baseUrl/products'),
          headers: {
            'Content-Type':
                'application/json',
            'Authorization':
                'Bearer $token',
          },
          body: jsonEncode(body),
        );
      }

      dynamic data;

      if (response.body.isNotEmpty) {
        try {
          data = jsonDecode(
            response.body,
          );
        } catch (_) {}
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (!mounted) return;

        _showMessage(
          widget.isEditMode
              ? 'Product updated successfully.'
              : 'Product added successfully.',
          success: true,
        );

        await Future.delayed(
          const Duration(
            milliseconds: 400,
          ),
        );

        if (!mounted) return;

        Navigator.pop(context);
        return;
      }

      String message = widget.isEditMode
          ? 'Unable to update product.'
          : 'Unable to add product.';

      if (data is Map<String, dynamic> &&
          data['message'] != null) {
        message =
            data['message'].toString();
      }

      throw Exception(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
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
  // HELPERS
  // ----------------------------------------------------------

  String? _getImageUrl(String? imageUrl) {
    if (imageUrl == null ||
        imageUrl.trim().isEmpty) {
      return null;
    }

    final value = imageUrl.trim();

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    return '$backendUrl'
        '${value.startsWith('/') ? '' : '/'}'
        '$value';
  }

  void _showMessage(
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success
            ? const Color(0xFF16A34A)
            : const Color(0xFFDC2626),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEditMode;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme:
            const IconThemeData(
          color: Color(0xFF0F172A),
        ),
        title: Text(
          isEdit
              ? 'Edit Product'
              : 'Add Product',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 700,
            ),
            child: Container(
              padding:
                  const EdgeInsets.all(26),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color:
                      const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit
                        ? 'Edit Product / Service'
                        : 'Product / Service Details',
                    style:
                        const TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    isEdit
                        ? 'Update your product information.'
                        : 'Add a product or service to your DealMate catalogue.',
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 22),

                  _label('Name *'),
                  _field(
                    controller:
                        _nameController,
                    hint:
                        'Enter product or service name',
                  ),

                  const SizedBox(height: 18),

                  _label('Price *'),
                  _field(
                    controller:
                        _priceController,
                    hint:
                        'Enter price',
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _label('Offer Price'),
                  _field(
                    controller:
                        _offerPriceController,
                    hint:
                        'Enter offer price (optional)',
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _label('Description'),
                  _field(
                    controller:
                        _descriptionController,
                    hint:
                        'Describe your product or service',
                    maxLines: 4,
                  ),

                  const SizedBox(height: 18),

                  _label('Specifications'),
                  _field(
                    controller:
                        _specificationsController,
                    hint:
                        'Add specifications or key details',
                    maxLines: 5,
                  ),

                  const SizedBox(height: 18),

                  _label(
                    isEdit
                        ? 'Product Image'
                        : 'Product Image *',
                  ),

                  const SizedBox(height: 8),

                  _imagePicker(),

                  const SizedBox(height: 28),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 50,
                    child:
                        ElevatedButton(
                      onPressed:
                          _loading
                              ? null
                              : _saveProduct,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF2563EB,
                        ),
                        foregroundColor:
                            Colors.white,
                        disabledBackgroundColor:
                            const Color(
                          0xFF93C5FD,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                      ),
                      child: _loading
                          ? Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  _uploadingImage
                                      ? 'Uploading image...'
                                      : isEdit
                                          ? 'Updating product...'
                                          : 'Adding product...',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              isEdit
                                  ? 'Save Changes'
                                  : 'Add Product',
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePicker() {
    final hasNewImage =
        _selectedImageBytes != null;

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF8FAFC),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          if (hasNewImage)
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
              child: Image.memory(
                _selectedImageBytes!,
                height: 220,
                width:
                    double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else if (_existingImageUrl != null)
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
              child:
                  Image.network(
                _existingImageUrl!,
                height: 220,
                width:
                    double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _noImage();
                },
              ),
            )
          else
            _noImage(),

          const SizedBox(height: 14),

          SizedBox(
            width:
                double.infinity,
            height: 44,
            child:
                OutlinedButton.icon(
              onPressed:
                  _loading
                      ? null
                      : _pickImage,
              icon: const Icon(
                Icons
                    .cloud_upload_outlined,
              ),
              label: Text(
                hasNewImage
                    ? 'Change Image'
                    : _existingImageUrl != null
                        ? 'Replace Image'
                        : 'Choose Image',
              ),
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(
                  0xFF2563EB,
                ),
                side:
                    const BorderSide(
                  color:
                      Color(0xFF2563EB),
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'JPG, PNG or WEBP • Maximum 1 MB',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color:
                  Color(0xFF64748B),
            ),
          ),

          if (_selectedImageName != null) ...[
            const SizedBox(height: 6),
            Text(
              _selectedImageName!,
              textAlign:
                  TextAlign.center,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color:
                    Color(0xFF334155),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _noImage() {
    return Container(
      height: 160,
      width:
          double.infinity,
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),
      child: const Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color:
                Color(0xFF94A3B8),
          ),
          SizedBox(height: 8),
          Text(
            'No image available',
            style: TextStyle(
              color:
                  Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style:
          const TextStyle(
        fontWeight:
            FontWeight.w600,
        color:
            Color(0xFF1E293B),
      ),
    );
  }

  Widget _field({
    required TextEditingController
        controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 8,
      ),
      child: TextField(
        controller:
            controller,
        keyboardType:
            keyboardType,
        maxLines:
            maxLines,
        decoration:
            InputDecoration(
          hintText: hint,
          filled: true,
          fillColor:
              const Color(
            0xFFF8FAFC,
          ),
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(0xFFE2E8F0),
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(0xFFE2E8F0),
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(0xFF2563EB),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}