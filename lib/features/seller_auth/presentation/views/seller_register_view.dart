import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/seller_auth_cubit/seller_auth_cubit.dart';

/// Creates the **account**, not the store.
///
/// On this backend every account starts as a buyer and becomes a seller by
/// opening a store, so asking for a shop name here would be asking for
/// something the endpoint cannot accept.
class SellerRegisterView extends StatelessWidget {
  const SellerRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SellerAuthCubit>(
      create: (_) => SellerAuthCubit(),
      child: const _SellerRegisterBody(),
    );
  }
}

class _SellerRegisterBody extends StatefulWidget {
  const _SellerRegisterBody();

  @override
  State<_SellerRegisterBody> createState() => _SellerRegisterBodyState();
}

class _SellerRegisterBodyState extends State<_SellerRegisterBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final error = await SellerAuthCubit.get(context).register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      phone: phone.isEmpty ? null : phone,
    );

    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }

    // Registered, verified and logged in — but with no store yet, so the
    // bootstrap screen is what decides where to land.
    context.go(SellerRoutes.bootstrap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Daftar akun'),
      body: SafeArea(
        child: BlocBuilder<SellerAuthCubit, SellerAuthState>(
          builder: (context, state) {
            final isBusy = state is SellerAuthInProgress;

            return SingleChildScrollView(
              padding: 24.pa,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Buat akun dulu, tokonya menyusul',
                          style: AppStyles.styleSemiBold18(context),
                        ),
                        8.sbh,
                        Text(
                          'Satu akun bisa punya beberapa toko. Toko pertama '
                          'dibuat setelah akun jadi.',
                          style: AppStyles.styleRegular12(context)
                              .copyWith(color: kLightThirdColor),
                        ),
                        24.sbh,
                        CustomTextFormField(
                          controller: _fullNameController,
                          labelText: 'Nama lengkap',
                          textInputAction: TextInputAction.next,
                          validator: Validators.required('Nama lengkap'),
                        ),
                        16.sbh,
                        CustomTextFormField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'nama@toko.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.email,
                        ),
                        16.sbh,
                        CustomTextFormField(
                          controller: _phoneController,
                          labelText: 'Nomor HP (opsional)',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: Validators.optional,
                        ),
                        16.sbh,
                        CustomTextFormField(
                          controller: _passwordController,
                          labelText: 'Kata sandi',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: Validators.password,
                        ),
                        32.sbh,
                        FilledButton(
                          onPressed: isBusy ? null : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: isBusy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: kWhiteColor,
                                  ),
                                )
                              : const Text('Daftar'),
                        ),
                        16.sbh,
                        Center(
                          child: TextButton(
                            onPressed: isBusy
                                ? null
                                : () => context.go(SellerRoutes.login),
                            child: const Text('Sudah punya akun? Masuk'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
