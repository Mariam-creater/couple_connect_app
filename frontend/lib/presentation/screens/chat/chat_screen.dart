import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _searchController = TextEditingController();

  bool _isVoiceRecording = false;
  bool _isSearching = false;
  bool _isPartnerTyping = false;
  MessageModel? _replyingToMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().markMessagesAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final partner = appState.partner;
    final allMessages = appState.messages;

    final filterText = _searchController.text.trim().toLowerCase();
    final messages = filterText.isEmpty
        ? allMessages
        : allMessages.where((m) => (m.decryptedText ?? '').toLowerCase().contains(filterText)).toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search encrypted messages...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.accentViolet,
                        backgroundImage: partner?.avatarUrl != null ? NetworkImage(partner!.avatarUrl!) : null,
                        child: partner?.avatarUrl == null ? Text(partner?.name[0] ?? 'P', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)) : null,
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
                        _isPartnerTyping ? 'Typing intimate thoughts...' : 'End-to-End Encrypted 🔒',
                        style: TextStyle(
                          fontSize: 11,
                          color: _isPartnerTyping ? AppTheme.accentGold : Colors.white.withOpacity(0.6),
                          fontWeight: _isPartnerTyping ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded, color: Colors.white70),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.push_pin_outlined, color: Colors.white70),
            onPressed: () => _showPinnedMessagesModal(context, appState),
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
                  'Curve25519 & AES-256-GCM hardware encryption active',
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
                        Text(
                          _isSearching ? 'No messages match your search.' : 'Send the first loving message!',
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
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

          // Replying Preview Bar
          if (_replyingToMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF1A1829),
              child: Row(
                children: [
                  const Icon(Icons.reply_rounded, color: AppTheme.primaryRose, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Replying to message', style: TextStyle(color: AppTheme.primaryRose, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(
                          _replyingToMessage!.decryptedText ?? 'Media message',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white54),
                    onPressed: () => setState(() => _replyingToMessage = null),
                  ),
                ],
              ),
            ),
          ],

          // Message Input Bar
          _buildInputBar(appState),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe, AppState appState) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageContextMenu(context, msg, isMe, appState),
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          margin: const EdgeInsets.symmetric(vertical: 5),
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
                    if (msg.isPinned) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.push_pin_rounded, color: AppTheme.accentGold, size: 12),
                          SizedBox(width: 4),
                          Text('Pinned', style: TextStyle(color: AppTheme.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],

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
                    ] else if (msg.type == 'photo') ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 140,
                          color: Colors.white10,
                          alignment: Alignment.center,
                          child: const Icon(Icons.photo_rounded, color: AppTheme.primaryRose, size: 40),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(msg.decryptedText ?? 'Photo', style: const TextStyle(color: Colors.white, fontSize: 14)),
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
              onPressed: () => _showAttachmentPicker(context, appState),
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
    setState(() => _replyingToMessage = null);
  }

  void _showMessageContextMenu(BuildContext context, MessageModel msg, bool isMe, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick emoji reaction bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['❤️', '🔥', '😍', '💋', '😂', '🥺'].map((emoji) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        appState.reactToMessage(msg.id, emoji);
                      },
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    );
                  }).toList(),
                ),
                const Divider(color: Colors.white12, height: 28),

                // Reply
                ListTile(
                  leading: const Icon(Icons.reply_rounded, color: Colors.white70),
                  title: const Text('Reply', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _replyingToMessage = msg);
                  },
                ),

                // Copy
                ListTile(
                  leading: const Icon(Icons.copy_rounded, color: Colors.white70),
                  title: const Text('Copy Text', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (msg.decryptedText != null) {
                      Clipboard.setData(ClipboardData(text: msg.decryptedText!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                    }
                  },
                ),

                // Pin / Unpin
                ListTile(
                  leading: Icon(msg.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined, color: AppTheme.accentGold),
                  title: Text(msg.isPinned ? 'Unpin Message' : 'Pin Message', style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    appState.togglePinMessage(msg.id);
                  },
                ),

                // Edit (if my message)
                if (isMe) ...[
                  ListTile(
                    leading: const Icon(Icons.edit_rounded, color: Colors.white70),
                    title: const Text('Edit Message', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showEditMessageDialog(context, msg, appState);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    title: const Text('Delete Message', style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(ctx);
                      appState.deleteMessage(msg.id);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditMessageDialog(BuildContext context, MessageModel msg, AppState appState) {
    final editController = TextEditingController(text: msg.decryptedText ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C2B),
        title: const Text('Edit Message', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: editController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
            onPressed: () {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                appState.editMessage(msg.id, newText);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPinnedMessagesModal(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final pinned = appState.pinnedMessages;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.push_pin_rounded, color: AppTheme.accentGold),
                    SizedBox(width: 8),
                    Text('Pinned Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                if (pinned.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No pinned messages yet.', style: TextStyle(color: Colors.white60))),
                  )
                else
                  ...pinned.map((m) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.favorite_rounded, color: AppTheme.primaryRose, size: 20),
                      title: Text(m.decryptedText ?? '[Encrypted]', style: const TextStyle(color: Colors.white)),
                      subtitle: Text(DateFormat('MMM d, h:mm a').format(m.createdAt), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                        onPressed: () {
                          appState.togglePinMessage(m.id);
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAttachmentPicker(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildAttachmentOption(Icons.image_rounded, 'Photos', AppTheme.primaryRose, () {
                  Navigator.pop(ctx);
                  appState.sendTextMessage('📷 [Encrypted Photo Shared]', type: 'photo');
                }),
                _buildAttachmentOption(Icons.videocam_rounded, 'Videos', AppTheme.accentViolet, () {
                  Navigator.pop(ctx);
                  appState.sendTextMessage('🎥 [Encrypted Intimate Video]', type: 'video');
                }),
                _buildAttachmentOption(Icons.description_rounded, 'Documents', Colors.blueAccent, () {
                  Navigator.pop(ctx);
                  appState.sendTextMessage('📄 [Encrypted Shared Document]', type: 'document');
                }),
                _buildAttachmentOption(Icons.gif_box_rounded, 'GIFs', Colors.orangeAccent, () {
                  Navigator.pop(ctx);
                  appState.sendTextMessage('🎬 [GIF: Sending Love & Hugs ❤️]', type: 'gif');
                }),
                _buildAttachmentOption(Icons.insert_emoticon_rounded, 'Stickers', AppTheme.accentGold, () {
                  Navigator.pop(ctx);
                  appState.sendTextMessage('✨ [Couple Animated Sticker]', type: 'sticker');
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
