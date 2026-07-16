import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendService {
  // Android Emulator
  // static const String baseUrl = "http://10.0.2.2:8000";

  // Real Device (same WiFi)
  // static const String baseUrl = "http://192.168.1.100:8000";

  // Windows/Desktop
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<void> startAutomation() async {
    final response = await http.post(
      Uri.parse("$baseUrl/automation/start"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Backend Automation Failed");
    }

    final json = jsonDecode(response.body);

    if (json["success"] != true) {
      throw Exception("Automation Failed");
    }
  }
}