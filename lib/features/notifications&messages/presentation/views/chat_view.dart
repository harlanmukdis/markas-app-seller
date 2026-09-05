import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../generated/l10n.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emon Gupta', style: AppStyles.styleSemiBold16(context)),
            6.sbh,
            Text(
              l.online,
              style: AppStyles.styleSemiBold12(context).copyWith(
                color: const Color(0xff43A047),
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: 16.ps,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: isAppDarkMode()
                    ? null
                    : Border.all(color: const Color(0xffBDD8FF), width: .2),
                shape: BoxShape.circle,
                color: isAppDarkMode() ? kBlackColor : const Color(0xffF8F8F8),
              ),
              child: Icon(
                size: 20,
                Icons.arrow_back_ios_new_outlined,
                color: isAppDarkMode()
                    ? isAppDarkMode()
                        ? kDarkSecondColor
                        : kLightSecondColor
                    : isAppDarkMode()
                        ? kDarkSecondColor
                        : kLightSecondColor,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          8.sbh,
          const Divider(color: Color(0xffE8E7F1), height: 0),
          Expanded(
            child: SingleChildScrollView(
              padding: 24.psh,
              child: Column(
                children: [
                  24.sbh,
                  Text(
                    l.today,
                    style: AppStyles.styleMedium12(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                  17.sbh,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const ShapeDecoration(
                        color: Color(0xFF1D55F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                      ),
                      child: Text(
                        'Hi, Tom 👋',
                        style: AppStyles.styleRegular14(context)
                            .copyWith(color: kWhiteColor),
                      ),
                    ),
                  ),
                  12.sbh,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: context.screenWidth * .7,
                      padding: const EdgeInsets.all(16),
                      decoration: const ShapeDecoration(
                        color: Color(0xFF1D55F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                      ),
                      child: Text(
                        'Iam looking for information about your house. Can I visit to see your house?',
                        style: AppStyles.styleRegular14(context)
                            .copyWith(color: kWhiteColor),
                      ),
                    ),
                  ),
                  12.sbh,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '12:13',
                      style: AppStyles.styleRegular12(context)
                          .copyWith(color: kLightThirdColor),
                    ),
                  ),
                  14.sbh,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: context.screenWidth * .52,
                      padding: const EdgeInsets.all(16),
                      decoration: const ShapeDecoration(
                        color: Color(0xFFBDD8FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                      ),
                      child: Text(
                        'Hi, Santi! Of course, the door is always open 😉',
                        style: AppStyles.styleRegular14(context).copyWith(
                            color: isAppDarkMode()
                                ? kLightThirdColor
                                : kWhiteColor),
                      ),
                    ),
                  ),
                  12.sbh,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '12:15',
                      style: AppStyles.styleRegular12(context)
                          .copyWith(color: kLightThirdColor),
                    ),
                  ),
                  14.sbh,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: context.screenWidth * .7,
                      padding: const EdgeInsets.all(16),
                      decoration: const ShapeDecoration(
                        color: Color(0xFF1D55F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                      ),
                      child: Text(
                        'That’s great, thank you! Sunday at 10 AM does this work for you?',
                        style: AppStyles.styleRegular14(context)
                            .copyWith(color: kWhiteColor),
                      ),
                    ),
                  ),
                  12.sbh,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '12:18',
                      style: AppStyles.styleRegular12(context)
                          .copyWith(color: kLightThirdColor),
                    ),
                  ),
                  14.sbh,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: context.screenWidth * .4,
                      padding: const EdgeInsets.all(16),
                      decoration: const ShapeDecoration(
                        color: Color(0xFFBDD8FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                      ),
                      child: Text(
                        'Of course, see you on Sunday!',
                        style: AppStyles.styleRegular14(context).copyWith(
                            color: isAppDarkMode()
                                ? kLightThirdColor
                                : kWhiteColor),
                      ),
                    ),
                  ),
                  12.sbh,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '12:19',
                      style: AppStyles.styleRegular12(context)
                          .copyWith(color: kLightThirdColor),
                    ),
                  ),
                  36.sbh,
                ],
              ),
            ),
          ),
          Padding(
            padding: 24.psh,
            child: Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    filled: true,
                    fillColor: const Color(0xffF4F6F9),
                    hintText: '${l.writeReply}...',
                    prefix: Container(
                      margin: 16.pa,
                      width: 23,
                      height: 23,
                      decoration: const BoxDecoration(
                        color: Color(0xff94A3B8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: kWhiteColor,
                      ),
                    ),
                    suffix: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Color(0xff94A3B8),
                      ),
                    ),
                  ),
                ),
                12.sbw,
                Container(
                  padding: const EdgeInsets.all(16),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: isAppDarkMode()
                        ? kDarkPrimaryColor
                        : kLightPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(64),
                    ),
                  ),
                  child: const Icon(
                    Icons.send,
                    color: kWhiteColor,
                  ),
                )
              ],
            ),
          ),
          10.sbh,
        ],
      ),
    );
  }
}
