import 'package:flutter/foundation.dart';
import '../models/category.dart' as app_models;
import '../models/product.dart';
import '../services/airtable_service.dart';

class ProductsProvider with ChangeNotifier {
  final AirtableService _airtable = AirtableService(
    apiKey:
        'patPwU4lGwxgsp7Qz.ecd2a289c7ddd1f19428124e63237e72abe282abbb5809152b6c79f858025437',
  );
  List<app_models.Category> _categories = [];
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<app_models.Category> get categories => [..._categories];
  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load categories
      final categoriesData = await _airtable.fetchCategories();
      _categories =
          categoriesData
              .map((cat) => app_models.Category.fromAirtable(cat))
              .toList();

      // Load products
      final productsData = await _airtable.fetchProducts();
      _products =
          productsData
              .map((prod) => Product.fromAirtable(prod as Map<String, dynamic>))
              .toList();
    } catch (e) {
      _error = 'Failed to load data: ${e.toString()}';
      if (kDebugMode) print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> getProductsByCategory(String categoryId) {
    return _products.where((prod) => prod.category == categoryId).toList();
  }

  List<Product> get featuredProducts {
    return _products.take(5).toList();
  }

  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchProductById(String productId) async {}

  updateAuth(String? uid) {}

  findById(String productId) {}
}
