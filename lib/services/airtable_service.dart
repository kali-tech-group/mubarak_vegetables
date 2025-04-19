import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AirtableService {
  // Never hardcode API keys in production - use environment variables or backend service
  static const String _baseUrl =
      'https://api.airtable.com/v0/appDyzn4yowCSXkkg';
  final String _apiKey;

  // Use dependency injection for API key
  AirtableService({required String apiKey}) : _apiKey = apiKey;

  // Generic GET request helper
  Future<List<dynamic>> _getRequest(
    String endpoint, {
    Map<String, String>? params,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/$endpoint',
      ).replace(queryParameters: params);
      debugPrint('Airtable API Request: ${uri.toString()}');

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Airtable API Error: $e');
      throw Exception('Failed to fetch data: $e');
    }
  }

  // Generic POST/PATCH request helper
  Future<Map<String, dynamic>> _postPatchRequest(
    String method,
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      debugPrint('Airtable API $method Request: ${uri.toString()}');

      final response = await (method == 'POST'
              ? http.post(uri, headers: _headers, body: jsonEncode(body))
              : http.patch(uri, headers: _headers, body: jsonEncode(body)))
          .timeout(const Duration(seconds: 15));

      return _handleSingleRecordResponse(response);
    } catch (e) {
      debugPrint('Airtable API Error: $e');
      throw Exception('Failed to $method data: $e');
    }
  }

  // Headers getter
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };

  // Response handlers
  List<dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['records'] as List;
    } else {
      throw _apiException(response);
    }
  }

  Map<String, dynamic> _handleSingleRecordResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw _apiException(response);
    }
  }

  Exception _apiException(http.Response response) {
    debugPrint('Airtable API Error: ${response.statusCode} - ${response.body}');
    return Exception(
      'API Error ${response.statusCode}: ${response.reasonPhrase}',
    );
  }

  // ========== Categories ==========
  Future<List<dynamic>> fetchCategories() async {
    return _getRequest('Categories', params: {'view': 'Grid view'});
  }

  // ========== Products ==========
  Future<List<dynamic>> fetchProducts() async {
    return _getRequest('Products', params: {'view': 'Grid view'});
  }

  Future<List<dynamic>> fetchFeaturedProducts() async {
    return _getRequest(
      'Products',
      params: {
        'view': 'Grid view',
        'filterByFormula': '{Featured} = TRUE()',
        'maxRecords': '10',
      },
    );
  }

  Future<List<dynamic>> fetchProductsByCategory(String categoryId) async {
    return _getRequest(
      'Products',
      params: {'filterByFormula': '{Category} = "$categoryId"'},
    );
  }

  Future<Map<String, dynamic>> fetchProductById(String productId) async {
    final response = await _getRequest('Products/$productId');
    return response.isNotEmpty
        ? response.first
        : throw Exception('Product not found');
  }

  // ========== Orders ==========
  Future<List<dynamic>> fetchOrders() async {
    return _getRequest('Orders', params: {'view': 'Grid view'});
  }

  Future<List<dynamic>> fetchUserOrders(String userId) async {
    return _getRequest(
      'Orders',
      params: {
        'filterByFormula': '{User} = "$userId"',
        'sort[0][field]': 'Date',
        'sort[0][direction]': 'desc',
      },
    );
  }

  Future<List<dynamic>> fetchOrdersByStatus(String status) async {
    return _getRequest(
      'Orders',
      params: {'filterByFormula': '{Status} = "$status"'},
    );
  }

  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    return _postPatchRequest('POST', 'Orders', {
      "fields": {...orderData, "Date": DateTime.now().toIso8601String()},
    });
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    return _postPatchRequest('PATCH', 'Orders/$orderId', {
      "fields": {"Status": newStatus},
    });
  }

  // ========== Additional Methods ==========
  Future<List<dynamic>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    return _getRequest(
      'Products',
      params: {'filterByFormula': "SEARCH(LOWER('$query'), LOWER({Name}))"},
    );
  }

  Future<List<dynamic>> fetchDiscountedProducts() async {
    return _getRequest(
      'Products',
      params: {
        'filterByFormula': '{Discount} > 0',
        'sort[0][field]': 'Discount',
        'sort[0][direction]': 'desc',
      },
    );
  }
}
