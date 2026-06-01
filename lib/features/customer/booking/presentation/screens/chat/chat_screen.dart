import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/models/mechanic.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';
import 'package:arsapplication/features/mechanic/chat/domain/models/chat_message.dart';
import 'package:arsapplication/features/mechanic/chat/domain/repositories/chat_repository.dart';
import 'package:arsapplication/features/mechanic/chat/data/repositories/firebase_chat_repository.dart';
import 'package:arsapplication/features/mechanic/chat/data/repositories/firebase_chat_media_repository.dart';

class ChatScreen extends StatefulWidget {
  final Mechanic mechanic;
  final String serviceType;

  /// Optional service request ID used to join the shared Firestore chat room.
  /// When not provided, a deterministic ID is generated from mechanicId + customerId.
  final String? serviceRequestId;

  const ChatScreen({
    super.key,
    required this.mechanic,
    required this.serviceType,
    this.serviceRequestId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isAttachmentMenuOpen = false;
  bool _isInitializing = true;

  late final ChatRepository _chatRepository;
  late final ChatMediaRepository _mediaRepository;
  String? _chatRoomId;
  StreamSubscription<List<ChatMessage>>? _messageSubscription;

  // Current customer identity from Firebase Auth
  String get _customerId => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _customerName =>
      FirebaseAuth.instance.currentUser?.displayName ??
      FirebaseAuth.instance.currentUser?.email ??
      'Customer';

  @override
  void initState() {
    super.initState();
    _chatRepository = FirebaseChatRepository();
    _mediaRepository = FirebaseChatMediaRepository();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Ensure user is authenticated before opening chat
      if (FirebaseAuth.instance.currentUser == null) {
        if (mounted) {
          setState(() => _isInitializing = false);
          ToastHelper.showError(context, 'Please log in to use chat');
          Navigator.of(context).pop();
        }
        return;
      }

      // Use provided serviceRequestId or generate a deterministic one
      final serviceRequestId =
          widget.serviceRequestId ?? '${widget.mechanic.id}_$_customerId';

      final chatRoom = await _chatRepository.getOrCreateChatRoom(
        serviceRequestId: serviceRequestId,
        mechanicId: widget.mechanic.id,
        mechanicName: widget.mechanic.name,
        customerId: _customerId,
        customerName: _customerName,
      );

      if (!mounted) return;
      setState(() {
        _chatRoomId = chatRoom.id;
        _isInitializing = false;
      });

      // Subscribe to real-time message stream
      _messageSubscription = _chatRepository.getMessages(chatRoom.id).listen((
        messages,
      ) {
        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(messages);
          });
          _scrollToBottom();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
        ToastHelper.showError(context, 'Failed to initialize chat: $e');
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatRoomId == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      await _chatRepository.sendMessage(
        chatRoomId: _chatRoomId!,
        senderId: _customerId,
        senderName: _customerName,
        content: messageText,
        isFromMechanic: false, // customer sending
      );
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Failed to send message: $e');
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_chatRoomId == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isAttachmentMenuOpen = false);

        if (mounted) ToastHelper.showInfo(context, 'Uploading image...');

        // Upload to Firebase Storage
        final uploadResult = await _mediaRepository.uploadImage(
          filePath: image.path,
          chatRoomId: _chatRoomId!,
        );

        // Send media message with the Firebase Storage URL
        await _chatRepository.sendMediaMessage(
          chatRoomId: _chatRoomId!,
          senderId: _customerId,
          senderName: _customerName,
          filePath: uploadResult.url,
          type: MessageType.image,
          isFromMechanic: false,
        );

        if (mounted) {
          ToastHelper.showSuccess(context, 'Image sent successfully');
        }
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Failed to send image: $e');
      }
    }
  }

  Future<void> _initiateVoiceCall() async {
    final phone = widget.mechanic.phoneNumber;
    if (phone != null && phone.isNotEmpty) {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } else {
      if (mounted) ToastHelper.showError(context, 'No phone number available');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mechanic.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.fontSize17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: AppTheme.fontSize13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.white),
            onPressed: _initiateVoiceCall,
            tooltip: 'Call',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Service Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.successBg,
            child: Row(
              children: [
                const Icon(Icons.build, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Service: ${widget.serviceType}',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: _isInitializing
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: TextStyle(
                        color: AppTheme.grey500,
                        fontSize: AppTheme.fontSize14,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _ChatBubble(
                        message: _messages[index],
                        currentUserId: _customerId,
                      );
                    },
                  ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Attachment menu
                if (_isAttachmentMenuOpen)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.grey50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.grey200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _AttachmentOption(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          color: AppTheme.primaryColor,
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                        _AttachmentOption(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          color: AppTheme.blue,
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ],
                    ),
                  ),

                // Input row
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isAttachmentMenuOpen
                            ? Icons.close
                            : Icons.add_circle_outline,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isAttachmentMenuOpen = !_isAttachmentMenuOpen;
                        });
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSize16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: const TextStyle(
                            fontSize: AppTheme.fontSize16,
                            color: AppTheme.grey500,
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppTheme.grey100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        onTap: () {
                          if (_isAttachmentMenuOpen) {
                            setState(() => _isAttachmentMenuOpen = false);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String currentUserId;

  const _ChatBubble({required this.message, required this.currentUserId});

  bool get _isOwnMessage => message.senderId == currentUserId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Row(
        mainAxisAlignment: _isOwnMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isOwnMessage) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: message.type == MessageType.image
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _isOwnMessage ? AppTheme.trustColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(_isOwnMessage ? 18 : 4),
                  bottomRight: Radius.circular(_isOwnMessage ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.image)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: message.mediaUrl != null
                          ? Image.network(
                              message.mediaUrl!,
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  width: 220,
                                  height: 220,
                                  color: AppTheme.grey300,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (ctx, error, stackTrace) {
                                return Container(
                                  width: 220,
                                  height: 220,
                                  color: AppTheme.grey300,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 220,
                              height: 220,
                              color: AppTheme.grey300,
                              child: const Center(
                                child: Icon(Icons.image, size: 50),
                              ),
                            ),
                    )
                  else
                    Text(
                      message.content,
                      style: TextStyle(
                        color: _isOwnMessage ? Colors.white : Colors.black87,
                        fontSize: AppTheme.fontSize15_5,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                        letterSpacing: 0.1,
                      ),
                    ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: message.type == MessageType.image
                        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                        : EdgeInsets.zero,
                    child: Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: _isOwnMessage
                            ? Colors.white.withValues(alpha: 0.75)
                            : AppTheme.grey600,
                        fontSize: AppTheme.fontSize11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isOwnMessage) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.grey300,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontSize13,
                fontWeight: FontWeight.w500,
                color: AppTheme.grey700,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
