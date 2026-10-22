import 'package:cloud_firestore/cloud_firestore.dart';

enum SupportTicketStatus { open, closed }

extension SupportTicketStatusExt on SupportTicketStatus {
  String get label => this == SupportTicketStatus.open ? 'مفتوحة' : 'مغلقة';
}

enum SupportSenderRole { customer, admin }

class SupportMessage {
  final SupportSenderRole senderRole;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const SupportMessage({
    required this.senderRole,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory SupportMessage.fromMap(Map<String, dynamic> map) {
    return SupportMessage(
      senderRole: map['senderRole'] == 'admin'
          ? SupportSenderRole.admin
          : SupportSenderRole.customer,
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderRole': senderRole.name,
      'senderName': senderName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class SupportTicketModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String category;
  final SupportTicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SupportMessage> messages;

  const SupportTicketModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  // آخر رسالة — تُعرض كمعاينة في قائمة التذاكر
  SupportMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  factory SupportTicketModel.fromMap(Map<String, dynamic> map, String id) {
    return SupportTicketModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      category: map['category'] ?? 'استفسار عام',
      status: map['status'] == 'closed'
          ? SupportTicketStatus.closed
          : SupportTicketStatus.open,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      messages: (map['messages'] as List? ?? [])
          .map((m) => SupportMessage.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'category': category,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }
}
