import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../generated/l10n.dart';

class DescriptionScreen extends StatelessWidget {
  const DescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final Map<String, String> items = {
      l.color: 'White',
      l.style: 'Casual',
      l.type: 'Top',
      l.neckline: 'V neck',
      l.details: 'Contrast Lace',
      l.sleeveLength: 'Half Sleeve',
      l.sleeveType: 'Flounce Sleeve',
      l.length: 'Regular',
      l.fitType: 'Regular Fit',
      l.fabric: 'Non-Stretch',
      l.material: 'Woven Fabric',
      l.composition: '100% Polyester',
      l.careInstructions: 'Machine wash or professional dry clean',
      l.sheer: 'Semi-Sheer',
    };
    return Scaffold(
      appBar: customAppBar(context, l.description),
      body: ListView.builder(
        padding: 16.pb,
        itemCount: items.length,
        itemBuilder: (context, index) {
          // Convert the map entries to a list for indexing
          final itemEntry = items.entries.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 24, left: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${itemEntry.key} :',
                    style:
                        AppStyles.styleRegular14(context).copyWith(height: 2),
                  ),
                ),
                Expanded(
                  child: Text(
                    itemEntry.value,
                    style:
                        AppStyles.styleRegular14(context).copyWith(height: 2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// class ProductListTile extends StatelessWidget {
//   final String? productLabel;
//
//   const ProductListTile(this.productLabel, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text('$productLabel', style: const TextStyle(color: Colors.black)),
//       subtitle: Text(S.of(context).subTitle,
//           style: const TextStyle(color: Colors.black)),
//       leading: const Icon(Icons.help_center_outlined, color: Colors.black),
//     );
//   }
// }
