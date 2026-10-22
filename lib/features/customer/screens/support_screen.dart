import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/settings_model.dart';
import '../../../core/models/support_ticket_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/support_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';

const List<String> _supportCategories = ['استفسار عام', 'مشكلة بطلب', 'شكوى', 'اقتراح'];

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم الفني'),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
      ),
      // وضع واتساب لا يحتاج أي طلب سابق — متاح دائماً. وضع التذاكر داخل
      // التطبيق يحتاج هوية (تُنشأ تلقائياً فقط بعد أول طلب فعلي)
      body: settings.isWhatsappSupportMode
          ? _WhatsappSupportView(
              settings: settings,
              userName: user?.name ?? '',
              userPhone: user?.phone ?? '',
            )
          : user == null
              ? const EmptyState(
                  message: 'اطلب مرة واحدة على الأقل أولاً حتى تقدر تفتح تذكرة دعم',
                  icon: Icons.info_outline,
                )
              : _TicketListView(userId: user.id, userName: user.name, userPhone: user.phone),
    );
  }
}

// ─── وضع واتساب: لا تذاكر داخل التطبيق، مجرد فتح محادثة مباشرة ──────────────
class _WhatsappSupportView extends StatelessWidget {
  final RestaurantSettings settings;
  final String userName;
  final String userPhone;
  const _WhatsappSupportView({required this.settings, required this.userName, required this.userPhone});

  @override
  Widget build(BuildContext context) {
    final number = settings.effectiveSupportWhatsapp.replaceAll(RegExp(r'\D'), '');
    final hasNumber = number.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientContainer(
              borderRadius: 50,
              padding: const EdgeInsets.all(22),
              child: const Icon(Icons.chat, color: Colors.white, size: 40),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text('تواصل معنا عبر واتساب',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              hasNumber
                  ? 'فريق الدعم الفني جاهز للرد عليك مباشرة عبر واتساب'
                  : 'لم يُحدَّد رقم واتساب للدعم بعد — تواصل مع المطعم من شاشة أخرى',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (hasNumber)
              AppButton(
                label: 'فتح واتساب',
                icon: Icons.chat,
                width: double.infinity,
                onPressed: () {
                  final lines = ['مرحباً، أحتاج مساعدة.'];
                  if (userName.isNotEmpty) lines.add('الاسم: $userName');
                  if (userPhone.isNotEmpty) lines.add('الجوال: $userPhone');
                  final text = Uri.encodeComponent(lines.join('\n'));
                  launchUrl(Uri.parse('https://wa.me/$number?text=$text'), mode: LaunchMode.externalApplication);
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─── وضع التذاكر داخل التطبيق ────────────────────────────────────────────────
class _TicketListView extends StatelessWidget {
  final String userId;
  final String userName;
  final String userPhone;
  const _TicketListView({required this.userId, required this.userName, required this.userPhone});

  void _openNewTicketSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewTicketSheet(userId: userId, userName: userName, userPhone: userPhone),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewTicketSheet(context),
        backgroundColor: AppColors.purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('تذكرة جديدة', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<SupportTicketModel>>(
        stream: SupportService.streamMyTickets(userId),
        builder: (context, snap) {
          if (!snap.hasData) return const LoadingWidget(message: 'جاري التحميل...');
          final tickets = snap.data!;
          if (tickets.isEmpty) {
            return EmptyState(
              message: 'لا توجد طلبات دعم سابقة\nاضغط + لإنشاء طلب جديد',
              icon: Icons.support_agent_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            itemCount: tickets.length,
            itemBuilder: (_, i) => _TicketTile(ticket: tickets[i]),
          );
        },
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  final SupportTicketModel ticket;
  const _TicketTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isOpen = ticket.status == SupportTicketStatus.open;
    final last = ticket.lastMessage;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isOpen ? AppColors.purple : AppColors.textHint).withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: () => context.push('/support/${ticket.id}'),
        leading: CircleAvatar(
          backgroundColor: (isOpen ? AppColors.purple : AppColors.textHint).withOpacity(0.12),
          child: Icon(Icons.support_agent, color: isOpen ? AppColors.purple : AppColors.textHint),
        ),
        title: Text(ticket.category,
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          last?.text ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.textHint, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: (isOpen ? AppColors.success : AppColors.textHint).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(ticket.status.label,
                  style: TextStyle(
                      color: isOpen ? AppColors.success : AppColors.textHint,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            Text(DateFormat('dd/MM hh:mm a').format(ticket.updatedAt),
                style: TextStyle(color: AppColors.textHint, fontSize: 9.5)),
          ],
        ),
      ),
    );
  }
}

class _NewTicketSheet extends StatefulWidget {
  final String userId;
  final String userName;
  final String userPhone;
  const _NewTicketSheet({required this.userId, required this.userName, required this.userPhone});

  @override
  State<_NewTicketSheet> createState() => _NewTicketSheetState();
}

class _NewTicketSheetState extends State<_NewTicketSheet> {
  String _category = _supportCategories.first;
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      final id = await SupportService.createTicket(
        customerId: widget.userId,
        customerName: widget.userName,
        customerPhone: widget.userPhone,
        category: _category,
        message: text,
      );
      if (mounted) {
        Navigator.pop(context);
        context.push('/support/$id');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('طلب دعم جديد',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 16),
            Text('نوع الطلب', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _supportCategories.map((c) {
                final selected = c == _category;
                return ChoiceChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = c),
                  selectedColor: AppColors.purple,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontSize: 12.5),
                  backgroundColor: AppColors.surfaceLight,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _msgCtrl,
              maxLines: 4,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'اشرح مشكلتك أو استفسارك بالتفصيل...',
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 18),
            AppButton(
              label: 'إرسال',
              icon: Icons.send,
              isLoading: _sending,
              width: double.infinity,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
