import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item.dart';
import '../models/order.dart' as app_models;

class OrdersProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<app_models.Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<app_models.Order> get orders => [..._orders];
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> fetchOrders({int limit = 10}) async {
    try {
      _clearError();
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final snapshot =
          await _firestore
              .collection('orders')
              .where('userId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get();

      _orders =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return app_models.Order(
              id: doc.id,
              amount: (data['amount'] as num).toDouble(),
              items:
                  List<Map<String, dynamic>>.from(data['items'] ?? []).map((
                    item,
                  ) {
                    return CartItem(
                      id: item['id'] ?? '',
                      productId: item['productId'] ?? '',
                      title: item['title'] ?? '',
                      quantity: item['quantity'] ?? 0,
                      price: (item['price'] as num).toDouble(),
                      productName: item['productName'] ?? 'Unknown Product',
                      imageUrl: item['imageUrl'] ?? '', // Added imageUrl
                    );
                  }).toList(),
              address: data['address'] ?? '',
              paymentMethod: data['paymentMethod'] ?? 'cod',
              status: data['status'] ?? 'pending',
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
              cancellationReason: data['cancellationReason'],
              order: {},
            );
          }).toList();
    } catch (error) {
      _error = 'Failed to fetch orders: ${error.toString()}';
      if (kDebugMode) print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addOrder(
    List<CartItem> list, {
    required List<CartItem> items,
    required double amount,
    required String address,
    required String paymentMethod,
    required String orderId,
    required String status,
    required String deliveryTime,
  }) async {
    try {
      _clearError();
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final orderRef = _firestore.collection('orders').doc();

      final orderData = {
        'userId': user.uid,
        'amount': amount,
        'items': items.map((item) => item.toMap()).toList(),
        'address': address,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await orderRef.set(orderData);

      _orders.insert(
        0,
        app_models.Order(
          id: orderRef.id,
          amount: amount,
          items: items,
          address: address,
          paymentMethod: paymentMethod,
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          order: {},
        ),
      );

      return orderRef.id;
    } catch (error) {
      _error = 'Failed to place order: ${error.toString()}';
      if (kDebugMode) print(_error);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? cancellationReason,
  }) async {
    try {
      _clearError();
      _isLoading = true;
      notifyListeners();

      final updateData = {
        'status': newStatus,
        'updatedAt': Timestamp.now(),
        if (cancellationReason != null)
          'cancellationReason': cancellationReason,
      };

      await _firestore.collection('orders').doc(orderId).update(updateData);

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
          cancellationReason: cancellationReason,
        );
      }

      return true;
    } catch (error) {
      _error = 'Failed to update order: ${error.toString()}';
      if (kDebugMode) print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  app_models.Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }

  Stream<List<app_models.Order>> get ordersStream {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return app_models.Order(
              id: doc.id,
              amount: (data['amount'] as num).toDouble(),
              items:
                  List<Map<String, dynamic>>.from(data['items'] ?? []).map((
                    item,
                  ) {
                    return CartItem(
                      id: item['id'] ?? '',
                      productId: item['productId'] ?? '',
                      title: item['title'] ?? '',
                      quantity: item['quantity'] ?? 0,
                      price: (item['price'] as num).toDouble(),
                      productName: item['productName'] ?? 'Unknown Product',
                      imageUrl: item['imageUrl'] ?? '', // Added imageUrl
                    );
                  }).toList(),
              address: data['address'] ?? '',
              paymentMethod: data['paymentMethod'] ?? 'cod',
              status: data['status'] ?? 'pending',
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
              cancellationReason: data['cancellationReason'],
              order: {},
            );
          }).toList();
        });
  }

  void updateAuth(String? uid) {
    // Handle user authentication update logic if necessary
  }
}
