import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_dialogs.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/data/sources/auth_remote_source.dart';
import 'package:frontend/features/auth/domain/usecases/auth_usecases.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_header.dart';
import 'package:frontend/core/localization/app_translations.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email  = TextEditingController();
  bool _loading = false;

  late final ForgotPasswordUseCase _forgot =
      ForgotPasswordUseCase(AuthRepositoryImpl(AuthRemoteSource()));

  @override
  void dispose() { _email.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await _forgot(_email.text.trim());
      if (mounted) {
        AppDialogs.snack(context, context.tr('otp_sent_msg')); // I should add this key
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: _email.text.trim()),
        ));
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              AuthHeader(
                icon: Icons.mark_email_unread_outlined,
                title: context.tr('forgot_password'),
                subtitle: context.tr('forgot_pass_subtitle'), // I should add this key
              ),
              const SizedBox(height: 48),
              AppTextField(controller: _email, label: context.tr('email'), icon: Icons.email_outlined),
              const SizedBox(height: 32),
              AppButton(label: context.tr('send_otp'), onPressed: _submit, isLoading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}
