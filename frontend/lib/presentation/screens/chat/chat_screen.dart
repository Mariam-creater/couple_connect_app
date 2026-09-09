import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../providers/app_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isVoiceRecording = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final partner = appState.partner;
    final messages = appState.messages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.accentViolet,
                  backgroundImage: partner?.avatarUrl != null ? NetworkImage(partner!.avatarUrl!) : null,
                  child: partner?.avatarUrl == null ? Text(partner?.name[0] ?? 'P', style: const TextStyle(fontWeight: FontWeight.bold)) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1E1C2B), width: 2),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partner?.name ?? 'My Partner', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(
                  'End-to-End Encrypted 🔒',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.push_pin_outlined, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // E2EE Notice Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, size: 14, color: AppTheme.accentGold),
                const SizedBox(width: 8),
                Text(
                  'Messages are encrypted with Curve25519 & AES-256',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          ),

          // Message Bubbles List
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_border_rounded, size: 48, color: AppTheme.primaryRose),
                        const SizedBox(height: 12),
                        Text('Send the first loving message!', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == appState.currentUser?.id;
                      return _buildMessageBubble(msg, isMe, appState);
                    },
                  ),
          ),

          // Message Input Bar
          _buildInputBar(appState),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe, AppState appState) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(colors: [AppTheme.primaryRose, AppTheme.primaryRoseDark])
                    : const LinearGradient(colors: [Color(0xFF262338), Color(0xFF1E1C2B)]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe ? AppTheme.primaryRose.withOpacity(0.25) : Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.type == 'voice') ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 8),
                        _buildWaveformMock(),
                        const SizedBox(width: 8),
                        const Text('0:14', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ] else ...[
                    Text(
                      msg.decryptedText ?? '[Encrypted]',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(msg.createdAt),
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          msg.status == 'read' ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 14,
                          color: msg.status == 'read' ? Colors.lightBlueAccent : Colors.white60,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Quick Reaction Pill
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 4, left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => appState.reactToMessage(msg.id, '❤️'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('❤️', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveformMock() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [4, 12, 18, 10, 22, 14, 8, 16, 20, 6].map((h) {
        return Container(
          width: 3,
          height: h.toDouble(),
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(2)),
        );
      }).toList(),
    );
  }

  Widget _buildInputBar(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161522),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file_rounded, color: Colors.white70),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type an encrypted message...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
                onSubmitted: (text) => _sendMessage(appState),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onLongPressStart: (_) => setState(() => _isVoiceRecording = true),
              onLongPressEnd: (_) => setState(() => _isVoiceRecording = false),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isVoiceRecording ? Colors.redAccent : AppTheme.primaryRose,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRose.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _textController.text.isNotEmpty ? Icons.send_rounded : Icons.mic_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => _sendMessage(appState),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(AppState appState) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    appState.sendTextMessage(text);
    _textController.clear();
  }
}
