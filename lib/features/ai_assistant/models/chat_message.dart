
import '../../home/models/service_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final bool isWelcome;
  final List<ServiceModel> suggestions;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.isWelcome = false,
    this.suggestions = const [],
  });
}
