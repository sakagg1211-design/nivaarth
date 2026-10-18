import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendService {
  static const String baseUrl = "https://nivaarth-backend.onrender.com";

  Future<void> startAutomation() async {
    print("🚀 STEP 1 : startAutomation() called");

    final url = Uri.parse("$baseUrl/automation/start");

    print("🌐 URL : $url");

    try {
      final response = await http
          .post(url)
          .timeout(const Duration(seconds: 10));

      print("📡 Status Code : ${response.statusCode}");
      print("📄 Response Body : ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Backend returned ${response.statusCode}: ${response.body}",
        );
      }

      final json = jsonDecode(response.body);

      print("✅ Parsed Response : $json");

      if (json["success"] != true) {
        throw Exception("Automation completed with failure.");
      }

      print("🎉 Backend automation completed");
    } on TimeoutException {
      throw Exception(
        "Backend request timed out. Render may be waking up or automation is taking longer than expected.",
      );
    } catch (e) {
      print("❌ Backend Error: $e");
      rethrow;
    }
  }

  Future<void> onboardStock({
    required String instrument,
    String? yahooSymbol,
  }) async {
    final url = Uri.parse("$baseUrl/automation/onboard-stock");
    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "instrument": instrument,
              "yahoo_symbol": yahooSymbol,
              "sync": true,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print("Onboard stock response: ${response.statusCode}");
    } catch (e) {
      print("Onboard stock background error: $e");
    }
  }

  Future<String> chatWithAdvisor(String message, {String? userId}) async {
    final url = Uri.parse("$baseUrl/ai/chat");
    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "message": message,
              "user_id": userId,
            }),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "Unable to analyze response.";
      } else {
        throw Exception("Server returned ${response.statusCode}");
      }
    } catch (e) {
      print("AI Chat Backend Error: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSmartAlerts({String? userId}) async {
    final uri = Uri.parse("$baseUrl/ai/alerts${userId != null ? '?user_id=$userId' : ''}");
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data["alerts"] as List?;
        if (list != null) {
          return List<Map<String, dynamic>>.from(list);
        }
      }
      return [];
    } catch (e) {
      print("Smart Alerts Backend Error: $e");
      return [];
    }
  }
}