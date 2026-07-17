import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendService {
  static const String baseUrl = "https://nivaarth-api.onrender.com";

  Future<void> startAutomation() async {
    print("🚀 STEP 1 : startAutomation() called");

    final url = Uri.parse("$baseUrl/automation/start");

    print("🌐 URL : $url");

    try {
      final response = await http
          .post(
            url,
            headers: const {
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 120));

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
}