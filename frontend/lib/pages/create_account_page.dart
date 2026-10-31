
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'services/api_service.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isOtpSent = false;
  bool isLoading = false;

  static const Color green = Color(0xFF247A43);
  static const Color lightGreen = Color(0xFFEAF5EC);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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

  Future<void> runRequest(Future<void> Function() action) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      await action();
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  bool get isValidEmail {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(emailController.text.trim());
  }

  Future<void> createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isValidEmail) {
      showMessage('Please enter a valid email address');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showMessage('Passwords do not match');
      return;
    }

    await runRequest(() async {
      await ApiService.signup(
        userName: nameController.text.trim(),
        emailId: emailController.text.trim(),
        phoneNumber: mobileController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        isOtpSent = true;
        otpController.clear();
      });

      showMessage('Signup request sent. Check your email for the OTP.');
    });
  }

  Future<void> verifySignupOtp() async {
    final otp = otpController.text.trim();

    if (!isOtpSent) {
      showMessage('Please request an OTP first');
      return;
    }

    if (!isValidEmail) {
      showMessage('Please enter a valid email address');
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      showMessage('Please enter the 6-digit OTP');
      return;
    }

    await runRequest(() async {
      await ApiService.verifySignupOtp(
        emailId: emailController.text.trim(),
        otp: otp,
      );

      if (!mounted) return;

      showMessage('Account verified successfully');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F5),
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        backgroundColor: green,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/Singup_background_image.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withValues(alpha: 0.70),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 25,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLogo(),

                          const SizedBox(height: 25),

                          const Text(
                            'Create Your Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: green,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Create an account to manage your farm expenses',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 30),

                          _buildTextField(
                            controller: nameController,
                            label: 'Name',
                            hint: 'Enter your name',
                            icon: Icons.person_outline,
                            enabled: !isOtpSent,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isOtpSent,
                            validator: (value) {
                              final email = value?.trim() ?? '';

                              if (email.isEmpty) {
                                return 'Please enter your email';
                              }

                              if (!RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(email)) {
                                return 'Please enter a valid email';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: mobileController,
                            label: 'Mobile No.',
                            hint: 'Enter your mobile number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            enabled: !isOtpSent,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: passwordController,
                            label: 'Password',
                            hint: 'Create a password',
                            icon: Icons.lock_outline,
                            obscureText: !isPasswordVisible,
                            enabled: !isOtpSent,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: isOtpSent
                                  ? null
                                  : () {
                                      setState(() {
                                        isPasswordVisible =
                                            !isPasswordVisible;
                                      });
                                    },
                            ),
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Enter password again',
                            icon: Icons.lock_outline,
                            obscureText: !isConfirmPasswordVisible,
                            enabled: !isOtpSent,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }

                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                isConfirmPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: isOtpSent
                                  ? null
                                  : () {
                                      setState(() {
                                        isConfirmPasswordVisible =
                                            !isConfirmPasswordVisible;
                                      });
                                    },
                            ),
                          ),

                          if (isOtpSent) ...[
                            const SizedBox(height: 22),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: lightGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'An OTP was requested for '
                                '${emailController.text.trim()}. '
                                'Enter the 6-digit code from your email.',
                                style: const TextStyle(
                                  color: green,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              enabled: !isLoading,
                              decoration: _decoration(
                                label: 'Email OTP',
                                hint: 'Enter your 6-digit OTP',
                                icon: Icons.password_outlined,
                              ),
                            ),

                            const SizedBox(height: 8),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed:
                                    isLoading ? null : verifySignupOtp,
                                icon: const Icon(
                                  Icons.verified_user_outlined,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Verify OTP & Create Account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: green,
                                  disabledBackgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        isOtpSent = false;
                                        otpController.clear();
                                      });
                                    },
                              child: const Text(
                                'Edit account details',
                                style: TextStyle(color: green),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 25),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: isLoading ? null : createAccount,
                                icon: const Icon(
                                  Icons.mark_email_read_outlined,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Send Email OTP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: green,
                                  disabledBackgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],

                          if (isLoading) ...[
                            const SizedBox(height: 18),
                            const Center(
                              child: CircularProgressIndicator(
                                color: green,
                              ),
                            ),
                          ],

                          const SizedBox(height: 15),

                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text(
                              'Already have an account? Login',
                              style: TextStyle(color: green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: lightGreen,
        ),
        child: const Icon(
          Icons.agriculture_rounded,
          size: 45,
          color: green,
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
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDCE6DC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDCE6DC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: green, width: 1.7),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      autocorrect: false,
      validator: validator,
      decoration: _decoration(
        label: label,
        hint: hint,
        icon: icon,
      ).copyWith(suffixIcon: suffixIcon),
    );
  }
}
