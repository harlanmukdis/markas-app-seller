import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/domain/model/enums.dart';
import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/seller_auth_cubit/seller_auth_cubit.dart';

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
  final TextEditingController _tokoNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _sellerType = SellerType.toko;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _tokoNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await SellerAuthCubit.get(context).register(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      tokoName: _tokoNameController.text.trim(),
      sellerType: _sellerType,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }

    showSuccessSnackBar(
      context,
      'Akun toko dibuat. Lanjutkan proses aktivasi.',
    );
    context.go(SellerRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Daftar Toko'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: 24.pa,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Buat akun toko',
                      style: AppStyles.styleSemiBold18(context),
                    ),
                    8.sbh,
                    Text(
                      'Setelah mendaftar, toko berstatus DRAFT dan masuk masa '
                      'percobaan. Empat gerbang aktivasi harus lolos sebelum '
                      'bisa berjualan.',
                      style: AppStyles.styleRegular12(context)
                          .copyWith(color: kLightThirdColor),
                    ),
                    24.sbh,
                    _Field(
                      label: 'Nama pemilik',
                      controller: _fullNameController,
                      hintText: 'Nama sesuai KTP',
                      validator: Validators.required('Nama pemilik'),
                    ),
                    _Field(
                      label: 'Nama toko',
                      controller: _tokoNameController,
                      hintText: 'Toko Jaya Bangunan',
                      validator: Validators.required('Nama toko'),
                    ),
                    _Field(
                      label: 'Nomor HP',
                      controller: _phoneController,
                      hintText: '081234500001',
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                    ),
                    _Field(
                      label: 'Email (opsional)',
                      controller: _emailController,
                      hintText: 'toko@mail.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.optionalEmail,
                    ),
                    Text(
                      'Jenis toko',
                      style: AppStyles.styleMedium14(context),
                    ),
                    8.sbh,
                    DropdownButtonFormField<String>(
                      initialValue: _sellerType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isAppDarkMode()
                            ? kLightSecondColor
                            : const Color(0xffF4F6F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      items: SellerType.all
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(SellerType.label(type)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(
                        () => _sellerType = value ?? SellerType.toko,
                      ),
                    ),
                    4.sbh,
                    Text(
                      'Distributor hanya pembeda tampilan — alur onboarding, '
                      'katalog, pesanan, dan pencairan identik.',
                      style: AppStyles.styleRegular10(context)
                          .copyWith(color: kLightThirdColor),
                    ),
                    16.sbh,
                    Text(
                      'Kata sandi',
                      style: AppStyles.styleMedium14(context),
                    ),
                    8.sbh,
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: 'Minimal 6 karakter',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      filled: true,
                      onSubmitted: (_) => _submit(),
                      validator: Validators.password,
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
                              : const Text('Daftar'),
                        );
                      },
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.validator,
    this.hintText,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final String? hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppStyles.styleMedium14(context)),
          8.sbh,
          CustomTextFormField(
            controller: controller,
            hintText: hintText,
            keyboardType: keyboardType,
            filled: true,
            validator: validator,
          ),
        ],
      ),
    );
  }
}
