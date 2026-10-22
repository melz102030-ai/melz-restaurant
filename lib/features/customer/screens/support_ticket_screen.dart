import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/support_ticket_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/support_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../support/widgets/support_thread_view.dart';

class SupportTicketScreen extends ConsumerWidget {
  final String ticketId;
  const SupportTicketScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
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
            return EmptyState(message: 'لم يعد هذا الطلب موجوداً', icon: Icons.error_outline);
          }
          final isClosed = ticket.status == SupportTicketStatus.closed;
          return SupportThreadView(
            ticket: ticket,
            currentRole: SupportSenderRole.customer,
            currentName: user?.name ?? ticket.customerName,
            onSend: (text) => SupportService.addMessage(
              ticketId,
              SupportMessage(
                senderRole: SupportSenderRole.customer,
                senderName: user?.name ?? ticket.customerName,
                text: text,
                createdAt: DateTime.now(),
              ),
              reopen: isClosed,
            ),
          );
        },
      ),
    );
  }
}
