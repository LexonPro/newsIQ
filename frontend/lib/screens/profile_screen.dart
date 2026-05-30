import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/news_service.dart';
import '../main.dart'; // Access global themeNotifier

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

  /// Toggle and persist active system themeMode
  Future<void> updateThemeMode(ThemeMode mode) async {
    themeNotifier.value = mode;
    setState(() {});
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("theme_light", mode == ThemeMode.light);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.grey[500]! : const Color(0xFF64748B);
    final cardBorder = isDark ? Colors.white12 : Colors.black.withOpacity(0.06);
    final cardDivider = isDark ? Colors.white10 : Colors.black.withOpacity(0.08);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          "newsIQ Control Center",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FA),
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
                border: Border.all(color: cardBorder),
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
                      Text(
                        "Welcome to newsIQ",
                        style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your Personalized AI Newsfeed",
                        style: TextStyle(color: secondaryTextColor, fontSize: 13),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 🎨 SECTION: SYSTEM THEME DESIGN
            _buildSectionHeader("🎨 SYSTEM THEME DESIGN"),
            const SizedBox(height: 12),
            _buildSettingCard(
              child: _buildThemeToggleRow(textColor, secondaryTextColor, isDark),
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
                  Divider(color: cardDivider, height: 25),
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
                    backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                    labelStyle: TextStyle(
                      color: isFav ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
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
                          Text(
                            "Active API Server IP",
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Current active dynamic tunnel address",
                            style: TextStyle(color: secondaryTextColor, fontSize: 12),
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
                          style: TextStyle(color: textColor, fontSize: 14),
                          decoration: InputDecoration(
                            fillColor: isDark ? Colors.black : const Color(0xFFF1F5F9),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: cardBorder),
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
                        child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Divider(color: cardDivider, height: 30),
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
                  Text("newsIQ for Mobile/Desktop", style: TextStyle(color: isDark ? Colors.grey[600] : const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("v1.0.0 • Connected to Gemini API", style: TextStyle(color: isDark ? Colors.grey[800] : const Color(0xFFCBD5E1), fontSize: 11)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06)),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildThemeToggleRow(Color textColor, Color secondaryTextColor, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Display Theme",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                isDark ? "Comfortable dark look (Default)" : "Crisp bright look for daylight reading",
                style: TextStyle(color: secondaryTextColor, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => updateThemeMode(ThemeMode.dark),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.dark_mode, size: 16, color: isDark ? Colors.white : Colors.black54),
                      const SizedBox(width: 4),
                      Text("Dark", style: TextStyle(color: isDark ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => updateThemeMode(ThemeMode.light),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: !isDark ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.light_mode, size: 16, color: !isDark ? Colors.white : Colors.white70),
                      const SizedBox(width: 4),
                      Text("Light", style: TextStyle(color: !isDark ? Colors.white : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String description,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.grey[500] : const Color(0xFF64748B);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: secondaryTextColor, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: isDark ? Colors.black : Colors.white,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
              icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black54),
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