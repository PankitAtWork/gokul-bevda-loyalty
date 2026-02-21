// lib/login_tab/login_otp.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/terms_privacy_text.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import 'package:flutter/gestures.dart';

class LoginOtpWidget extends StatefulWidget {
  const LoginOtpWidget({Key? key}) : super(key: key);

  @override
  State<LoginOtpWidget> createState() => _LoginOtpWidgetState();
}

class _LoginOtpWidgetState extends State<LoginOtpWidget> {
  final TextEditingController _identifierCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();

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
    // Changed to use new sendOtp API for login purpose
    final ok = await auth.sendOtp(
      identifier: id,
      purpose: 'login',
      ctx: context,
    );
    if (ok) {
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

    // Call new verifyOtp API
    final ok = await auth.verifyOtp(otp: otp, ctx: context);
    if (ok) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const SizedBox(height: 30),
            TextFormField(
              controller: _identifierCtrl,
              decoration: InputDecoration(
                hintText: 'Phone or Email',
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
            const SizedBox(height: 60),
            PrimaryButton(
              text: 'Send OTP',
              loading: sending,
              onPressed: () => _sendOtp(auth),
            ),
            const SizedBox(height: 12),

            if (auth.otpSent &&
                auth.otpPurpose == 'login') // Check if OTP was sent
              Column(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color:
                              AppTheme.unselected_tab_color, // light grey line
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
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // <-- rounded corners

                      inactiveColor: AppTheme.grayColor, // <-- gray border
                      activeColor: AppTheme.accent, // <-- gray when selected
                      selectedColor: AppTheme.accent, // <-- border when focused

                      inactiveFillColor: Colors.white,
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,

                      borderWidth: 1.5,
                    ),
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
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
                          TextSpan(text: "Didn't receive code? "),

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
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Verify & Login',
                    loading: verifying,
                    onPressed: () => _verifyOtp(auth),
                  ),
                ],
              ),

            const SizedBox(height: 8),
            const TermsPrivacyText(),
          ],
        ),
      ),
    );
  }
}
