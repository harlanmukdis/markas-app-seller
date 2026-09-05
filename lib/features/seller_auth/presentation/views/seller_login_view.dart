import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/function/components.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/seller_auth_cubit/seller_auth_cubit.dart';

class SellerLoginView extends StatelessWidget {
  const SellerLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SellerAuthCubit>(
      create: (_) => SellerAuthCubit(),
      child: const _SellerLoginBody(),
    );
  }
}

class _SellerLoginBody extends StatefulWidget {
  const _SellerLoginBody();

  @override
  State<_SellerLoginBody> createState() => _SellerLoginBodyState();
}

class _SellerLoginBodyState extends State<_SellerLoginBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await SellerAuthCubit.get(context).login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }

    context.go(SellerRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: 24.pa,
            child: ConstrainedBox(
              // The target is a browser, where an unconstrained form stretches
              // across the whole window and becomes unreadable.
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Masuk sebagai Toko',
                      style: AppStyles.styleSemiBold24(context),
                    ),
                    8.sbh,
                    Text(
                      'Kelola pesanan, stok, dan pencairan dana toko Anda.',
                      style: AppStyles.styleRegular14(context)
                          .copyWith(color: kLightThirdColor),
                    ),
                    32.sbh,
                    Text('Nomor HP', style: AppStyles.styleMedium14(context)),
                    8.sbh,
                    CustomTextFormField(
                      controller: _phoneController,
                      hintText: '081234500001',
                      keyboardType: TextInputType.phone,
                      filled: true,
                      validator: Validators.phone,
                    ),
                    16.sbh,
                    Text('Kata sandi', style: AppStyles.styleMedium14(context)),
                    8.sbh,
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: '••••••••',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      filled: true,
                      onSubmitted: (_) => _submit(),
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: Validators.required('Kata sandi'),
                    ),
                    32.sbh,
                    BlocBuilder<SellerAuthCubit, SellerAuthState>(
                      builder: (context, state) {
                        final isBusy = state is SellerAuthInProgress;
                        return CustomButton(
                          onPressed: isBusy ? null : _submit,
                          child: isBusy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: kWhiteColor,
                                  ),
                                )
                              : const Text('Masuk'),
                        );
                      },
                    ),
                    16.sbh,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Belum punya akun toko?',
                          style: AppStyles.styleRegular14(context),
                        ),
                        4.sbw,
                        CustomTextButton(
                          onPressed: () =>
                              context.push(SellerRoutes.register),
                          child: Text(
                            'Daftar',
                            style:
                                AppStyles.styleSemiBold14(context).copyWith(
                              color: isAppDarkMode()
                                  ? kDarkPrimaryColor
                                  : kLightPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
