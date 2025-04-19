class Category {
  final String id;
  final String name;
  final String imageUrl;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.color,
  });

  factory Category.fromAirtable(Map<String, dynamic> data) {
    return Category(
      id: data['id'],
      name: data['fields']['Name'] ?? 'No Name',
      imageUrl: data['fields']['Image']?[0]['url'] ?? '',
      color: data['fields']['Color'] ?? '#4CAF50',
    );
  }
}
