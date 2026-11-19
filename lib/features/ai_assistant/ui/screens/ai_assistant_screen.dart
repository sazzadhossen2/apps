import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/common_widgets.dart';
import '../../../../utils/widgets/ktext.dart';
import '../../../../utils/widgets/net_image.dart';
import '../../../details/ui/screens/service_details_screen.dart';
import '../../../home/models/service_model.dart';
import '../../models/chat_message.dart';
import '../controller/ai_controller.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _lastCount = 0;

  static const _quickPrompts = [
    'Recommend something relaxing',
    'What is the cheapest service?',
    'Services under ৳1000',
    'How do I book?',
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty) return;
    _input.clear();
    context.read<AiController>().send(text);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiController>();
    final count = ai.messages.length + (ai.sending ? 1 : 0);
    if (count != _lastCount) {
      _lastCount = count;
      _scrollToEnd();
    }
    final side = Responsive.side(context, maxWidth: 760);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI assistant'),
        actions: [
          IconButton(tooltip: 'New chat', icon: const Icon(Icons.refresh_rounded), onPressed: ai.reset),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(side, 12, side, 12),
              children: [
                for (final m in ai.messages) _Bubble(message: m),
                if (ai.sending) const _TypingBubble(),
              ],
            ),
          ),
          if (ai.messages.length == 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: side),
                itemCount: _quickPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(_quickPrompts[i]),
                  backgroundColor: KColors.surface,
                  side: const BorderSide(color: KColors.border),
                  labelStyle: const TextStyle(color: KColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 13),
                  onPressed: () => _send(_quickPrompts[i]),
                ),
              ),
            ),
          Container(
            decoration: const BoxDecoration(color: KColors.surface, border: Border(top: BorderSide(color: KColors.border))),
            padding: EdgeInsets.fromLTRB(side, 10, side, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 500,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Ask about services, prices...',
                      counterText: '',
                      fillColor: KColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: KColors.primary, width: 1.4)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: ai.sending ? null : _send,
                  child: Opacity(
                    opacity: ai.sending ? 0.5 : 1,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: KColors.gradient)),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final m = message;
    final isUser = m.isUser;
    final bg = isUser ? KColors.primary : (m.isError ? KColors.cancelledBg : KColors.surface);
    final fg = isUser ? Colors.white : (m.isError ? KColors.danger : KColors.textPrimary);
    final maxW = MediaQuery.sizeOf(context).width * 0.8;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW > 520 ? 520 : maxW),
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: bg,
                  border: isUser ? null : Border.all(color: m.isError ? KColors.cancelledBg : KColors.border),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                ),
                child: SelectableText(m.text, style: TextStyle(color: fg, fontSize: 14.5, height: 1.4)),
              ),
              if (m.suggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final s in m.suggestions) _SuggestionCard(service: s),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.service});
  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(8),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ServiceDetailsScreen(serviceId: service.id, initial: service)),
        ),
        child: Row(
          children: [
            NetImage(url: service.image, width: 52, height: 52, radius: 10),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KText(text: service.name, fontWeight: FontWeight.w700, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  KText(text: '${Fmt.price(service.price)}  •  ${Fmt.duration(service.durationMinutes)}', fontSize: 12, color: KColors.textSecondary),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: KColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: KColors.surface, border: Border.all(color: KColors.border), borderRadius: BorderRadius.circular(18)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: KColors.primary)),
            SizedBox(width: 10),
            Text('Thinking...', style: TextStyle(color: KColors.textSecondary, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}
