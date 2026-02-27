import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_dialogs.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/data/sources/auth_remote_source.dart';
import 'package:frontend/features/auth/domain/usecases/auth_usecases.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_header.dart';
import 'package:frontend/core/localization/app_translations.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _otp      = TextEditingController();
  final _newPass  = TextEditingController();
  final _confirm  = TextEditingController();
  final _formKey  = GlobalKey<FormState>();
  bool _obscure   = true;
  bool _loading   = false;

  late final ResetPasswordUseCase _reset =
      ResetPasswordUseCase(AuthRepositoryImpl(AuthRemoteSource()));

  @override
  void dispose() { _otp.dispose(); _newPass.dispose(); _confirm.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newPass.text != _confirm.text) {
      AppDialogs.snack(context, context.tr('pass_mismatch'), isError: true); // Add key
      return;
    }
    setState(() => _loading = true);
    try {
      await _reset(widget.email, _otp.text.trim(), _newPass.text);
      if (mounted) {
        AppDialogs.snack(context, context.tr('pass_reset_success')); // Add key
        Navigator.popUntil(context, (r) => r.isFirst);
      }
    } on ApiException catch (e) {
      if (mounted) AppDialogs.snack(context, e.message, isError: true);
    } catch (_) {
      if (mounted) AppDialogs.snack(context, context.tr('error'), isError: true);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              AuthHeader(
                icon: Icons.password_rounded,
                title: context.tr('update_password'),
                subtitle: '${context.tr('otp_sent_to')}\n${widget.email}', // Add key
              ),
              const SizedBox(height: 40),
              AppTextField(controller: _otp, label: context.tr('otp'), icon: Icons.pin_outlined, keyboardType: TextInputType.number, validator: Validators.required),
              const SizedBox(height: 16),
              AppTextField(
                controller: _newPass, label: context.tr('new_password'), icon: Icons.lock_outline,
                obscureText: _obscure, validator: Validators.minLength(6),
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)),
              ),
              const SizedBox(height: 16),
              AppTextField(controller: _confirm, label: context.tr('confirm_password'), icon: Icons.lock_reset, obscureText: _obscure, validator: Validators.required),
              const SizedBox(height: 32),
              AppButton(label: context.tr('update_password'), onPressed: _submit, isLoading: _loading),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
