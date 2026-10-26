import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class BackendService {
  static const String baseUrl = "https://nivaarth-backend.onrender.com";

  Map<String, String> _authHeaders() {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<void> startAutomation() async {
    debugPrint("🚀 STEP 1 : startAutomation() called");

    final url = Uri.parse("$baseUrl/automation/start");

    debugPrint("🌐 URL : $url");

    try {
      final response = await http
          .post(url, headers: _authHeaders())
          .timeout(const Duration(seconds: 10));

      debugPrint("📡 Status Code : ${response.statusCode}");
      debugPrint("📄 Response Body : ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Backend returned ${response.statusCode}: ${response.body}",
        );
      }

      final json = jsonDecode(response.body);

      debugPrint("✅ Parsed Response : $json");

      if (json["success"] != true) {
        throw Exception("Automation completed with failure.");
      }

      debugPrint("🎉 Backend automation completed");
    } on TimeoutException {
      throw Exception(
        "Server se jawab nahi aaya, thodi der baad try karo.",
      );
    } catch (e) {
      debugPrint("❌ Backend Error: $e");
      rethrow;
    }
  }

  Future<void> onboardStock({
    required String instrument,
  }) async {
    final url = Uri.parse("$baseUrl/automation/onboard-stock");
    try {
      final response = await http
          .post(
            url,
            headers: _authHeaders(),
            body: jsonEncode({
              "instrument": instrument,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Onboard stock response: ${response.statusCode}");
    } catch (e) {
      debugPrint("Onboard stock background error: $e");
    }
  }

  Future<String> chatWithAdvisor(String message) async {
    final url = Uri.parse("$baseUrl/ai/chat");
    try {
      final response = await http
          .post(
            url,
            headers: _authHeaders(),
            body: jsonEncode({
              "message": message,
            }),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "Unable to analyze response.";
      } else if (response.statusCode == 429) {
        return "Ghante ki limit poori ho gayi, thodi der baad try karo.";
      } else {
        throw Exception("Server returned ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("AI Chat Backend Error: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSmartAlerts() async {
    final uri = Uri.parse("$baseUrl/ai/alerts");
    try {
      final response = await http
          .get(uri, headers: _authHeaders())
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data["alerts"] as List?;
        if (list != null) {
          return List<Map<String, dynamic>>.from(list);
        }
      }
      return [];
    } catch (e) {
      debugPrint("Smart Alerts Backend Error: $e");
      return [];
    }
  }
}