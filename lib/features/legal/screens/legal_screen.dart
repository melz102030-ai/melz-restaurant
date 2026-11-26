import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/legal_document_model.dart';
import '../../../core/providers/legal_provider.dart';
import '../../../core/services/legal_service.dart';
import '../../../shared/widgets/loading_widget.dart';

/// سياسة الخصوصية / الشروط والأحكام
class LegalScreen extends ConsumerWidget {
  final String docId; // LegalService.privacyId | LegalService.termsId

  const LegalScreen({super.key, required this.docId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = docId == 'privacy_policy'
        ? ref.watch(privacyPolicyProvider)
        : ref.watch(termsConditionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(LegalService.titles[docId] ?? ''),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (e, _) => Center(
          child: Text('تعذّر التحميل', style: TextStyle(color: AppColors.error)),
        ),
        data: (doc) => doc == null ? const SizedBox.shrink() : _DocBody(doc: doc),
      ),
    );
  }
}

class _DocBody extends StatelessWidget {
  final LegalDocumentModel doc;
  const _DocBody({required this.doc});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
      children: [
        if (doc.updatedAt != null) ...[
          Text(
            'آخر تحديث: ${DateFormat('dd/MM/yyyy').format(doc.updatedAt!)}',
            style: TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
        ],
        const SizedBox(height: 20),

        // الأقسام
        for (int i = 0; i < doc.sections.length; i++)
          _SectionTile(number: i + 1, section: doc.sections[i]),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  final int number;
  final LegalSection section;
  const _SectionTile({required this.number, required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.heading,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 38),
            child: Text(
              section.body,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
