import 'package:flutter/material.dart';
import '../widgets/page_template.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  // Track which waste categories are expanded
  final Map<String, bool> _expandedCategories = {
    'Plastic': false,
    'Paper & Cardboard': false,
    'Glass': false,
    'Metal': false,
    'E-Waste': false,
    'Hazardous (B3)': false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageTemplate(
      title: 'Sorting Guide',
      subtitle: 'Learn how to sort waste properly.',
      icon: Icons.menu_book,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Waste Sorting Instructions',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildWasteCategory(
              theme,
              'Plastic',
              [
                '🎯 Flexible/stretchy film, grocery bags, bubble wrap?',
                '   → Gather cleanly → Retail store plastic film drop-off',
                '',
                '🎯 Rigid container? Check resin code (1-7):',
                '   • #1 (PET), #2 (HDPE), #5 (PP):',
                '     → Rinse, keep caps on → Plastic recycling bin',
                '   • #3, #4, #6, #7:',
                '     → Check local rules → General trash',
              ],
            ),
            const SizedBox(height: 12),
            _buildWasteCategory(
              theme,
              'Paper & Cardboard',
              [
                '🎯 Wet, wax-coated, or contaminated (pizza box, grease)?',
                '   → Organic compost bin or general trash',
                '',
                '🎯 Clean and dry (office paper, flattened boxes, magazines)?',
                '   → Remove plastic linings/heavy tape',
                '   → Paper recycling bin',
              ],
            ),
            const SizedBox(height: 12),
            _buildWasteCategory(
              theme,
              'Glass',
              [
                '🎯 Food/beverage bottle or jar?',
                '   → Rinse out, remove metal/plastic lids',
                '   → Glass recycling bin',
                '',
                '🎯 Treated glass (windows, mirrors, drinking glasses, pyrex)?',
                '   → General trash (Different melting point)',
              ],
            ),
            const SizedBox(height: 12),
            _buildWasteCategory(
              theme,
              'Metal',
              [
                '🎯 Aluminum beverage can or tin/steel food can?',
                '   → Rinse out, push lids inside the can',
                '   → Metal recycling bin',
                '',
                '🎯 Large metal object, pipe, or thick cookware?',
                '   → Take to local scrap metal recycler',
              ],
            ),
            const SizedBox(height: 12),
            _buildWasteCategory(
              theme,
              'E-Waste',
              [
                '🎯 Contains data (phone, laptop, hard drive)?',
                '   → Securely wipe data first',
                '',
                '🎯 Standard IT/consumer tech (cords, monitors, circuit boards)?',
                '   → Remove loose batteries',
                '   → Certified e-waste recycler (R2/e-Stewards)',
              ],
            ),
            const SizedBox(height: 12),
            _buildWasteCategory(
              theme,
              'Hazardous (B3)',
              [
                '🎯 Flammable, toxic, corrosive, reactive, or infectious?',
                '   → Keep in original container with legible label',
                '   → HHW / TPS Limbah B3',
                '',
                'Includes:',
                '   • Loose batteries',
                '   • Chemicals',
                '   • Motor oil',
                '   • Spray cans',
                '   • CFL bulbs',
                '   • Medical waste',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteCategory(
    ThemeData theme,
    String category,
    List<String> instructions,
  ) {
    final isExpanded = _expandedCategories[category] ?? false;

    return Material(
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedCategories[category] = !isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isExpanded
                ? Colors.green.withOpacity(0.08)
                : Colors.transparent,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: Colors.green[700],
                    ),
                  ],
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: instructions
                        .map(
                          (instruction) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              instruction,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}