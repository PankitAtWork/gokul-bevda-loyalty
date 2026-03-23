import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import 'change_password_sheet.dart';
import 'package:flutter/gestures.dart';

class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final TextEditingController _identifierCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();

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
    _identifierCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp(AuthProvider auth) async {
    final id = _identifierCtrl.text.trim();
    if (id.isEmpty) {
      _showLocal('Enter phone or email');
      return;
    }
    if (!Validators.isEmailOrPhone(id)) {
      _showLocal('Enter valid phone or email');
      return;
    }

    final ok = await auth.sendOtp(
      identifier: id,
      purpose: 'forgot_password',
      countryCode: _isPhoneInput ? _selectedCountryCode : null,
      ctx: context,
    );
    if (ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP sent')));
    }
  }

  Future<void> _verifyOtp(AuthProvider auth) async {
    final otp = _otpCtrl.text.trim();
    if (otp.isEmpty) {
      _showLocal('Enter OTP');
      return;
    }

    final ok = await auth.verifyOtp(otp: otp, ctx: context);
    if (ok) {
      if (!mounted) return;
      // Close the bottom sheet
      Navigator.pop(context);
      // Navigate to change password sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const ChangePasswordSheet(),
      );
    }
  }

  void _showLocal(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Info'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final sending = auth.uiBlocked && auth.flow == AuthFlow.sendingOtp;
    final verifying = auth.uiBlocked && auth.flow == AuthFlow.verifyingOtp;

    return Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto Flex',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _identifierCtrl,
              decoration: InputDecoration(
                hintText: 'Phone or Email',
                prefixIcon: _isPhoneInput
                    ? Container(
                        padding: const EdgeInsets.only(left: 12, right: 8),
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
                                .map<DropdownMenuItem<String>>((String value) {
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
                hintStyle: TextStyle(
                  color: AppTheme.unselected_tab_color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto Flex',
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                isDense: true,
                filled: true,
                fillColor: AppTheme.bg,
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
              ),
            ),
            const SizedBox(height: 30),
            PrimaryButton(
              text: 'Send OTP',
              loading: sending,
              onPressed: () => _sendOtp(auth),
            ),
            const SizedBox(height: 12),

            if (auth.otpSent && auth.otpPurpose == 'forgot_password')
              Column(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.unselected_tab_color,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "Enter OTP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.unselected_tab_color,
                            fontFamily: 'Roboto Flex',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.unselected_tab_color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PinCodeTextField(
                    appContext: context,
                    controller: _otpCtrl,
                    length: 6,
                    enableActiveFill: true,
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      fieldHeight: 48,
                      fieldWidth: 40,
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      inactiveColor: AppTheme.grayColor,
                      activeColor: AppTheme.accent,
                      selectedColor: AppTheme.accent,
                      inactiveFillColor: Colors.white,
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      borderWidth: 1.5,
                    ),
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.unselected_tab_color,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto Flex',
                        ),
                        children: [
                          const TextSpan(text: "Didn't receive code? "),
                          TextSpan(
                            text: "Resend OTP",
                            style: TextStyle(
                              color: AppTheme.darkRed,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Roboto Flex',
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                debugPrint("Resend OTP");
                                _sendOtp(auth);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Verify OTP',
                    loading: verifying,
                    onPressed: () => _verifyOtp(auth),
                  ),
                ],
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
