part of '../figma_ui.dart';

class FigmaSegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Color? selectedColor;

  const FigmaSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = selectedColor ?? AppTheme.primaryBlue;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.neumorphicInset,
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? active : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  labels[i],
                  style: FigmaUi.rubik(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : AppTheme.textColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
