import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/support_ticket_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/support_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../support/widgets/support_thread_view.dart';

class AdminSupportTicketScreen extends ConsumerWidget {
  final String ticketId;
  const AdminSupportTicketScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('محادثة الدعم'),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
      ),
      body: StreamBuilder<SupportTicketModel?>(
        stream: SupportService.streamTicket(ticketId),
        builder: (context, snap) {
          if (!snap.hasData) return const LoadingWidget();
          final ticket = snap.data;
          if (ticket == null) {
            return EmptyState(message: 'لم تعد هذه التذكرة موجودة', icon: Icons.error_outline);
          }
          final isOpen = ticket.status == SupportTicketStatus.open;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('${ticket.customerName} · ${ticket.customerPhone}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Text(ticket.category, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: SupportThreadView(
                  ticket: ticket,
                  currentRole: SupportSenderRole.admin,
                  currentName: admin?.name ?? 'الدعم الفني',
                  onSend: (text) => SupportService.addMessage(
                    ticketId,
                    SupportMessage(
                      senderRole: SupportSenderRole.admin,
                      senderName: admin?.name ?? 'الدعم الفني',
                      text: text,
                      createdAt: DateTime.now(),
                    ),
                  ),
                  toggleLabel: isOpen ? 'إغلاق المحادثة' : 'إعادة فتح المحادثة',
                  onToggle: () => SupportService.setStatus(
                    ticketId,
                    isOpen ? SupportTicketStatus.closed : SupportTicketStatus.open,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
