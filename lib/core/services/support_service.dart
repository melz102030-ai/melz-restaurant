import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/support_ticket_model.dart';

class SupportService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _col = 'support_tickets';

  static Future<String> createTicket({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String category,
    required String message,
  }) async {
    final ref = _db.collection(_col).doc();
    final now = DateTime.now();
    final ticket = SupportTicketModel(
      id: ref.id,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      category: category,
      status: SupportTicketStatus.open,
      createdAt: now,
      updatedAt: now,
      messages: [
        SupportMessage(
          senderRole: SupportSenderRole.customer,
          senderName: customerName,
          text: message,
          createdAt: now,
        ),
      ],
    );
    await ref.set(ticket.toMap());
    return ref.id;
  }

  static Future<void> addMessage(
    String ticketId,
    SupportMessage message, {
    bool reopen = false,
  }) async {
    await _db.collection(_col).doc(ticketId).update({
      'messages': FieldValue.arrayUnion([message.toMap()]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      if (reopen) 'status': SupportTicketStatus.open.name,
    });
  }

  static Future<void> setStatus(String ticketId, SupportTicketStatus status) async {
    await _db.collection(_col).doc(ticketId).update({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  static Stream<List<SupportTicketModel>> streamMyTickets(String customerId) {
    return _db
        .collection(_col)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) {
          final tickets =
              snap.docs.map((d) => SupportTicketModel.fromMap(d.data(), d.id)).toList();
          tickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return tickets;
        });
  }

  static Stream<List<SupportTicketModel>> streamAllTickets() {
    return _db.collection(_col).snapshots().map((snap) {
      final tickets =
          snap.docs.map((d) => SupportTicketModel.fromMap(d.data(), d.id)).toList();
      // المفتوحة أولاً، ثم الأحدث تحديثاً داخل كل مجموعة
      tickets.sort((a, b) {
        if (a.status != b.status) {
          return a.status == SupportTicketStatus.open ? -1 : 1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return tickets;
    });
  }

  static Stream<SupportTicketModel?> streamTicket(String ticketId) {
    return _db.collection(_col).doc(ticketId).snapshots().map(
        (snap) => snap.exists ? SupportTicketModel.fromMap(snap.data()!, snap.id) : null);
  }
}
