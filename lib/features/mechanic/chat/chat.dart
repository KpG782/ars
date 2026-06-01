/// Chat Module Exports
///
/// Centralized exports for the chat module following Clean Architecture.
/// Import this file instead of individual files for cleaner code.
library;

// Domain Layer
export 'domain/models/chat_message.dart';
export 'domain/repositories/chat_repository.dart';

// Data Layer
export 'data/repositories/firebase_chat_repository.dart';
export 'data/repositories/firebase_chat_media_repository.dart';

// Presentation Layer
export 'presentation/widgets/chat_bubble.dart';
export 'presentation/widgets/chat_input_field.dart';
export 'presentation/widgets/chat_app_bar.dart';
export 'presentation/widgets/attachment_menu.dart';
export 'presentation/widgets/attachment_option.dart';
export 'presentation/widgets/service_info_banner.dart';
export 'presentation/widgets/call_dialog.dart';
export 'presentation/screens/mechanic_chat_screen.dart';

/// Usage Example:
/// ```dart
/// import 'package:arsapplication/features/mechanic/chat/chat.dart';
///
/// // Use domain models
/// final message = ChatMessage(...);
///
/// // Use repositories
/// final chatRepo = FirebaseChatRepository();
/// await chatRepo.sendMessage(...);
///
/// // Use widgets
/// ChatBubble(message: message)
/// ```
