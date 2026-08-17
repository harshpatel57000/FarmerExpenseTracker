import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ============================================================
  // USER INFORMATION
  // Later this information will come from Spring Boot / MySQL.
  // ============================================================

  String farmerName = 'ખેડૂતનું નામ';
  String mobileNumber = '9876543210';
  String email = 'example@gmail.com';
  String villageName = 'ગામનું નામ';

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  void editProfile() {
    final nameController =
        TextEditingController(text: farmerName);

    final mobileController =
        TextEditingController(text: mobileNumber);

    final emailController =
        TextEditingController(text: email);

    final villageController =
        TextEditingController(text: villageName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // ------------------------------------------------
                // TITLE
                // ------------------------------------------------

                const Text(
                  'પ્રોફાઇલમાં ફેરફાર કરો',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // NAME
                // ------------------------------------------------

                _buildTextField(
                  controller: nameController,
                  label: 'ખેડૂતનું નામ',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 14),

                // ------------------------------------------------
                // MOBILE
                // ------------------------------------------------

                _buildTextField(
                  controller: mobileController,
                  label: 'મોબાઇલ નંબર',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 14),

                // ------------------------------------------------
                // EMAIL
                // ------------------------------------------------

                _buildTextField(
                  controller: emailController,
                  label: 'ઈમેલ',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                // ------------------------------------------------
                // VILLAGE
                // ------------------------------------------------

                _buildTextField(
                  controller: villageController,
                  label: 'ગામનું નામ',
                  icon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // SAVE
                // ------------------------------------------------

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        farmerName =
                            nameController.text.trim();

                        mobileNumber =
                            mobileController.text.trim();

                        email =
                            emailController.text.trim();

                        villageName =
                            villageController.text.trim();
                      });

                      Navigator.pop(context);

                      showMessage(
                        'પ્રોફાઇલ સફળતાપૂર્વક અપડેટ થઈ',
                      );
                    },
                    icon: const Icon(
                      Icons.save_outlined,
                    ),
                    label: const Text(
                      'સાચવો',
                      style: TextStyle(
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
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'લોગઆઉટ',
          ),
          content: const Text(
            'શું તમે લોગઆઉટ કરવા માંગો છો?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'રદ કરો',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                // Later:
                // Clear login/session data
                // and navigate to LoginPage.

                showMessage(
                  'લોગઆઉટ કરવામાં આવ્યું',
                );
              },
              child: const Text(
                'લોગઆઉટ',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'મારી પ્રોફાઇલ',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              // ==================================================
              // PROFILE HEADER
              // ==================================================

              _buildProfileHeader(),

              const SizedBox(height: 24),

              // ==================================================
              // PERSONAL INFORMATION
              // ==================================================

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

              // ==================================================
              // EDIT BUTTON
              // ==================================================

              SizedBox(
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: editProfile,

                  icon: const Icon(
                    Icons.edit_outlined,
                  ),

                  label: const Text(
                    'પ્રોફાઇલમાં ફેરફાર કરો',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // LOGOUT
              // ==================================================

              SizedBox(
                height: 52,

                child: OutlinedButton.icon(
                  onPressed: logout,

                  icon: const Icon(
                    Icons.logout,
                  ),

                  label: const Text(
                    'લોગઆઉટ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.red,

                    side: const BorderSide(
                      color: Colors.red,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
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

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),

      child: Column(
        children: [
          // ------------------------------------------------------
          // PROFILE ICON
          // ------------------------------------------------------

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

          // ------------------------------------------------------
          // NAME
          // ------------------------------------------------------

          Text(
            farmerName,
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          // ------------------------------------------------------
          // VILLAGE
          // ------------------------------------------------------

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                Icons.location_on_outlined,
                size: 17,
                color: Colors.grey.shade700,
              ),

              const SizedBox(width: 4),

              Text(
                villageName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
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
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),

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

              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: Icon(
              icon,
              color: Colors.green.shade700,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

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
                  value,
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
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return TextField(
      controller: controller,

      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),

          borderSide: BorderSide(
            color:
                Colors.green.shade700,
            width: 2,
          ),
        ),
      ),
    );
  }
}