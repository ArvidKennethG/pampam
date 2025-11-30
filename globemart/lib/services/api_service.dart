import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = "https://dummyjson.com";

  static Future<List<ProductModel>> getProducts() async {
    final res = await http.get(Uri.parse("$baseUrl/products"));
    final data = jsonDecode(res.body);
    return (data['products'] as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await http.get(Uri.parse("$baseUrl/products/categories"));
    final List data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<ProductModel>> getProductByCategory(String slug) async {
    final res = await http.get(
      Uri.parse("$baseUrl/products/category/${Uri.encodeComponent(slug)}"),
    );
    final data = jsonDecode(res.body);
    return (data['products'] as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }

  static Future<List<ProductModel>> searchProduct(String q) async {
    final res = await http.get(Uri.parse("$baseUrl/products/search?q=$q"));
    final data = jsonDecode(res.body);
    return (data['products'] as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }
}
