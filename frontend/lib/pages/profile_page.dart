
import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart';
import 'services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Profile data received from Spring Boot.
  String farmerName = '';
  String mobileNumber = '';
  String email = '';
  String villageName = 'ગામ ઉમેરેલ નથી';

  bool isLoading = true;
  bool isSaving = false;
  String? profileError;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ============================================================
  // LOAD PROFILE FROM BACKEND
  // ============================================================

  Future<void> loadProfile() async {
    setState(() {
      isLoading = true;
      profileError = null;
    });

    try {
      final profile = await ApiService.getProfile();

      final dynamic villages = profile['villages'];

      if (!mounted) return;

      setState(() {
        farmerName = profile['userName']?.toString() ?? '';
        email = profile['emailId']?.toString() ?? '';
        mobileNumber = profile['phoneNumber']?.toString() ?? '';

        if (villages is List && villages.isNotEmpty) {
          villageName = villages.join(', ');
        } else {
          villageName = 'ગામ ઉમેરેલ નથી';
        }

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        profileError = e.toString();
      });
    }
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Future<void> editProfile() async {
    final nameController = TextEditingController(
      text: farmerName,
    );

    final mobileController = TextEditingController(
      text: mobileNumber,
    );

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom:
                      MediaQuery.of(sheetContext).viewInsets.bottom +
                          20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'પ્રોફાઇલમાં ફેરફાર કરો',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 22),

                      _buildTextField(
                        controller: nameController,
                        label: 'ખેડૂતનું નામ',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 14),

                      _buildTextField(
                        controller: mobileController,
                        label: 'મોબાઇલ નંબર',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 14),

                      // Email is read-only in the current API.
                      _buildReadOnlyField(
                        label: 'ઈમેલ',
                        value: email,
                        icon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 14),

                      // Village is read-only in the current API.
                      _buildReadOnlyField(
                        label: 'ગામનું નામ',
                        value: villageName,
                        icon: Icons.location_on_outlined,
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final name =
                                      nameController.text.trim();
                                  final phone =
                                      mobileController.text.trim();

                                  if (name.isEmpty) {
                                    showMessage(
                                      'ખેડૂતનું નામ દાખલ કરો',
                                    );
                                    return;
                                  }

                                  if (!RegExp(r'^[0-9]{10}$')
                                      .hasMatch(phone)) {
                                    showMessage(
                                      'સાચો 10 અંકનો મોબાઇલ નંબર દાખલ કરો',
                                    );
                                    return;
                                  }

                                  setSheetState(() {
                                    isSaving = true;
                                  });

                                  try {
                                    final updated =
                                        await ApiService.updateProfile(
                                      userName: name,
                                      phoneNumber: phone,
                                    );

                                    if (!mounted) return;

                                    setState(() {
                                      farmerName =
                                          updated['userName']
                                                  ?.toString() ??
                                              name;

                                      mobileNumber =
                                          updated['phoneNumber']
                                                  ?.toString() ??
                                              phone;
                                    });

                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }

                                    showMessage(
                                      'પ્રોફાઇલ સફળતાપૂર્વક અપડેટ થઈ',
                                    );
                                  } catch (e) {
                                    if (!mounted) return;

                                    setSheetState(() {
                                      isSaving = false;
                                    });

                                    showMessage(
                                      'પ્રોફાઇલ અપડેટ થઈ શકી નથી. '
                                      'મોબાઇલ નંબર પહેલેથી નોંધાયેલ છે '
                                      'કે નહીં તે તપાસો.',
                                    );
                                  }
                                },
                          icon: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            isSaving ? 'સાચવી રહ્યા છીએ...' : 'સાચવો',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      mobileController.dispose();
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  
Future<void> logout() async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('લોગઆઉટ'),
        content: const Text(
          'શું તમે લોગઆઉટ કરવા માંગો છો?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('રદ કરો'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('લોગઆઉટ'),
          ),
        ],
      );
    },
  );

  // User cancelled logout.
  if (shouldLogout != true || !mounted) {
    return;
  }

  // Call backend logout and clear local session.
  try {
    await ApiService.logout();
  } catch (e) {
    // ApiService.logout() clears local tokens in its finally block.
    // Continue to LoginPage even if the backend is unreachable.
    debugPrint('Logout request failed: $e');
  }

  if (!mounted) return;

  // Remove all previous screens so Back cannot reopen Home/Profile.
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const LoginPage(),
    ),
    (route) => false,
  );
}

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('મારી પ્રોફાઇલ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (profileError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'પ્રોફાઇલ લોડ થઈ શકી નથી',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'ઇન્ટરનેટ, લોગિન અને સર્વર તપાસીને ફરી પ્રયાસ કરો.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: loadProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('ફરી પ્રયાસ કરો'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(),

            const SizedBox(height: 24),

            const Text(
              'વ્યક્તિગત માહિતી',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.person_outline,
              title: 'ખેડૂતનું નામ',
              value: farmerName,
            ),

            _buildInfoCard(
              icon: Icons.phone_outlined,
              title: 'મોબાઇલ નંબર',
              value: mobileNumber,
            ),

            _buildInfoCard(
              icon: Icons.email_outlined,
              title: 'ઈમેલ',
              value: email,
            ),

            _buildInfoCard(
              icon: Icons.location_on_outlined,
              title: 'ગામ',
              value: villageName,
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : editProfile,
                icon: const Icon(Icons.edit_outlined),
                label: const Text(
                  'પ્રોફાઇલમાં ફેરફાર કરો',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  'લોગઆઉટ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green.shade300,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 52,
              color: Colors.green.shade700,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            farmerName.isEmpty ? 'ખેડૂતનું નામ' : farmerName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 17,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  villageName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.green.shade700,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value.isEmpty ? 'ઉપલબ્ધ નથી' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EDITABLE TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.green.shade700,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // READ-ONLY FIELD
  // ============================================================

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
