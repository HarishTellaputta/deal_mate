class CategoryModel {
  final int id;
  final String name;
  final String type;
  final bool active;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.active,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      active: json['active'],
    );
  }
}