class ProductModel {
  final int id;
  final String name;
  final double price;
  final double? offerPrice;
  final String? description;
  final String? specifications;
  final String? imageUrl;
  final bool active;
  final int businessId;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.offerPrice,
    this.description,
    this.specifications,
    this.imageUrl,
    required this.active,
    required this.businessId,
  });

  factory ProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      price: (json['price'] as num).toDouble(),
      offerPrice: json['offerPrice'] != null
          ? (json['offerPrice'] as num).toDouble()
          : null,
      description: json['description'],
      specifications: json['specifications'],
      imageUrl: json['imageUrl'],
      active: json['active'] ?? true,
      businessId: json['businessId'],
    );
  }
}