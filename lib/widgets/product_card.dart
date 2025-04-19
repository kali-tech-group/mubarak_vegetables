import 'package:intl/intl.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String description;
  final bool isOrganic;
  final double discount;
  final int stock;
  final double? rating;
  final double? weight;
  final DateTime? expiryDate;
  final bool isFeatured;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.isOrganic,
    this.discount = 0,
    required this.stock,
    this.rating,
    this.weight,
    this.expiryDate,
    required this.isFeatured,
    required this.createdAt,
  });

  factory Product.fromAirtable(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['Name'] ?? 'Unnamed Product',
      category: data['Category'] ?? 'Uncategorized',
      price: (data['Price'] ?? 0).toDouble(),
      imageUrl: data['Image']?[0]['url'] ?? '',
      description: data['Description'] ?? '',
      isOrganic: data['Organic'] ?? false,
      discount: (data['Discount'] ?? 0).toDouble(),
      stock: data['Stock'] ?? 0,
      rating: data['Rating']?.toDouble(),
      weight: data['Weight']?.toDouble(),
      expiryDate:
          data['ExpiryDate'] != null
              ? DateTime.parse(data['ExpiryDate'])
              : null,
      isFeatured: data['Featured'] ?? false,
      createdAt:
          data['CreatedAt'] != null
              ? DateTime.parse(data['CreatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Category': category,
      'Price': price,
      'Image': imageUrl,
      'Description': description,
      'Organic': isOrganic,
      'Discount': discount,
      'Stock': stock,
      'Rating': rating,
      'Weight': weight,
      'ExpiryDate': expiryDate?.toIso8601String(),
      'Featured': isFeatured,
    };
  }

  double get discountedPrice => price * (1 - discount);
  bool get isOutOfStock => stock <= 0;
}
