// lib/signup_tab/signup_otp.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../../utils/theme.dart';
import 'package:flutter/gestures.dart';

class SignupOtpWidget extends StatefulWidget {
  final String? name;
  final VoidCallback? onVerified;
  const SignupOtpWidget({Key? key, this.name, this.onVerified})
    : super(key: key);

  @override
  State<SignupOtpWidget> createState() => _SignupOtpWidgetState();
}

class _SignupOtpWidgetState extends State<SignupOtpWidget> {
  final TextEditingController _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify(AuthProvider auth) async {
    final otp = _otpCtrl.text.trim();
    if (otp.isEmpty) {
      _showLocal('Enter OTP');
      return;
    }
    // Save the OTP in the auth provider so it can be sent to the register API later
    auth.signupOtp = otp;
    final ok = true; //await auth.verifyOtp(otp: otp, ctx: context);
    if (ok) {
      if (widget.onVerified != null) widget.onVerified!();
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
    final verifying = auth.uiBlocked && auth.flow == AuthFlow.verifyingOtp;

    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.unselected_tab_color, // light grey line
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Verify OTP",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.unselected_tab_color,
                  fontFamily: 'Roboto Flex',
                ),
              ),
            ),

            Expanded(
              child: Container(height: 1, color: AppTheme.unselected_tab_color),
            ),
          ],
        ),
        const SizedBox(height: 25),
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
            borderRadius: BorderRadius.circular(10), // <-- rounded corners

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
        const SizedBox(height: 10),

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
        const SizedBox(height: 30),
        PrimaryButton(
          text: 'Verify & Sign Up',
          loading: verifying,
          onPressed: () => _verify(auth),
        ),
      ],
    );
  }
}
