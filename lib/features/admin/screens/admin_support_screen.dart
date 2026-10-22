import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/support_ticket_model.dart';
import '../../../core/services/support_service.dart';
import '../../../shared/widgets/loading_widget.dart';

class AdminSupportScreen extends StatelessWidget {
  const AdminSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الدعم الفني')),
      body: StreamBuilder<List<SupportTicketModel>>(
        stream: SupportService.streamAllTickets(),
        builder: (context, snap) {
          if (!snap.hasData) return const LoadingWidget(message: 'جاري التحميل...');
          final tickets = snap.data!;
          if (tickets.isEmpty) {
            return EmptyState(message: 'لا توجد طلبات دعم من العملاء حتى الآن', icon: Icons.support_agent_outlined);
          }
          final open = tickets.where((t) => t.status == SupportTicketStatus.open).toList();
          final closed = tickets.where((t) => t.status == SupportTicketStatus.closed).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            children: [
              if (open.isNotEmpty) ...[
                _SectionLabel(title: 'مفتوحة', count: open.length, color: AppColors.success),
                ...open.map((t) => _TicketCard(ticket: t)),
              ],
              if (closed.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SectionLabel(title: 'مغلقة', count: closed.length, color: AppColors.textHint),
                ...closed.map((t) => _TicketCard(ticket: t)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  const _SectionLabel({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 6),
          Text('($count)', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicketModel ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isOpen = ticket.status == SupportTicketStatus.open;
    final last = ticket.lastMessage;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isOpen ? AppColors.purple : AppColors.textHint).withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: () => context.push('/admin/support/${ticket.id}'),
        leading: CircleAvatar(
          backgroundColor: (isOpen ? AppColors.purple : AppColors.textHint).withOpacity(0.12),
          child: Icon(Icons.person_outline, color: isOpen ? AppColors.purple : AppColors.textHint),
        ),
        title: Text('${ticket.customerName} · ${ticket.category}',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13.5)),
        subtitle: Text(
          last?.text ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.textHint, fontSize: 12),
        ),
        trailing: Text(DateFormat('dd/MM hh:mm a').format(ticket.updatedAt),
            style: TextStyle(color: AppColors.textHint, fontSize: 9.5)),
      ),
    );
  }
}
