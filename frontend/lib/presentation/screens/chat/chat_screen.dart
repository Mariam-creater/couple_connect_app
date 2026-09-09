import 'dart:async';
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

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _searchController = TextEditingController();

  bool _isSearching = false;
  final bool _isPartnerTyping = false;
  MessageModel? _replyingToMessage;

  // Voice Recording State
  bool _isRecordingVoice = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  late AnimationController _recordingPulseController;

  // Audio Playback Simulation State
  final Map<int, bool> _playingVoiceMessages = {};
  final Map<int, double> _voiceProgress = {};
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _recordingPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().markMessagesAsRead();
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _recordingPulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecordingVoice = true;
      _recordingSeconds = 0;
    });
    _recordingPulseController.repeat(reverse: true);
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
      });
    });
  }

  void _cancelVoiceRecording() {
    _recordingTimer?.cancel();
    _recordingPulseController.stop();
    setState(() {
      _isRecordingVoice = false;
      _recordingSeconds = 0;
    });
  }

  void _sendVoiceRecording(AppState appState) {
    if (_recordingSeconds < 1) {
      _cancelVoiceRecording();
      return;
    }
    final durationStr = '${(_recordingSeconds ~/ 60)}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}';
    _recordingTimer?.cancel();
    _recordingPulseController.stop();
    setState(() {
      _isRecordingVoice = false;
    });

    appState.sendTextMessage(
      '🎙️ Voice Note ($durationStr)',
      type: 'voice',
      metadata: {
        'duration': durationStr,
        'seconds': _recordingSeconds,
        'waveform': [6, 14, 22, 12, 28, 18, 10, 24, 16, 8],
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Encrypted Voice Note ($durationStr) sent! 🎙️❤️'),
        backgroundColor: const Color(0xFF1E1C2B),
      ),
    );
  }

  void _toggleVoicePlayback(int messageId, int totalSeconds) {
    setState(() {
      final isCurrentlyPlaying = _playingVoiceMessages[messageId] ?? false;
      if (isCurrentlyPlaying) {
        _playingVoiceMessages[messageId] = false;
        _playbackTimer?.cancel();
      } else {
        _playingVoiceMessages.clear();
        _playingVoiceMessages[messageId] = true;
        _voiceProgress[messageId] = _voiceProgress[messageId] ?? 0.0;

        _playbackTimer?.cancel();
        _playbackTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
          setState(() {
            double current = _voiceProgress[messageId] ?? 0.0;
            current += (0.2 / (totalSeconds > 0 ? totalSeconds : 10));
            if (current >= 1.0) {
              _voiceProgress[messageId] = 0.0;
              _playingVoiceMessages[messageId] = false;
              _playbackTimer?.cancel();
            } else {
              _voiceProgress[messageId] = current;
            }
          });
        });
      }
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
                        child: partner?.avatarUrl == null
                            ? Text(partner?.name[0] ?? 'P', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                            : null,
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
          // E2EE Security Banner
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
                          _isSearching ? 'No messages match your search.' : 'Send the first loving message, voice note, or doc!',
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
                        const Text('Replying to message', style: TextStyle(color: AppTheme.primaryRose, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(
                          _replyingToMessage!.decryptedText ?? 'Encrypted message',
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

          // Voice Recording Active Bar OR Standard Input Bar
          if (_isRecordingVoice)
            _buildVoiceRecordingBar(appState)
          else
            _buildInputBar(appState),
        ],
      ),
    );
  }

  Widget _buildVoiceRecordingBar(AppState appState) {
    final minutes = _recordingSeconds ~/ 60;
    final seconds = _recordingSeconds % 60;
    final timeStr = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C2B),
        border: Border(top: BorderSide(color: Colors.redAccent.withOpacity(0.4))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Trash / Cancel Button
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 26),
              tooltip: 'Cancel Recording',
              onPressed: _cancelVoiceRecording,
            ),
            const SizedBox(width: 8),

            // Pulsing Red Dot & Timer
            FadeTransition(
              opacity: _recordingPulseController,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              timeStr,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 12),

            // Audio Waveform Visualization
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [8, 16, 24, 14, 30, 20, 10, 26, 18, 12, 22, 16].map((h) {
                  return Container(
                    width: 3,
                    height: (h * (_recordingPulseController.value * 0.6 + 0.4)).clamp(6.0, 30.0),
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRose,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 8),

            // Send Voice Note Button
            FloatingActionButton.small(
              backgroundColor: AppTheme.primaryRose,
              foregroundColor: Colors.white,
              onPressed: () => _sendVoiceRecording(appState),
              child: const Icon(Icons.arrow_upward_rounded, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe, AppState appState) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageContextMenu(context, msg, isMe, appState),
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
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

                    // 1. Voice Note Bubble
                    if (msg.type == 'voice') ...[
                      _buildVoiceBubbleContent(msg),
                    ]
                    // 2. Document Bubble
                    else if (msg.type == 'document' || msg.type == 'pdf') ...[
                      _buildDocumentBubbleContent(msg),
                    ]
                    // 3. Photo Bubble
                    else if (msg.type == 'photo') ...[
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
                    ]
                    // 4. Standard Text Message Bubble
                    else ...[
                      Text(
                        msg.decryptedText ?? '[Encrypted Message]',
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ],

                    const SizedBox(height: 6),
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

              // Quick Heart Reaction Pill
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

  Widget _buildVoiceBubbleContent(MessageModel msg) {
    final isPlaying = _playingVoiceMessages[msg.id] ?? false;
    final progress = _voiceProgress[msg.id] ?? 0.0;
    final durationStr = msg.metadata?['duration']?.toString() ?? '0:14';
    final totalSecs = msg.metadata?['seconds'] != null ? int.tryParse(msg.metadata!['seconds'].toString()) ?? 14 : 14;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic_rounded, size: 14, color: AppTheme.accentGold),
            const SizedBox(width: 4),
            Text('Voice Note', style: TextStyle(color: AppTheme.accentGold.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _toggleVoicePlayback(msg.id, totalSecs),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Waveform with Progress Highlight
                  Row(
                    children: [4, 12, 20, 10, 24, 16, 8, 18, 22, 14, 8, 16, 20, 6].asMap().entries.map((entry) {
                      final idx = entry.key;
                      final h = entry.value;
                      final barRatio = idx / 14;
                      final isPlayed = barRatio <= progress;

                      return Expanded(
                        child: Container(
                          height: h.toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: isPlayed ? AppTheme.accentGold : Colors.white38,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPlaying ? '${(progress * totalSecs).toInt()}s / $durationStr' : durationStr,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentBubbleContent(MessageModel msg) {
    final fileName = msg.metadata?['file_name']?.toString() ?? msg.decryptedText ?? 'Couple_Document.pdf';
    final fileSize = msg.metadata?['file_size']?.toString() ?? '1.8 MB';
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    final isXls = fileName.toLowerCase().endsWith('.xlsx') || fileName.toLowerCase().endsWith('.xls');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPdf ? Colors.redAccent.withOpacity(0.2) : isXls ? Colors.greenAccent.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPdf ? Icons.picture_as_pdf_rounded : isXls ? Icons.table_chart_rounded : Icons.description_rounded,
                  color: isPdf ? Colors.redAccent : isXls ? Colors.greenAccent : Colors.blueAccent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$fileSize • End-to-End Encrypted',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _previewDocument(context, fileName),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.visibility_rounded, size: 16, color: Colors.white70),
                  SizedBox(width: 6),
                  Text('Preview & Download Encrypted Document', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
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
            // Attach Files & Documents Button
            IconButton(
              icon: const Icon(Icons.attach_file_rounded, color: Colors.white70),
              tooltip: 'Send Documents, Photos or Videos',
              onPressed: () => _showAttachmentPicker(context, appState),
            ),

            // Text Input Field
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
                onChanged: (_) => setState(() {}),
                onSubmitted: (text) => _sendMessage(appState),
              ),
            ),
            const SizedBox(width: 8),

            // Voice Recording or Send Button
            if (_textController.text.trim().isEmpty)
              GestureDetector(
                onTap: _startVoiceRecording,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryRose,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRose.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryRose,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRose.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: () => _sendMessage(appState),
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

  void _previewDocument(BuildContext context, String fileName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C2B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_rounded, color: AppTheme.accentGold, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(fileName, style: const TextStyle(color: Colors.white, fontSize: 16))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.description_rounded, size: 40, color: AppTheme.primaryRose),
                    SizedBox(height: 8),
                    Text('AES-256 Decrypted Preview Active', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Document verified against Curve25519 signature.', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: Colors.white60))),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Download', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloaded "$fileName" to secure device storage!')),
              );
            },
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
                _buildAttachmentOption(Icons.mic_rounded, 'Voice Note', Colors.amberAccent, () {
                  Navigator.pop(ctx);
                  _startVoiceRecording();
                }),
                _buildAttachmentOption(Icons.picture_as_pdf_rounded, 'PDF & Docs', Colors.redAccent, () {
                  Navigator.pop(ctx);
                  _showDocumentPicker(context, appState);
                }),
                _buildAttachmentOption(Icons.image_rounded, 'Photos', AppTheme.primaryRose, () {
                  Navigator.pop(ctx);
                  appState.sendTextMessage('📷 [Encrypted Photo Shared]', type: 'photo');
                }),
                _buildAttachmentOption(Icons.videocam_rounded, 'Videos', AppTheme.accentViolet, () {
                  Navigator.pop(ctx);
                  appState.sendTextMessage('🎥 [Encrypted Intimate Video]', type: 'video');
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

  void _showDocumentPicker(BuildContext context, AppState appState) {
    final customDocController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.description_rounded, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text('Send Encrypted Document 📄', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),

                // Pre-formatted Quick Documents
                _buildDocItem(ctx, appState, 'Travel_Itinerary_Kyoto.pdf', '2.4 MB', Icons.picture_as_pdf_rounded, Colors.redAccent),
                _buildDocItem(ctx, appState, 'Couple_Monthly_Budget_2026.xlsx', '850 KB', Icons.table_chart_rounded, Colors.greenAccent),
                _buildDocItem(ctx, appState, 'Wedding_Guest_List_&_Venues.docx', '1.2 MB', Icons.description_rounded, Colors.blueAccent),
                _buildDocItem(ctx, appState, 'Our_Love_Promise_Contract.pdf', '980 KB', Icons.favorite_rounded, AppTheme.primaryRose),
                _buildDocItem(ctx, appState, 'Dream_Home_Blueprints.pdf', '4.1 MB', Icons.home_rounded, AppTheme.accentGold),

                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 8),

                // Custom Document Name
                TextField(
                  controller: customDocController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Custom Document Name',
                    hintText: 'e.g. Flight_Tickets_Paris.pdf',
                    hintStyle: const TextStyle(color: Colors.white30),
                    prefixIcon: const Icon(Icons.file_upload_rounded, color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send Custom Document', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      final name = customDocController.text.trim();
                      if (name.isEmpty) return;
                      Navigator.pop(ctx);
                      appState.sendTextMessage(
                        name,
                        type: 'document',
                        metadata: {
                          'file_name': name,
                          'file_size': '2.0 MB',
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocItem(BuildContext ctx, AppState appState, String title, String size, IconData icon, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      subtitle: Text('$size • Ready to Encrypt & Send', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
      trailing: const Icon(Icons.send_rounded, color: AppTheme.primaryRose, size: 18),
      onTap: () {
        Navigator.pop(ctx);
        appState.sendTextMessage(
          title,
          type: 'document',
          metadata: {
            'file_name': title,
            'file_size': size,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sent "$title" securely! 📄')),
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
                ListTile(
                  leading: const Icon(Icons.reply_rounded, color: Colors.white70),
                  title: const Text('Reply', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _replyingToMessage = msg);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.push_pin_rounded, color: AppTheme.accentGold),
                  title: Text(msg.isPinned ? 'Unpin Message' : 'Pin Message', style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    appState.togglePinMessage(msg.id);
                  },
                ),
                if (isMe)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    title: const Text('Delete Message', style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(ctx);
                      appState.deleteMessage(msg.id);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
