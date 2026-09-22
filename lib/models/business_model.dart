
class BusinessModel {
  final int id;
  final String name;
  final String? mobile;
  final String? whatsapp;
  final String location;
  final String? address;
  final String? description;
  final String? imageUrl;
  final bool paid;
  final bool active;
  final int categoryId;
  final String categoryName;
  final bool showMobile;
  final bool showWhatsapp;

  BusinessModel({
    required this.id,
    required this.name,
    this.mobile,
    this.whatsapp,
    required this.location,
    this.address,
    this.description,
    this.imageUrl,
    required this.paid,
    required this.active,
    required this.categoryId,
    required this.categoryName,
    required this.showMobile,
    required this.showWhatsapp,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      whatsapp: json['whatsapp'],
      location: json['location'],
      address: json['address'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      paid: json['paid'] ?? false,
      active: json['active'] ?? true,
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      showMobile: json['showMobile'] ?? false,
      showWhatsapp: json['showWhatsapp'] ?? false,
    );
  }
}

