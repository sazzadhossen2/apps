import 'package:flutter/foundation.dart';


import '../../../../core/services/api_service/api_services.dart';
import '../../../../core/services/network/network_response.dart';
import '../../../home/models/service_model.dart';
import '../../models/chat_message.dart';

class AiController extends ChangeNotifier {
  final ApiServices _api = ApiServices.instance;

  static const ChatMessage _welcome = ChatMessage(
    text: 'Hi! I\'m your service assistant. Ask me about our services, prices, or tell me what you need and I\'ll recommend the best match.',
    isUser: false,
    isWelcome: true,
  );

  final List<ChatMessage> messages = [_welcome];
  bool sending = false;

  Future<void> send(String text) async {
    final msg = text.trim();
    if (msg.isEmpty || sending) return;

    final history = messages
        .where((m) => !m.isWelcome && !m.isError)
        .map((m) => <String, String>{'role': m.isUser ? 'user' : 'assistant', 'text': m.text})
        .toList();
    final trimmed = history.length > 8 ? history.sublist(history.length - 8) : history;

    messages.add(ChatMessage(text: msg, isUser: true));
    sending = true;
    notifyListeners();

    final NetworkResponse res = await _api.aiChat(msg, trimmed);

    if (res.isSuccess) {
      final data = res.dataMap;
      final suggestions = res
          .listOf('suggestions')
          .map(ServiceModel.fromJson)
          .toList();
      messages.add(ChatMessage(
        text: (data['reply'] ?? 'Sorry, I could not find an answer.').toString(),
        isUser: false,
        suggestions: suggestions,
      ));
    } else {
      messages.add(ChatMessage(text: res.errorMessage, isUser: false, isError: true));
    }
    sending = false;
    notifyListeners();
  }

  void reset() {
    messages
      ..clear()
      ..add(_welcome);
    sending = false;
    notifyListeners();
  }
}
