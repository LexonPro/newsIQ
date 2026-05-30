import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/news_service.dart';

class DetailScreen extends StatefulWidget {
  final String title;
  final String summary;
  final String imageUrl;
  final String articleUrl;

  const DetailScreen({
    super.key,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.articleUrl,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Quick AI action states
  String? aiResultText;
  String? activeAction; // 'tldr', 'eli5', or 'impact'
  bool isAiLoading = false;

  // Q&A Chat states
  final List<Map<String, String>> chatHistory = [];
  final TextEditingController chatController = TextEditingController();
  bool isChatLoading = false;

  Future<void> openArticle() async {
    final Uri url = Uri.parse(widget.articleUrl);
    if (!await launchUrl(url)) {
      throw Exception("Could not launch article");
    }
  }

  /// Triggers a quick AI action (TL;DR, ELI5, or Impact)
  Future<void> runAiAction(String action) async {
    if (isAiLoading && activeAction == action) {
      // Toggle off if clicked while loading
      setState(() {
        activeAction = null;
        aiResultText = null;
      });
      return;
    }

    if (activeAction == action) {
      // Toggle off if already showing
      setState(() {
        activeAction = null;
        aiResultText = null;
      });
      return;
    }

    setState(() {
      activeAction = action;
      isAiLoading = true;
      aiResultText = null;
    });

    try {
      String response = "";
      final content = "${widget.title}. ${widget.summary}";
      
      if (action == 'tldr') {
        response = await NewsService.getTLDR(widget.title, content);
      } else if (action == 'eli5') {
        response = await NewsService.getELI5(widget.title, content);
      } else if (action == 'impact') {
        response = await NewsService.getImpact(widget.title, content);
      }

      setState(() {
        aiResultText = response;
        isAiLoading = false;
      });
    } catch (e) {
      setState(() {
        aiResultText = "⚠️ Unable to load AI response. Please ensure backend is running.";
        isAiLoading = false;
      });
    }
  }

  /// Sends a chat message to the backend article Q&A endpoint
  Future<void> sendChatMessage(String message, StateSetter modalSetState) async {
    if (message.trim().isEmpty) return;

    chatController.clear();
    modalSetState(() {
      chatHistory.add({"role": "user", "content": message});
      isChatLoading = true;
    });

    try {
      final response = await NewsService.chatAboutArticle(
        widget.title,
        widget.summary,
        chatHistory,
        message,
      );

      modalSetState(() {
        chatHistory.add({"role": "model", "content": response});
        isChatLoading = false;
      });
    } catch (e) {
      modalSetState(() {
        chatHistory.add({
          "role": "model",
          "content": "⚠️ Connection error. Could not connect to newsIQ AI assistant."
        });
        isChatLoading = false;
      });
    }
  }

  /// Opens the gorgeous glassmorphic bottom sheet for Live Q&A chat
  void openChatSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
            final secondaryTextColor = isDark ? Colors.grey[400] : const Color(0xFF64748B);
            final sheetBg = isDark ? Colors.grey[950]! : Colors.white;
            final borderThemeColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.06);
            final handleColor = isDark ? Colors.white24 : Colors.black26;
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                border: Border.all(color: borderThemeColor, width: 1.5),
              ),
              child: Column(
                children: [
                  // Grab handle & title
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_bubble_outline, color: Colors.red, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Chat with newsIQ AI",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Ask any questions about this article",
                              style: TextStyle(color: secondaryTextColor, fontSize: 13),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  ),
                  Divider(color: borderThemeColor, height: 1),

                  // Chat Message List
                  Expanded(
                    child: chatHistory.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome, color: isDark ? Colors.grey[800] : Colors.grey[300], size: 60),
                                  const SizedBox(height: 15),
                                  Text(
                                    "No messages yet",
                                    style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Ask things like 'Who is mentioned?' or 'What are the main consequences?'",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: chatHistory.length,
                            itemBuilder: (context, index) {
                              final msg = chatHistory[index];
                              final isUser = msg["role"] == "user";
                              return Align(
                                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUser ? Colors.red : (isDark ? Colors.grey[900] : const Color(0xFFF1F5F9)),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: Radius.circular(isUser ? 20 : 0),
                                      bottomRight: Radius.circular(isUser ? 0 : 20),
                                    ),
                                    border: isUser ? null : Border.all(color: borderThemeColor),
                                  ),
                                  child: Text(
                                    msg["content"] ?? "",
                                    style: TextStyle(
                                      color: isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Typing loader
                  if (isChatLoading)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                            ),
                            const SizedBox(width: 10),
                            Text("newsIQ is reading...", style: TextStyle(color: secondaryTextColor, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),

                  // Input bar
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      top: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: chatController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: "Type a question about the article...",
                              hintStyle: TextStyle(color: isDark ? Colors.white30 : const Color(0xFF94A3B8)),
                              fillColor: isDark ? Colors.grey[900] : const Color(0xFFF1F5F9),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: isDark ? BorderSide.none : BorderSide(color: borderThemeColor),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                            onSubmitted: (val) => sendChatMessage(val, modalSetState),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () => sendChatMessage(chatController.text, modalSetState),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF475569);
    final scaffoldBg = isDark ? Colors.black : const Color(0xFFF7F8FA);
    final cardBorder = isDark ? Colors.white10 : Colors.black.withOpacity(0.08);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        title: Text(
          "newsIQ Detail",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Header image
            Image.network(
              widget.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: isDark ? Colors.grey[900] : const Color(0xFFE2E8F0),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 50,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // ⚡ AI Action Hub Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAiChip("tldr", "⚡ TL;DR Summary"),
                      _buildAiChip("eli5", "👶 ELI5 Mode"),
                      _buildAiChip("impact", "📈 Impact Pros/Cons"),
                    ],
                  ),

                  // Expanded Dynamic AI Card
                  if (activeAction != null) ...[
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(isDark ? 0.03 : 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                activeAction == 'tldr'
                                    ? "newsIQ AI TL;DR Summary"
                                    : activeAction == 'eli5'
                                        ? "newsIQ AI Simple Explanation"
                                        : "newsIQ AI Impact Analysis",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (isAiLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(color: Colors.red),
                              ),
                            )
                          else
                            Text(
                              aiResultText ?? "",
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Divider(color: cardBorder),
                  const SizedBox(height: 15),

                  // Original Summary
                  Text(
                    widget.summary,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Primary read original button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: openArticle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Read Full Original Article",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openChatSheet,
        backgroundColor: Colors.red,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildAiChip(String action, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = activeAction == action;
    return GestureDetector(
      onTap: () => runAiAction(action),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : (isDark ? Colors.grey[900] : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.red : (isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
          ),
          boxShadow: (isSelected || isDark) ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}