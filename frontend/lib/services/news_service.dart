import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewsService {
  static const String defaultUrl = "http://10.37.146.192:8000";
  static String activeUrl = defaultUrl;
  static bool hasInitialized = false;

  /// Dynamically loads the saved backend URL, falling back to local host addresses
  /// if the preset server is unreachable.
  static Future<void> _initializeUrl() async {
    if (hasInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? cached = prefs.getString("backend_url");
      // Discard cached URL if it references the old inactive IP
      if (cached != null && cached.contains("10.221.231.192")) {
        await prefs.remove("backend_url");
        cached = null;
      }
      activeUrl = cached ?? defaultUrl;
      hasInitialized = true;
    } catch (_) {
      activeUrl = defaultUrl;
    }
  }

  /// Sends a unified request with full self-healing fallback support for both GET and POST.
  static Future<http.Response> _sendRequest(String method, String path, {Map<String, dynamic>? body}) async {
    await _initializeUrl();
    final headers = {"Content-Type": "application/json"};
    final encodedBody = body != null ? jsonEncode(body) : null;

    try {
      final uri = Uri.parse("$activeUrl$path");
      if (method == "POST") {
        return await http.post(uri, headers: headers, body: encodedBody).timeout(const Duration(seconds: 4));
      } else {
        return await http.get(uri).timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint("HTTP request to $activeUrl$path failed: $e. Scanning candidates...");

      // Candidates list including USB port-forwards, Wi-Fi IP, and default fallback configurations
      final List<String> candidates = [
        "http://127.0.0.1:8000",
        "http://localhost:8000",
        "http://10.37.146.192:8000",
        if (defaultTargetPlatform == TargetPlatform.android) "http://10.0.2.2:8000",
        defaultUrl,
      ];

      for (final candidate in candidates) {
        if (candidate == activeUrl) continue; // Skip activeUrl since it just failed
        try {
          debugPrint("Scanning backend candidate: $candidate...");
          final candidateUri = Uri.parse("$candidate$path");
          http.Response response;
          if (method == "POST") {
            response = await http.post(candidateUri, headers: headers, body: encodedBody).timeout(const Duration(seconds: 2));
          } else {
            response = await http.get(candidateUri).timeout(const Duration(seconds: 2));
          }

          // Handshake succeeded! Update active URL and save it to storage
          activeUrl = candidate;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("backend_url", candidate);
          debugPrint("Successfully healed connection! Saved URL: $candidate");
          return response;
        } catch (_) {
          // Keep trying remaining candidates
        }
      }
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchNews({
    String category = "technology",
  }) async {
    final response = await _sendRequest("GET", "/news/$category");
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchNews(
    String query,
  ) async {
    final response = await _sendRequest("GET", "/search/$query");
    return jsonDecode(response.body);
  }

  /// Fetches a 3-bullet TL;DR summary from Gemini.
  static Future<String> getTLDR(String title, String content) async {
    final res = await _sendRequest("POST", "/news/tldr", body: {"title": title, "content": content});
    return jsonDecode(res.body)["response"];
  }

  /// Fetches a child-friendly explanation from Gemini.
  static Future<String> getELI5(String title, String content) async {
    final res = await _sendRequest("POST", "/news/eli5", body: {"title": title, "content": content});
    return jsonDecode(res.body)["response"];
  }

  /// Fetches Pros/Cons impact analysis from Gemini.
  static Future<String> getImpact(String title, String content) async {
    final res = await _sendRequest("POST", "/news/impact", body: {"title": title, "content": content});
    return jsonDecode(res.body)["response"];
  }

  /// Sends the conversation thread to Gemini for dynamic article Q&A.
  static Future<String> chatAboutArticle(
    String title,
    String summary,
    List<Map<String, String>> history,
    String message,
  ) async {
    final res = await _sendRequest("POST", "/news/chat", body: {
      "title": title,
      "summary": summary,
      "history": history,
      "message": message,
    });
    return jsonDecode(res.body)["response"];
  }
}