// lib/signup_tab/signup_password.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/terms_privacy_text.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';

class SignupPasswordWidget extends StatefulWidget {
  final String? name;
  final String? identifier;
  const SignupPasswordWidget({Key? key, this.name, this.identifier})
    : super(key: key);

  @override
  State<SignupPasswordWidget> createState() => _SignupPasswordWidgetState();
}

class _SignupPasswordWidgetState extends State<SignupPasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerAccount(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    final phone = auth.currentPhone;
    final email = auth.currentEmail;
    final name = widget.name ?? auth.currentName ?? '';
    
    if (phone == null || phone.isEmpty || email == null || email.isEmpty) {
      _showLocal('Missing details. Please go back and enter details again.');
      return;
    }
    // For demo, use identifier as both phone/email and phone
    final otp = auth.signupOtp;
    if (otp == null || otp.isEmpty) {
      _showLocal('Missing OTP. Please go back and verify your phone/email.');
      return;
    }

    final ok = await auth.registerUser(
      phoneOrEmail: phone,
      email: email,
      phone: phone,
      password: _passCtrl.text.trim(),
      name: name,
      enteredOtp: otp,
      ctx: context,
    );
    if (ok) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showLocal(String s) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Info'),
      content: Text(s),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final creating = auth.uiBlocked && auth.flow == AuthFlow.creatingAccount;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Create Password',
                  filled: true,
                  fillColor: AppTheme.bg,
                  hintStyle: TextStyle(
                    color: AppTheme.unselected_tab_color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto Flex',
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.unselected_tab_color,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primary, width: 1),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (v) {
                  final s = v ?? '';
                  if (s.isEmpty) return 'Required';
                  if (!Validators.validPassword(s))
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  filled: true,
                  fillColor: AppTheme.bg,
                  hintStyle: TextStyle(
                    color: AppTheme.unselected_tab_color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto Flex',
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.unselected_tab_color,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primary, width: 1),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (v) {
                  final s = v ?? '';
                  if (s.isEmpty) return 'Required';
                  if (s != _passCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 60),
              PrimaryButton(
                text: 'Create Account',
                loading: creating,
                onPressed: () => _registerAccount(auth),
              ),
              const SizedBox(height: 40),
              const TermsPrivacyText(),
            ],
          ),
        ),
      ),
    );
  }
}
