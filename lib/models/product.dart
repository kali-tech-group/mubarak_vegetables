class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String imageUrl;
  final String description;
  final bool isOrganic;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.imageUrl,
    required this.description,
    required this.isOrganic,
    required this.stock,
  });

  factory Product.fromAirtable(Map<String, dynamic> data) {
    return Product(
      id: data['id'],
      name: data['fields']['Name'] ?? 'No Name',
      category: data['fields']['Category']?[0] ?? 'Uncategorized',
      price: (data['fields']['Price'] ?? 0).toDouble(),
      unit: data['fields']['Unit'] ?? 'per item',
      imageUrl: data['fields']['Image']?[0]['url'] ?? '',
      description: data['fields']['Description'] ?? '',
      isOrganic: data['fields']['IsOrganic'] ?? false,
      stock: data['fields']['Stock'] ?? 0,
    );
  }

  get image => null;
}
