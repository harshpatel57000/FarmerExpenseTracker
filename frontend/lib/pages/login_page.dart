
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'create_account_page.dart';
import 'services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  bool isOtpMode = false;
  bool otpSent = false;
  bool passwordVisible = false;
  bool isLoading = false;

  static const Color green = Color(0xFF247A43);
  static const Color lightGreen = Color(0xFFEAF5EC);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> runRequest(
    Future<void> Function() action,
  ) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      await action();
    } catch (e) {
      showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void openHome() {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(),
      ),
      (route) => false,
    );
  }

  String get emailOrPhone => emailController.text.trim();

  bool get looksLikeEmail =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
          .hasMatch(emailOrPhone);

  Future<void> passwordLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await runRequest(() async {
      await ApiService.loginWithPassword(
        loginId: emailOrPhone,
        password: passwordController.text,
      );

      openHome();
    });
  }

  Future<void> sendOtp() async {
    if (!looksLikeEmail) {
      showMessage('કૃપા કરીને સાચો ઈમેલ દાખલ કરો');
      return;
    }

    await runRequest(() async {
      await ApiService.sendLoginOtp(
        emailId: emailOrPhone,
      );

      if (!mounted) return;

      otpController.clear();
      setState(() => otpSent = true);

      showMessage('તમારા ઈમેલ પર OTP મોકલવામાં આવ્યો છે');
    });
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (!looksLikeEmail) {
      showMessage('કૃપા કરીને સાચો ઈમેલ દાખલ કરો');
      return;
    }

    if (otp.isEmpty) {
      showMessage('OTP દાખલ કરો');
      return;
    }

    await runRequest(() async {
      await ApiService.verifyLoginOtp(
        emailId: emailOrPhone,
        otp: otp,
      );

      openHome();
    });
  }

  void selectMethod(bool otpMode) {
    setState(() {
      isOtpMode = otpMode;
      otpSent = false;
      otpController.clear();
      passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Farming logo
                    Center(
                      child: Container(
                        height: 88,
                        width: 88,
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius:
                              BorderRadius.circular(26),
                        ),
                        child: const Icon(
                          Icons.agriculture_rounded,
                          color: green,
                          size: 52,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Farmer Expense Tracker',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: green,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'તમારા ખેતીના ખર્ચનું સરળ સંચાલન',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Login card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'તમારું સ્વાગત છે!',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 7),

                          const Text(
                            'લોગિન કરવાની રીત પસંદ કરો',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Two login options
                          Container(
                            padding:
                                const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                            child: Row(
                              children: [
                                _methodButton(
                                  label: 'પાસવર્ડ',
                                  icon: Icons.lock_outline,
                                  selected: !isOtpMode,
                                  onTap: () =>
                                      selectMethod(false),
                                ),
                                _methodButton(
                                  label: 'ઈમેલ OTP',
                                  icon: Icons.mail_outline,
                                  selected: isOtpMode,
                                  onTap: () =>
                                      selectMethod(true),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Email or phone for password login;
                          // email only for OTP login.
                          TextFormField(
                            controller: emailController,
                            keyboardType: isOtpMode
                                ? TextInputType.emailAddress
                                : TextInputType.text,
                            autocorrect: false,
                            decoration: _decoration(
                              label: isOtpMode
                                  ? 'ઈમેલ'
                                  : 'ઈમેલ અથવા મોબાઈલ નંબર',
                              hint: isOtpMode
                                  ? 'તમારો ઈમેલ દાખલ કરો'
                                  : 'ઈમેલ અથવા મોબાઈલ દાખલ કરો',
                              icon: Icons.person_outline,
                            ),
                            validator: (value) {
                              final text =
                                  value?.trim() ?? '';

                              if (text.isEmpty) {
                                return 'ઈમેલ અથવા મોબાઈલ દાખલ કરો';
                              }

                              if (isOtpMode &&
                                  !RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(text)) {
                                return 'સાચો ઈમેલ દાખલ કરો';
                              }

                              return null;
                            },
                          ),

                          if (!isOtpMode) ...[
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: passwordController,
                              obscureText: !passwordVisible,
                              decoration: _decoration(
                                label: 'પાસવર્ડ',
                                hint: 'તમારો પાસવર્ડ દાખલ કરો',
                                icon: Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passwordVisible =
                                          !passwordVisible;
                                    });
                                  },
                                  icon: Icon(
                                    passwordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (!isOtpMode &&
                                    (value == null ||
                                        value.isEmpty)) {
                                  return 'પાસવર્ડ દાખલ કરો';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 22),

                            _primaryButton(
                              label: 'લોગિન કરો',
                              icon: Icons.login,
                              onPressed: passwordLogin,
                            ),
                          ],

                          if (isOtpMode) ...[
                            if (!otpSent) ...[
                              const SizedBox(height: 22),

                              _primaryButton(
                                label: 'ઈમેલ પર OTP મોકલો',
                                icon: Icons.mark_email_read_outlined,
                                onPressed: sendOtp,
                              ),
                            ],

                            if (otpSent) ...[
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 14,
                                  bottom: 16,
                                ),
                                padding:
                                    const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: lightGreen,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'OTP મોકલ્યો છે: $emailOrPhone',
                                  style: const TextStyle(
                                    color: green,
                                  ),
                                ),
                              ),

                              TextFormField(
                                controller: otpController,
                                keyboardType:
                                    TextInputType.number,
                                maxLength: 6,
                                decoration: _decoration(
                                  label: 'OTP',
                                  hint: 'OTP દાખલ કરો',
                                  icon: Icons.password_outlined,
                                ),
                              ),

                              const SizedBox(height: 8),

                              _primaryButton(
                                label: 'ચકાસો અને લોગિન કરો',
                                icon: Icons.verified_user_outlined,
                                onPressed: verifyOtp,
                              ),

                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : sendOtp,
                                child: const Text(
                                  'ફરીથી OTP મોકલો',
                                  style: TextStyle(
                                    color: green,
                                  ),
                                ),
                              ),
                            ],
                          ],

                          if (isLoading) ...[
                            const SizedBox(height: 18),
                            const Center(
                              child: CircularProgressIndicator(
                                color: green,
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 8),

                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment:
                                WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'એકાઉન્ટ નથી? ',
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const CreateAccountPage(),
                                          ),
                                        );
                                      },
                                child: const Text(
                                  'નવું એકાઉન્ટ બનાવો',
                                  style: TextStyle(
                                    color: green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'તમારા ખેતરનો હિસાબ, હવે સરળતાથી.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _methodButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: selected ? green : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : green,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: green),
      filled: true,
      fillColor: const Color(0xFFFAFCF9),
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDCE6DC),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDCE6DC),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: green,
          width: 1.7,
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          disabledBackgroundColor: Colors.grey.shade400,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }
}
