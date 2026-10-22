import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/support_ticket_model.dart';

/// واجهة محادثة دعم فني مشتركة — تُستخدم من جهة العميل وجهة الأدمن معاً
/// بنفس التصميم (فقاعات محادثة، صاحب الرسالة الحالي يمين وبنفسجي، الطرف
/// الآخر يسار ومحايد)، لتجنّب تكرار نفس الواجهة مرتين بتفاصيل مختلفة قليلاً
class SupportThreadView extends StatefulWidget {
  final SupportTicketModel ticket;
  final SupportSenderRole currentRole;
  final String currentName;
  final Future<void> Function(String text) onSend;
  // زر إغلاق/إعادة فتح — نص الزر ودالته تختلف حسب الطرف (الأدمن يُغلق،
  // العميل يُعيد الفتح بإرسال رسالة جديدة فقط)
  final String? toggleLabel;
  final VoidCallback? onToggle;

  const SupportThreadView({
    super.key,
    required this.ticket,
    required this.currentRole,
    required this.currentName,
    required this.onSend,
    this.toggleLabel,
    this.onToggle,
  });

  @override
  State<SupportThreadView> createState() => _SupportThreadViewState();
}

class _SupportThreadViewState extends State<SupportThreadView> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SupportThreadView old) {
    super.didUpdateWidget(old);
    if (old.ticket.messages.length != widget.ticket.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  void _scrollToEnd() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _textCtrl.clear();
    try {
      await widget.onSend(text);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClosed = widget.ticket.status == SupportTicketStatus.closed;

    return Column(
      children: [
        if (isClosed)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: AppColors.textHint.withOpacity(0.12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text('هذه المحادثة مغلقة',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12.5, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(14),
            itemCount: widget.ticket.messages.length,
            itemBuilder: (_, i) => _Bubble(
              message: widget.ticket.messages[i],
              isMine: widget.ticket.messages[i].senderRole == widget.currentRole,
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Row(
              children: [
                if (widget.toggleLabel != null && widget.onToggle != null)
                  IconButton(
                    onPressed: widget.onToggle,
                    icon: Icon(
                      isClosed ? Icons.lock_open_outlined : Icons.check_circle_outline,
                      color: isClosed ? AppColors.success : AppColors.textHint,
                    ),
                    tooltip: widget.toggleLabel,
                  ),
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: isClosed && widget.currentRole == SupportSenderRole.admin
                          ? 'المحادثة مغلقة'
                          : 'اكتب رسالتك...',
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    enabled: !(isClosed && widget.currentRole == SupportSenderRole.admin),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.purple,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _sending ? null : _send,
                    child: Padding(
                      padding: const EdgeInsets.all(11),
                      child: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final SupportMessage message;
  final bool isMine;
  const _Bubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('hh:mm a');
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.purple : AppColors.surfaceLight,
          borderRadius: BorderRadius.only(
            topRight: const Radius.circular(16),
            topLeft: const Radius.circular(16),
            bottomRight: Radius.circular(isMine ? 4 : 16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.senderRole == SupportSenderRole.admin ? 'الدعم الفني' : message.senderName,
                  style: TextStyle(
                    color: isMine ? Colors.white70 : AppColors.purple,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(color: isMine ? Colors.white : AppColors.textPrimary, fontSize: 14),
            ),
            const SizedBox(height: 3),
            Text(
              df.format(message.createdAt),
              style: TextStyle(
                color: isMine ? Colors.white60 : AppColors.textHint,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
