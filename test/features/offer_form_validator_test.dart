import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/catalog/offer.dart';
import 'package:navy_wear/core/utils/local_network.dart';
import 'package:navy_wear/features/seller_catalog/presentation/views/widgets/photo_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `CustomTextFormField` falls back to a required-field validator whose
/// message is Arabic. Any such field inside a `Form` blocks submission when
/// empty — and the photo editor's URL box is empty by design once the photos
/// have been added, so the product form refused to submit and explained why
/// in a language the store cannot read.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CachedHelper.init();
  });

  testWidgets('an emptied photo URL box does not block the enclosing form',
      (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: PhotoEditor(
                photos: const <OfferPhoto>[
                  OfferPhoto(url: 'https://x/1.jpg', width: 900, height: 900),
                  OfferPhoto(url: 'https://x/2.jpg', width: 900, height: 900),
                  OfferPhoto(url: 'https://x/3.jpg', width: 900, height: 900),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('هذا الحقل مطلوب'), findsNothing);
  });
}
