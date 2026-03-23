// lib/login_tab/login_password.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/terms_privacy_text.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import 'forgot_password_sheet.dart';

class LoginPasswordWidget extends StatefulWidget {
  const LoginPasswordWidget({Key? key}) : super(key: key);

  @override
  State<LoginPasswordWidget> createState() => _LoginPasswordWidgetState();
}

class _LoginPasswordWidgetState extends State<LoginPasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPhoneInput = false;
  String _selectedCountryCode = '+1';

  @override
  void initState() {
    super.initState();
    _identifierController.addListener(_checkInputType);
  }

  void _checkInputType() {
    final text = _identifierController.text.trim();
    if (text.isNotEmpty) {
      // Check if the first character is a digit or a plus sign
      final firstChar = text[0];
      final isPhone = RegExp(r'[0-9+]').hasMatch(firstChar);

      if (_isPhoneInput != isPhone) {
        setState(() {
          _isPhoneInput = isPhone;
        });
      }
    } else {
      if (_isPhoneInput != false) {
        setState(() {
          _isPhoneInput = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await auth.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text.trim(),
      countryCode: _isPhoneInput ? _selectedCountryCode : null,
      ctx: context,
    );
    if (ok) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final loading = auth.uiBlocked && auth.flow == AuthFlow.loggingIn;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Input fields with rounded style
              TextFormField(
                controller: _identifierController,
                decoration: InputDecoration(
                  hintText: 'Phone or Email',
                  prefixIcon: _isPhoneInput
                      ? Container(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppTheme.inputBorderColor,
                                width: 1,
                              ),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountryCode,
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              isDense: true,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedCountryCode = newValue;
                                  });
                                }
                              },
                              items: <String>['+1', '+91']
                                  .map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Roboto Flex',
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  isDense: true,
                  hintStyle: TextStyle(
                    color: AppTheme.unselected_tab_color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto Flex',
                  ),
                  filled: true,
                  fillColor: AppTheme.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.inputBorderColor,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primary, width: 1),
                  ),
                ),

                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Required';
                  if (!Validators.isEmailOrPhone(s))
                    return 'Enter valid phone or email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                // makes it automatically smaller
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  isDense: true,
                  hintStyle: TextStyle(
                    color: AppTheme.unselected_tab_color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto Flex',
                  ),
                  filled: true,
                  fillColor: AppTheme.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.inputBorderColor,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primary, width: 1),
                  ),
                  suffixIcon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.grey.shade500,
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
              const SizedBox(height: 25),
              PrimaryButton(
                text: 'Login',
                loading: loading,

                onPressed: () => _onLogin(auth),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: auth.uiBlocked
                    ? null
                    : () {
                        auth.resetOtpState();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const ForgotPasswordSheet(),
                        );
                      },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppTheme.darkRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Roboto Flex',
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const TermsPrivacyText(),
            ],
          ),
        ),
      ),
    );
  }
}
