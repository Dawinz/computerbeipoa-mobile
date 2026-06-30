import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:beipoa_mobile/config/app_config.dart';
import 'package:beipoa_mobile/models/category.dart';
import 'package:beipoa_mobile/models/product.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalized').replace(queryParameters: query);
  }

  Future<T> _get<T>(String path, T Function(dynamic json) parse, {Map<String, String>? query}) async {
    try {
      final response = await _client
          .get(_uri(path, query))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return parse(jsonDecode(response.body));
      }
      throw ApiException(
        'Request failed (${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Could not reach the server. Check your connection.');
    }
  }

  Future<PaginatedProducts> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    String? condition,
  }) {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (condition != null && condition.isNotEmpty) query['condition'] = condition;

    return _get('/products', (json) => PaginatedProducts.fromJson(json as Map<String, dynamic>), query: query);
  }

  Future<List<Product>> getFeaturedProducts() {
    return _get('/products/featured', (json) {
      return (json as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Product> getProduct(String slug) {
    return _get('/products/$slug', (json) => Product.fromJson(json as Map<String, dynamic>));
  }

  Future<List<Category>> getCategories() {
    return _get('/categories', (json) {
      return (json as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<bool> healthCheck() async {
    try {
      final response = await _client
          .get(_uri('/health'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> submitCheckout(Map<String, dynamic> body) async {
    try {
      final response = await _client
          .post(
            _uri('/orders/checkout'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));

      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded as Map<String, dynamic>;
      }

      final message = decoded is Map && decoded['message'] != null
          ? (decoded['message'] is List
              ? (decoded['message'] as List).join(', ')
              : decoded['message'].toString())
          : 'Checkout failed (${response.statusCode})';
      throw ApiException(message, statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Could not complete checkout. Check your connection.');
    }
  }
}
