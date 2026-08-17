import 'package:flutter/material.dart';
import 'create_account_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController mobileController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController otpController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool isPasswordVisible = false;

  bool showOtp = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    otpController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  void loginUser() {
    final email =
        emailController.text.trim();

    final mobile =
        mobileController.text.trim();

    final password =
        passwordController.text.trim();

    // Email OR Mobile required
    if (email.isEmpty && mobile.isEmpty) {
      showMessage(
        'ઈમેલ અથવા મોબાઈલ નંબર દાખલ કરો',
      );
      return;
    }

    // Password required
    if (password.isEmpty) {
      showMessage(
        'પાસવર્ડ દાખલ કરો',
      );
      return;
    }

    // ----------------------------------------------------------
    // હાલ માટે સીધું Home Page પર જાય છે.
    //
    // પછી Spring Boot API સાથે login verification જોડશું.
    // ----------------------------------------------------------

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const HomePage(),
      ),
    );
  }

  // ============================================================
  // SHOW OTP
  // ============================================================

  void showOtpLogin() {
    setState(() {
      showOtp = true;
    });
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  void verifyOtp() {
    final otp =
        otpController.text.trim();

    if (otp.isEmpty) {
      showMessage(
        'OTP દાખલ કરો',
      );
      return;
    }

    // ----------------------------------------------------------
    // TODO:
    // Spring Boot OTP API સાથે જોડવાનું બાકી છે.
    // ----------------------------------------------------------

    showMessage(
      'OTP ચકાસણી કરવામાં આવી',
    );
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  void createAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CreateAccountPage(),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),

            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 450,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,

                children: [

                  // ==================================================
                  // LOGO
                  // ==================================================

                  _buildLogo(),

                  const SizedBox(
                    height: 35,
                  ),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  const Text(
                    'તમારું સ્વાગત છે.',
                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'તમારા ખેતીના ખર્ચનું સંચાલન કરવા માટે લોગિન કરો',
                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 35,
                  ),

                  // ==================================================
                  // EMAIL
                  // ==================================================

                  _buildTextField(
                    controller:
                        emailController,

                    label:
                        'ઈમેલ',

                    hint:
                        'તમારો ઈમેલ દાખલ કરો',

                    icon:
                        Icons.email_outlined,

                    keyboardType:
                        TextInputType
                            .emailAddress,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // MOBILE
                  // ==================================================

                  _buildTextField(
                    controller:
                        mobileController,

                    label:
                        'મોબાઈલ નંબર',

                    hint:
                        'તમારો મોબાઈલ નંબર દાખલ કરો',

                    icon:
                        Icons.phone_outlined,

                    keyboardType:
                        TextInputType.phone,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  _buildTextField(
                    controller:
                        passwordController,

                    label:
                        'પાસવર્ડ',

                    hint:
                        'તમારો પાસવર્ડ દાખલ કરો',

                    icon:
                        Icons.lock_outline,

                    obscureText:
                        !isPasswordVisible,

                    suffixIcon:
                        IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons
                                .visibility_off
                            : Icons
                                .visibility,
                      ),

                      onPressed: () {
                        setState(() {
                          isPasswordVisible =
                              !isPasswordVisible;
                        });
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // ==================================================
                  // LOGIN BUTTON
                  // ==================================================

                  SizedBox(
                    height: 52,

                    child:
                        ElevatedButton(
                      onPressed:
                          loginUser,

                      style:
                          ElevatedButton
                              .styleFrom(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),

                      child:
                          const Text(
                        'લોગિન',
                        style:
                            TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // OTP LOGIN
                  // ==================================================

                  OutlinedButton.icon(
                    onPressed:
                        showOtpLogin,

                    icon:
                        const Icon(
                      Icons.sms_outlined,
                    ),

                    label:
                        const Text(
                      'OTP વડે લોગિન કરો',
                    ),

                    style:
                        OutlinedButton
                            .styleFrom(
                      minimumSize:
                          const Size(
                        double.infinity,
                        50,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // OTP SECTION
                  // ==================================================

                  if (showOtp) ...[
                    const SizedBox(
                      height: 22,
                    ),

                    _buildTextField(
                      controller:
                          otpController,

                      label:
                          'OTP',

                      hint:
                          'OTP દાખલ કરો',

                      icon:
                          Icons
                              .password_outlined,

                      keyboardType:
                          TextInputType
                              .number,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    SizedBox(
                      height: 48,

                      child:
                          ElevatedButton(
                        onPressed:
                            verifyOtp,

                        child:
                            const Text(
                          'OTP ચકાસો',
                          style:
                              TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 28,
                  ),

                  // ==================================================
                  // CREATE ACCOUNT
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [

                      const Text(
                        'એકાઉન્ટ નથી? ',

                        style:
                            TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),

                      TextButton(
                        onPressed:
                            createAccount,

                        child:
                            const Text(
                          'નવું એકાઉન્ટ બનાવો',

                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo() {
    return Center(
      child: Container(
        height: 90,
        width: 90,

        decoration:
            BoxDecoration(
          borderRadius:
              BorderRadius.circular(
            22,
          ),

          color:
              Colors.green.shade50,
        ),

        child:
            Icon(
          Icons.agriculture,
          size: 50,
          color:
              Colors.green.shade700,
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController
        controller,

    required String label,

    required String hint,

    required IconData icon,

    bool obscureText = false,

    TextInputType keyboardType =
        TextInputType.text,

    Widget? suffixIcon,
  }) {
    return TextField(
      controller:
          controller,

      obscureText:
          obscureText,

      keyboardType:
          keyboardType,

      decoration:
          InputDecoration(
        labelText:
            label,

        hintText:
            hint,

        prefixIcon:
            Icon(icon),

        suffixIcon:
            suffixIcon,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              const BorderSide(
            color: Colors.grey,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              BorderSide(
            color:
                Colors.green.shade700,

            width: 2,
          ),
        ),
      ),
    );
  }
}