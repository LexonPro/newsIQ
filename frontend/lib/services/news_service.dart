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

  /// Sends a request with self-healing fallback if the main backend URL fails.
  static Future<http.Response> _safeGet(String path) async {
    await _initializeUrl();
    try {
      // Attempt connection with a short 3-second timeout
      final response = await http.get(Uri.parse("$activeUrl$path")).timeout(const Duration(seconds: 3));
      return response;
    } catch (e) {
      debugPrint("Connection to $activeUrl failed: $e. Initiating self-healing network scan...");
      
      // Candidate list of all potential backend environments
      final List<String> candidates = [
        "http://127.0.0.1:8000",
        "http://localhost:8000",
        if (defaultTargetPlatform == TargetPlatform.android) "http://10.0.2.2:8000",
        defaultUrl,
      ];

      for (final candidate in candidates) {
        if (candidate == activeUrl) continue; // Skip the one we already know is failing
        try {
          debugPrint("Scanning backend candidate: $candidate...");
          final response = await http.get(Uri.parse("$candidate$path")).timeout(const Duration(seconds: 2));
          
          // Connection succeeded! Update activeUrl and cache it for future launches
          activeUrl = candidate;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("backend_url", candidate);
          debugPrint("Successfully healed network connection! Active URL: $candidate");
          return response;
        } catch (_) {
          // Continue scanning remaining candidates
        }
      }
      // If all candidates failed, rethrow the original error
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchNews({
    String category = "technology",
  }) async {
    final response = await _safeGet("/news/$category");
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchNews(
    String query,
  ) async {
    final response = await _safeGet("/search/$query");
    return jsonDecode(response.body);
  }

  /// Sends a safe POST request to the backend.
  static Future<http.Response> _safePost(String path, Map<String, dynamic> body) async {
    await _initializeUrl();
    try {
      final response = await http.post(
        Uri.parse("$activeUrl$path"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      debugPrint("Post request failed to $activeUrl$path: $e");
      rethrow;
    }
  }

  /// Fetches a 3-bullet TL;DR summary from Gemini.
  static Future<String> getTLDR(String title, String content) async {
    final res = await _safePost("/news/tldr", {"title": title, "content": content});
    return jsonDecode(res.body)["response"];
  }

  /// Fetches a child-friendly explanation from Gemini.
  static Future<String> getELI5(String title, String content) async {
    final res = await _safePost("/news/eli5", {"title": title, "content": content});
    return jsonDecode(res.body)["response"];
  }

  /// Fetches Pros/Cons impact analysis from Gemini.
  static Future<String> getImpact(String title, String content) async {
    final res = await _safePost("/news/impact", {"title": title, "content": content});
    return jsonDecode(res.body)["response"];
  }

  /// Sends the conversation thread to Gemini for dynamic article Q&A.
  static Future<String> chatAboutArticle(
    String title,
    String summary,
    List<Map<String, String>> history,
    String message,
  ) async {
    final res = await _safePost("/news/chat", {
      "title": title,
      "summary": summary,
      "history": history,
      "message": message,
    });
    return jsonDecode(res.body)["response"];
  }
}