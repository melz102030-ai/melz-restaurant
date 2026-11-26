import 'package:cloud_firestore/cloud_firestore.dart';

class LegalSection {
  final String heading;
  final String body;

  const LegalSection({required this.heading, required this.body});

  Map<String, dynamic> toMap() => {'heading': heading, 'body': body};

  factory LegalSection.fromMap(Map<String, dynamic> m) =>
      LegalSection(heading: m['heading'] ?? '', body: m['body'] ?? '');
}

class LegalDocumentModel {
  final String id; // 'privacy_policy' | 'terms_conditions'
  final String title;
  final List<LegalSection> sections;
  final DateTime? updatedAt;

  const LegalDocumentModel({
    required this.id,
    required this.title,
    required this.sections,
    this.updatedAt,
  });

  factory LegalDocumentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final raw = d['sections'] as List? ?? [];
    return LegalDocumentModel(
      id: doc.id,
      title: d['title'] ?? '',
      sections: raw.map((e) => LegalSection.fromMap(Map<String, dynamic>.from(e))).toList(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'sections': sections.map((s) => s.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
