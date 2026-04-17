import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import 'relationship_hub_page.dart';

class PartnerChatPage extends StatefulWidget {
  const PartnerChatPage();

  @override
  State<PartnerChatPage> createState() => PartnerChatPageState();
}


class PartnerChatPageState extends State<PartnerChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final List<String> _messages = [
    "Hey, what did the AI say about us today? 😂"
  ];

  void _showWhatsAppExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sync WhatsApp Chat', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Export your chat from WhatsApp (without media) and upload the .txt file here to get real-time AI relationship insights based on your conversation history.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
             onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Working: WhatsApp sync analyzing...')));
             },
             style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
             child: const Text('Upload .txt export', style: TextStyle(color: Colors.white)),
          )
        ]
      )
    );
  }

  void _send() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
       _messages.add(_msgController.text.trim());
       _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
           backgroundColor: AppColors.surface,
           elevation: 0,
           iconTheme: const IconThemeData(color: AppColors.textPrimary),
           title: const Row(
             children: [
                CircleAvatar(
                   backgroundColor: Color(0xFFDEA080),
                   radius: 16,
                   child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
                SizedBox(width: 8),
                Text('Emily & You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
             ]
           ),
           actions: [
             IconButton(
               icon: const Icon(Icons.psychology_rounded, color: AppColors.primary),
               tooltip: 'Ask AI',
               onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI is analyzing your tone...')));
               },
             ),
             PopupMenuButton<String>(
               icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
               color: AppColors.elevated,
               itemBuilder: (context) => [
                 const PopupMenuItem(
                   value: 'export',
                   child: Text('Sync from WhatsApp', style: TextStyle(color: AppColors.textPrimary)),
                 ),
                 const PopupMenuItem(
                   value: 'hub',
                   child: Text('Relationship Hub', style: TextStyle(color: AppColors.textPrimary)),
                 ),
               ],
               onSelected: (val) {
                 if (val == 'export') {
                    _showWhatsAppExportDialog();
                 } else if (val == 'hub') {
                    Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (context, anim1, anim2) => const RelationshipHubPage(),
                      transitionsBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child),
                      transitionDuration: const Duration(milliseconds: 300),
                    ));
                 }
               }
             )
           ]
        ),
        body: Column(
          children: [
             Expanded(
               child: ListView.builder(
                 padding: const EdgeInsets.all(16),
                 itemCount: _messages.length,
                 itemBuilder: (context, i) {
                    final isMe = i > 0;
                    return Align(
                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                       child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                             color: isMe ? AppColors.primary : AppColors.elevated,
                             borderRadius: BorderRadius.circular(16).copyWith(
                                bottomRight: isMe ? const Radius.circular(4) : null,
                                bottomLeft: isMe ? null : const Radius.circular(4),
                             )
                          ),
                          child: Text(_messages[i], style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary)),
                       )
                    );
                 }
               )
             ),
             Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12).copyWith(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.secondary.withValues(alpha: 0.1))),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                       IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.textSecondary),
                          onPressed: () {},
                       ),
                       Expanded(
                          child: TextField(
                             controller: _msgController,
                             style: const TextStyle(color: AppColors.textPrimary),
                             decoration: InputDecoration(
                                hintText: 'Message...',
                                hintStyle: const TextStyle(color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.elevated,
                                border: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(24),
                                   borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                             ),
                             onSubmitted: (_) => _send(),
                          )
                       ),
                       const SizedBox(width: 4),
                       Container(
                         decoration: const BoxDecoration(
                           color: AppColors.primary,
                           shape: BoxShape.circle,
                         ),
                         child: IconButton(
                            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            onPressed: _send,
                         ),
                       ),
                    ]
                  ),
                )
             )
          ]
        )
      );
  }
}

// ─────────────────────────────────────────────
// Relationship Hub Page
// ─────────────────────────────────────────────

