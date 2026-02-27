import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_dialogs.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/core/widgets/language_toggle.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/data/sources/auth_remote_source.dart';
import 'package:frontend/features/auth/domain/usecases/auth_usecases.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_header.dart';

import '../../../../core/localization/app_translations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  bool _obscure   = true;
  bool _loading   = false;

  late final SignupUseCase _signup = SignupUseCase(AuthRepositoryImpl(AuthRemoteSource()));

  @override
  void dispose() {
    _username.dispose(); _email.dispose(); _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _signup(_username.text.trim(), _email.text.trim(), _password.text);
      if (mounted) {
        AppDialogs.snack(context, 'គណនីត្រូវបានបង្កើត! សូមចូលប្រើប្រាស់។');
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) AppDialogs.snack(context, e.message, isError: true);
    } catch (_) {
      if (mounted) AppDialogs.snack(context, 'មានបញ្ហាតភ្ជាប់បណ្តាញ។', isError: true);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const LanguageToggle(),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthHeader(
                        icon: Icons.person_add_alt_1_rounded,
                        title: context.tr('create_account'),
                        subtitle: 'Join the inventory management system',
                      ),
                      const SizedBox(height: 40),
                      AppTextField(controller: _username, label: context.tr('username_email'), icon: Icons.person_outline, validator: Validators.required),
                      const SizedBox(height: 16),
                      AppTextField(controller: _email, label: 'Email', icon: Icons.email_outlined, validator: Validators.email),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _password,
                        label: context.tr('password'),
                        icon: Icons.lock_outline,
                        obscureText: _obscure,
                        validator: Validators.minLength(6),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 32),
                      AppButton(label: context.tr('create_account'), onPressed: _submit, isLoading: _loading),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(context.tr('no_account'), style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
