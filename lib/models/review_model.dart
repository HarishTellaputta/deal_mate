class ReviewModel {
  final int id;
  final String name;
  final int rating;
  final String? comment;
  final int businessId;

  ReviewModel({
    required this.id,
    required this.name,
    required this.rating,
    this.comment,
    required this.businessId,
  });

  factory ReviewModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReviewModel(
      id: json['id'],
      name: json['name'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      businessId: json['businessId'],
    );
  }
}