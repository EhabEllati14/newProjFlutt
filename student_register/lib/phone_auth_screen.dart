import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  String _selectedCode = "+970";
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            top: isKeyboardOpen ? 30 : size.height * 0.15,
            bottom: isKeyboardOpen ? 30 : 0,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Header Image
                SizedBox(
                  height: size.height * 0.20,
                  child: Image.asset(
                    "assets/phone_header.png",
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "WASSELNI",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Please confirm your country code and\nenter your phone number",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 24),

                // ✅ Phone Input Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCode,
                            items: const [
                              DropdownMenuItem(
                                value: "+970",
                                child: Text("🇵🇸 +970"),
                              ),
                              DropdownMenuItem(
                                value: "+972",
                                child: Text("🇮🇱 +972"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCode = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          decoration: InputDecoration(
                            hintText: "5XXXXXXXX",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final phone = _phoneController.text.trim();

                        if (phone.length != 9) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("⚠️ Please enter exactly 9 digits"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final fullPhone = '$_selectedCode$phone';

                        if (kIsWeb) {
                          await _sendOtpWeb(fullPhone);
                        } else {
                          await _sendOtpMobile(fullPhone);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📱 Mobile flow → SMS is sent
  Future<void> _sendOtpMobile(String phone) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Phone verified automatically"),
              backgroundColor: Colors.green,
            ),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Verification failed: ${e.message}"),
              backgroundColor: Colors.red,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                verificationId: verificationId,
                phone: phone,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("⌛ Code auto-retrieval timed out"),
              backgroundColor: Colors.orange,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Unexpected error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🌐 Web flow → SMS is sent
  Future<void> _sendOtpWeb(String phone) async {
    try {
      final confirmationResult =
          await FirebaseAuth.instance.signInWithPhoneNumber(phone);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            verificationId: confirmationResult.verificationId,
            phone: phone,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Web OTP error: $e")),
      );
    }
  }
}
