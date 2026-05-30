import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/news_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Config states
  String backendUrl = NewsService.activeUrl;
  final TextEditingController urlController = TextEditingController();
  
  // Customization states
  String selectedDensity = "Comfortable";
  String selectedAiTone = "Professional";
  
  // Preferences states
  Map<String, bool> favoriteCategories = {
    "technology": true,
    "sports": false,
    "business": true,
    "health": false,
    "science": false,
    "entertainment": false,
  };

  @override
  void initState() {
    super.initState();
    urlController.text = backendUrl;
    loadPreferences();
  }

  /// Loads saved customizations from SharedPreferences
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        selectedDensity = prefs.getString("card_density") ?? "Comfortable";
        selectedAiTone = prefs.getString("ai_tone") ?? "Professional";
        
        // Load favorite categories
        for (final category in favoriteCategories.keys) {
          favoriteCategories[category] = prefs.getBool("cat_$category") ?? (category == "technology" || category == "business");
        }
      });
    } catch (_) {}
  }

  /// Saves a preference string to SharedPreferences
  Future<void> savePref(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {}
  }

  /// Toggles a favorite category preference
  Future<void> toggleCategory(String category) async {
    setState(() {
      favoriteCategories[category] = !favoriteCategories[category]!;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("cat_$category", favoriteCategories[category]!);
    } catch (_) {}
  }

  /// Clears the cached dynamic backend URL
  Future<void> clearNetworkCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("backend_url");
      NewsService.hasInitialized = false;
      NewsService.activeUrl = NewsService.defaultUrl;
      
      setState(() {
        backendUrl = NewsService.defaultUrl;
        urlController.text = NewsService.defaultUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Network cache cleared! Auto-scan active on next reload."),
        ),
      );
    } catch (_) {}
  }

  /// Saves a custom backend URL typed by the user
  Future<void> saveCustomUrl() async {
    String input = urlController.text.trim();
    if (input.isEmpty) return;
    
    // Auto-append protocol if missing
    if (!input.startsWith("http://") && !input.startsWith("https://")) {
      input = "http://$input";
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("backend_url", input);
      NewsService.activeUrl = input;
      NewsService.hasInitialized = true;
      
      setState(() {
        backendUrl = input;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[800],
          content: Text("Custom backend URL saved: $input"),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "newsIQ Control Center",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Greeting header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.withOpacity(0.15), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.redAccent, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome to newsIQ",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your Personalized AI Newsfeed",
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 🤖 SECTION: AI CUSTOMIZATION
            _buildSectionHeader("🤖 AI CUSTOMIZATION"),
            const SizedBox(height: 12),
            _buildSettingCard(
              child: Column(
                children: [
                  _buildDropdownRow(
                    label: "AI Summarization Persona",
                    description: "Customize summary tone & depth",
                    value: selectedAiTone,
                    items: ["Professional", "Factual", "Humorous", "Bullish", "ELI5"],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedAiTone = val);
                        savePref("ai_tone", val);
                      }
                    },
                  ),
                  const Divider(color: Colors.white10, height: 25),
                  _buildDropdownRow(
                    label: "Reader Density",
                    description: "Feed layout sizing & cards spacing",
                    value: selectedDensity,
                    items: ["Comfortable", "Magazine", "Compact"],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedDensity = val);
                        savePref("card_density", val);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 📁 SECTION: FAVORITE FEEDS
            _buildSectionHeader("📁 PREFERRED CATEGORIES"),
            const SizedBox(height: 12),
            _buildSettingCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 10,
                children: favoriteCategories.keys.map((cat) {
                  final isFav = favoriteCategories[cat]!;
                  return FilterChip(
                    label: Text(cat.toUpperCase()),
                    selected: isFav,
                    selectedColor: Colors.red,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.grey[900],
                    labelStyle: TextStyle(
                      color: isFav ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (_) => toggleCategory(cat),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 25),

            // 📡 SECTION: NETWORK CONFIGURATION
            _buildSectionHeader("📡 NETWORK & TUNNEL CONTROLS"),
            const SizedBox(height: 12),
            _buildSettingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Active API Server IP",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Current active dynamic tunnel address",
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.withOpacity(0.2)),
                        ),
                        child: const Text("CONNECTED", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: urlController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            fillColor: Colors.black,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: saveCustomUrl,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: clearNetworkCache,
                      icon: const Icon(Icons.refresh, color: Colors.red, size: 18),
                      label: const Text("Wipe Cache & Re-Scan Tunnels", style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Footer / System version
            Center(
              child: Column(
                children: [
                  Text("newsIQ for Mobile/Desktop", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("v1.0.0 • Connected to Gemini API", style: TextStyle(color: Colors.grey[750], fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String description,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}