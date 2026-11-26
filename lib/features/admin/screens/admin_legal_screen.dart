import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/legal_document_model.dart';
import '../../../core/providers/legal_provider.dart';
import '../../../core/services/legal_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_widget.dart';

class AdminLegalScreen extends ConsumerStatefulWidget {
  const AdminLegalScreen({super.key});

  @override
  ConsumerState<AdminLegalScreen> createState() => _AdminLegalScreenState();
}

class _AdminLegalScreenState extends ConsumerState<AdminLegalScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    // إنشاء المستندات في Firestore إن لم تكن موجودة
    LegalService.seedIfMissing();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستندات القانونية'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'سياسة الخصوصية'),
            Tab(text: 'الشروط والأحكام'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _DocEditor(
            stream: ref.watch(privacyPolicyProvider),
            docId: LegalService.privacyId,
          ),
          _DocEditor(
            stream: ref.watch(termsConditionsProvider),
            docId: LegalService.termsId,
          ),
        ],
      ),
    );
  }
}

class _DocEditor extends StatefulWidget {
  final AsyncValue<LegalDocumentModel?> stream;
  final String docId;

  const _DocEditor({required this.stream, required this.docId});

  @override
  State<_DocEditor> createState() => _DocEditorState();
}

class _DocEditorState extends State<_DocEditor> {
  List<_SectionEditor>? _editors;
  bool _saving = false;

  void _loadEditors(LegalDocumentModel doc) {
    if (_editors != null) return; // لا تُعيد التهيئة إذا كان المستخدم يعدّل
    _editors = doc.sections
        .map((s) => _SectionEditor(
              heading: TextEditingController(text: s.heading),
              body: TextEditingController(text: s.body),
            ))
        .toList();
  }

  void _addSection() {
    setState(() {
      _editors ??= [];
      _editors!.add(_SectionEditor(
        heading: TextEditingController(),
        body: TextEditingController(),
      ));
    });
  }

  void _removeSection(int index) {
    setState(() => _editors!.removeAt(index));
  }

  Future<void> _save(String title) async {
    if (_editors == null) return;
    setState(() => _saving = true);
    try {
      final doc = LegalDocumentModel(
        id: widget.docId,
        title: title,
        sections: _editors!
            .map((e) => LegalSection(
                  heading: e.heading.text.trim(),
                  body: e.body.text.trim(),
                ))
            .where((s) => s.heading.isNotEmpty)
            .toList(),
      );
      await LegalService.saveDocument(doc);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحفظ'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.stream.when(
      loading: () => const Center(child: LoadingWidget()),
      error: (e, _) => Center(child: Text('$e')),
      data: (doc) {
        if (doc == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('جاري إنشاء المستند...', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                const CircularProgressIndicator(),
              ],
            ),
          );
        }
        _loadEditors(doc);
        return _buildForm(doc.title);
      },
    );
  }

  Widget _buildForm(String title) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_editors != null)
                for (int i = 0; i < _editors!.length; i++)
                  _SectionCard(
                    index: i,
                    editor: _editors![i],
                    onRemove: () => _removeSection(i),
                  ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة قسم'),
                onPressed: _addSection,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.surfaceLight)),
          ),
          child: AppButton(
            label: 'حفظ التغييرات',
            icon: Icons.save_outlined,
            width: double.infinity,
            onPressed: () => _save(title),
            isLoading: _saving,
          ),
        ),
      ],
    );
  }
}

class _SectionEditor {
  final TextEditingController heading;
  final TextEditingController body;
  _SectionEditor({required this.heading, required this.body});
}

class _SectionCard extends StatelessWidget {
  final int index;
  final _SectionEditor editor;
  final VoidCallback onRemove;

  const _SectionCard({
    required this.index,
    required this.editor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: editor.heading,
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'عنوان القسم',
                      hintStyle: TextStyle(color: AppColors.textHint),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: onRemove,
                  tooltip: 'حذف القسم',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: editor.body,
              maxLines: null,
              minLines: 3,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
              decoration: InputDecoration(
                hintText: 'نص القسم...',
                hintStyle: TextStyle(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
