import 'package:mubarak_vegetables/models/cart_item.dart';

class Order {
  final String id;
  final double amount;
  final List<CartItem> items;
  final String address;
  final String paymentMethod;
  final String status; // pending, processing, shipped, delivered, cancelled
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? cancellationReason;

  Order({
    required this.id,
    required this.amount,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.cancellationReason,
    required Map order,
  });

  Order copyWith({
    String? status,
    DateTime? updatedAt,
    String? cancellationReason,
  }) {
    return Order(
      id: id,
      amount: amount,
      items: items,
      address: address,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      order: {},
    );
  }

  bool get canCancel => status == 'pending' || status == 'processing';
  bool get isCompleted => status == 'delivered' || status == 'cancelled';
}
