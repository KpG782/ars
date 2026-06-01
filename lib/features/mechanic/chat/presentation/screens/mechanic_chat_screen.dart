import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../dashboard/domain/models/service_request.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/firebase_chat_repository.dart';
import '../../data/repositories/firebase_chat_media_repository.dart';
import '../widgets/chat_bubble.dart';

class MechanicChatScreen extends StatefulWidget {
  final ServiceRequest serviceRequest;

  const MechanicChatScreen({super.key, required this.serviceRequest});

  @override
  State<MechanicChatScreen> createState() => _MechanicChatScreenState();
}

class _MechanicChatScreenState extends State<MechanicChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isAttachmentMenuOpen = false;

  // Repository dependencies (Dependency Injection)
  late final ChatRepository _chatRepository;
  late final ChatMediaRepository _mediaRepository;
  String? _chatRoomId;

  // Current mechanic identity from Firebase Auth
  String get _mechanicId => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _mechanicName =>
      FirebaseAuth.instance.currentUser?.displayName ??
      FirebaseAuth.instance.currentUser?.email ??
      'Mechanic';

  @override
  void initState() {
    super.initState();
    // Initialize repositories (in production, use dependency injection)
    _chatRepository = FirebaseChatRepository();
    _mediaRepository = FirebaseChatMediaRepository();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Ensure mechanic is authenticated
      if (FirebaseAuth.instance.currentUser == null) {
        if (mounted) {
          ToastHelper.showError(context, 'Please log in to use chat');
        }
        return;
      }

      // Use customerId from model if available; fall back to parsing the request ID.
      final customerId = widget.serviceRequest.customerId.isNotEmpty
          ? widget.serviceRequest.customerId
          : widget.serviceRequest.id.split('_').first;

      // Deterministic serviceRequestId: matches the key generated on the customer side
      // (mechanic.id + '_' + customerId). Falls back to service request ID when the
      // customerId could not be determined.
      final serviceRequestId =
          customerId.isNotEmpty && customerId != widget.serviceRequest.id
          ? '${_mechanicId}_$customerId'
          : widget.serviceRequest.id;

      final chatRoom = await _chatRepository.getOrCreateChatRoom(
        serviceRequestId: serviceRequestId,
        mechanicId: _mechanicId,
        mechanicName: _mechanicName,
        customerId: customerId,
        customerName: widget.serviceRequest.customerName,
      );

      setState(() {
        _chatRoomId = chatRoom.id;
      });

      // Load messages as stream (real-time updates)
      _chatRepository.getMessages(chatRoom.id).listen((messages) {
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
        ToastHelper.showError(context, 'Failed to initialize chat: $e');
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatRoomId == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      // Send message using repository
      await _chatRepository.sendMessage(
        chatRoomId: _chatRoomId!,
        senderId: _mechanicId,
        senderName: _mechanicName,
        content: messageText,
        isFromMechanic: true,
      );

      // Messages will be updated automatically via stream
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

        // Show upload progress toast
        if (mounted) {
          ToastHelper.showInfo(context, 'Uploading image...');
        }

        // Upload image using media repository
        final uploadResult = await _mediaRepository.uploadImage(
          filePath: image.path,
          chatRoomId: _chatRoomId!,
          onProgress: (progress) {
            // Optional: Update progress UI
          },
        );

        // Send message with uploaded image URL
        await _chatRepository.sendMediaMessage(
          chatRoomId: _chatRoomId!,
          senderId: _mechanicId,
          senderName: _mechanicName,
          filePath: uploadResult.url,
          type: MessageType.image,
          isFromMechanic: true,
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
    final phone = widget.serviceRequest.customerPhone;
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
              child: Icon(LucideIcons.user, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.serviceRequest.customerName,
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
            color: AppTheme.trustBg,
            child: Row(
              children: [
                const Icon(LucideIcons.wrench, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Service: ${widget.serviceRequest.serviceType}',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
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
                        _buildAttachmentOption(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          color: AppTheme.primaryColor,
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                        _buildAttachmentOption(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          color: AppTheme.blue,
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ],
                    ),
                  ),

                // Input field row
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isAttachmentMenuOpen ? Icons.close : Icons.attach_file,
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
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: const TextStyle(color: AppTheme.grey400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: AppTheme.grey300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: AppTheme.grey300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onTap: () {
                          if (_isAttachmentMenuOpen) {
                            setState(() => _isAttachmentMenuOpen = false);
                          }
                        },
                        textCapitalization: TextCapitalization.sentences,
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

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
