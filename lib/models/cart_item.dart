class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String productId;
  final String productName;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.productId,
    required this.productName,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      title: map['title'],
      price: map['price'],
      quantity: map['quantity'],
      productId: map['productId'],
      productName: map['productName'],
      imageUrl: map['imageUrl'],
    );
  }
}
