import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// زر إجراء صغير موحّد (تعديل/نسخ/حذف...) — خلفية دائرية خفيفة بلون الإجراء
// بدل أيقونات متلاصقة بلا مسافات أو خلفية، لتمييزها عن بعضها بوضوح.
// كانت مكرَّرة بنسختين مختلفتين قليلاً في شاشتي إدارة القائمة والإعلانات
// المنبثقة — وُحِّدت هنا في مكان واحد.
class ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;
  const ActionIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}

// حبة اختيار نوع/رابط (لا شيء/فئة/صنف/رابط خارجي...) — تُستخدم في نوافذ ربط
// البانرات والإعلانات المنبثقة بفئة أو صنف
class TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const TypeChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple.withValues(alpha: 0.15) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.surfaceLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? AppColors.purple : AppColors.textHint, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.purple : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
