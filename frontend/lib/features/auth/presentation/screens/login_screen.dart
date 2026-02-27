import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/core/widgets/language_toggle.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_header.dart';
import 'package:frontend/core/localization/app_translations.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password   = TextEditingController();
  bool _obscure     = true;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final err = await context.read<AuthProvider>().login(_identifier.text.trim(), _password.text);
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                    children: [
                      AuthHeader(
                        icon: Icons.inventory_2_rounded,
                        title: context.tr('welcome_back'),
                        subtitle: context.tr('login_subtitle'),
                      ),
                      const SizedBox(height: 48),
                      AppTextField(
                        controller: _identifier,
                        label: context.tr('username_email'),
                        icon: Icons.person_outline_rounded,
                        validator: Validators.required,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _password,
                        label: context.tr('password'),
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        validator: Validators.required,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                          child: Text(context.tr('forgot_password'), style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppButton(label: context.tr('sign_in'), onPressed: _submit, isLoading: loading),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(context.tr('no_account'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                            child: Text(context.tr('create_account'), style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w900, fontSize: 16)),
                          ),
                        ],
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
