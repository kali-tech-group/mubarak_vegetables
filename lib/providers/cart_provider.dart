import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  get itemCount => null;

  void addItem(
    String productId,
    String title,
    double price,
    String imageUrl,
    int quantity,
    String productName,
  ) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          quantity: existing.quantity + quantity,
          productId: existing.productId,
          productName: existing.productName,
          imageUrl: existing.imageUrl,
        ),
      );
    } else {
      _items[productId] = CartItem(
        id: DateTime.now().toString(),
        title: title,
        price: price,
        quantity: quantity,
        productId: productId,
        productName: productName,
        imageUrl: imageUrl,
      );
    }
    _saveCartToPrefs();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _saveCartToPrefs();
    notifyListeners();
  }

  void clear() {
    _items = {};
    _saveCartToPrefs();
    notifyListeners();
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartList = _items.map((key, item) => MapEntry(key, item.toMap()));
    await prefs.setString('cart', json.encode(cartList));
  }

  Future<void> loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('cart')) return;

    final extracted =
        json.decode(prefs.getString('cart')!) as Map<String, dynamic>;
    final loadedItems = extracted.map(
      (key, item) =>
          MapEntry(key, CartItem.fromMap(Map<String, dynamic>.from(item))),
    );

    _items = loadedItems;
    notifyListeners();
  }

  loadCartItems() {}

  void clearCart() {}
}
