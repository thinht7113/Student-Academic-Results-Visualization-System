import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/student_data.dart';

class ApiService {
  static const _tokenKey = 'auth_token';

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Returns the access token on success, or an error message string prefixed with "ERR:" on failure.
  Future<String?> login(String username, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['access_token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
          return token;
        }
      }
      // Return backend error message
      return 'ERR:${data['msg'] ?? 'Đăng nhập thất bại'}';
    } catch (e) {
      return 'ERR:Lỗi kết nối: $e';
    }
  }

  Future<StudentData?> fetchStudentData() async {
    final headers = await _authHeaders();
    final token = headers['Authorization'];
    if (token == null) return null;

    final url = Uri.parse('${AppConstants.baseUrl}/api/student/data');
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return StudentData.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> chatWithAI(
    List<Map<String, String>> history, {
    Map<String, dynamic>? contextData,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/advisor/gemini');
    final headers = await _authHeaders();

    try {
      final body = {
        "messages": history,
        "use_context": contextData != null,
        "context": contextData,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? "Không nhận được phản hồi.";
      }

      // Try to parse error message from backend
      try {
        final errData = jsonDecode(response.body);
        return "Lỗi ${response.statusCode}: ${errData['msg'] ?? errData['detail'] ?? response.body}";
      } catch (_) {
        return "Lỗi ${response.statusCode}";
      }
    } catch (e) {
      return "Lỗi kết nối: $e";
    }
  }
}
