import 'package:flutter/material.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;

  const CartItem({
    super.key,
    required this.id,
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    required productName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: FittedBox(child: Text('\₹$price')),
          ),
        ),
        title: Text(title),
        subtitle: Text('Total: ₹${(price * quantity).toStringAsFixed(2)}'),
        trailing: Text('$quantity x'),
      ),
    );
  }

  // toMap method to convert CartItem to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'quantity': quantity,
      'price': price,
    };
  }
}
