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
  //patPwU4lGwxgsp7Qz.ecd2a289c7ddd1f19428124e63237e72abe282abbb5809152b6c79f858025437
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
      unit: data['fields']['Unit'] ?? '1 Kg',
      imageUrl: data['fields']['Image']?[0]['url'] ?? '',
      description: data['fields']['Description'] ?? '',
      isOrganic: data['fields']['IsOrganic'] ?? false,
      stock: data['fields']['Stock'] ?? 0,
    );
  }

  get image => null;

  static Product? empty() {}
}
