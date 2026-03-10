// lib/signup_tab/signup_detail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/terms_privacy_text.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import 'signup_otp.dart';

class SignupDetailWidget extends StatefulWidget {
  final VoidCallback? onOtpVerified;
  const SignupDetailWidget({Key? key, this.onOtpVerified}) : super(key: key);

  @override
  State<SignupDetailWidget> createState() => _SignupDetailWidgetState();
}

class _SignupDetailWidgetState extends State<SignupDetailWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _identifierCtrl = TextEditingController();

  bool _isPhoneInput = false;
  String _selectedCountryCode = '+1';

  @override
  void initState() {
    super.initState();
    _identifierCtrl.addListener(_checkInputType);
  }

  void _checkInputType() {
    final text = _identifierCtrl.text.trim();
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
    _nameCtrl.dispose();
    _identifierCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendSignupOtp(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    auth.currentName = _nameCtrl.text.trim();
    final ok = await auth.sendOtp(
      identifier: _identifierCtrl.text.trim(),
      purpose: 'signup',
      countryCode: _isPhoneInput ? _selectedCountryCode : null,
      ctx: context,
    );
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP sent for signup')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final sending = auth.uiBlocked && auth.flow == AuthFlow.sendingOtp;

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
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
                        borderSide: BorderSide(
                          color: AppTheme.primary,
                          width: 1,
                        ),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _identifierCtrl,
                    decoration: InputDecoration(
                      hintText: 'Phone or Email',
                      prefixIcon: _isPhoneInput
                          ? Container(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 8,
                              ),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: AppTheme.unselected_tab_color,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCountryCode,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 20,
                                  ),
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
                        borderSide: BorderSide(
                          color: AppTheme.primary,
                          width: 1,
                        ),
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
                  const SizedBox(height: 30),
                  PrimaryButton(
                    text: 'Sign Up & Send OTP',
                    loading: sending,
                    onPressed: () => _sendSignupOtp(auth),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            if (auth.otpSent && auth.otpPurpose == 'signup')
              SignupOtpWidget(
                name: _nameCtrl.text.trim(),
                onVerified: () {
                  // callback to open password page
                  if (widget.onOtpVerified != null) widget.onOtpVerified!();
                },
              ),
            const SizedBox(height: 30),
            const TermsPrivacyText(),
          ],
        ),
      ),
    );
  }
}
