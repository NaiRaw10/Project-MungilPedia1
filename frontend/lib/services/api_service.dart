import 'dart:convert';
import 'package:http/http.dart' as http;
import '../postmodel.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000/api";
  static const String imageBaseUrl = "http://localhost:3000/uploads";

  // FETCH CATEGORIES
  static Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/categories"));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['data'];
    } else {
      throw Exception("Gagal mengambil data kategori");
    }
  }

  // FETCH POSTS (READ)
  static Future<List<Post>> fetchPosts({int? kategoriId}) async {
    String url = "$baseUrl/posts";
    if (kategoriId != null) {
      url = "$baseUrl/posts?kategoriId=$kategoriId";
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil daftar postingan");
    }
  }

  // CREATE POST
  static Future<bool> createPost(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/posts"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  // UPDATE POST
  static Future<bool> updatePost(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/posts/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  // DELETE POST
  static Future<bool> deletePost(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/posts/$id"));
    return response.statusCode == 200;
  }
}