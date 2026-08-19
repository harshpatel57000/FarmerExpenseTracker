import 'package:flutter/material.dart';

import 'agro_expense_page.dart';
import 'total_expense_page.dart';
import 'select_farm_page.dart';
import 'profile_page.dart';
import 'add_region_page.dart';

class HomePage extends StatelessWidget {
  final int villageId;
   HomePage({super.key, required this.villageId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        title: const Text('ખેતી ખર્ચ ટ્રેકર'),
        centerTitle: true,

        actions: [
          // ========================================================
          // PROFILE
          // ========================================================
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // ======================================================
            // WELCOME
            // ======================================================
            const Text(
              'સ્વાગત છે',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              'તમારા ખેતીના ખર્ચનું સંચાલન કરો',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),

            const SizedBox(height: 25),

            // ======================================================
            // ADD FARM EXPENSE
            // ======================================================
            _buildMenuCard(
              icon: Icons.agriculture_outlined,

              title: 'ખેતરનો ખર્ચ ઉમેરો',

              subtitle: 'ખેતરમાં થયેલો ખર્ચ નોંધો',

              onTap: () {
                // --------------------------------------------------
                // IMPORTANT
                //
                // SelectFarmPage → FarmExpensePage
                //
                // Later:
                //
                // Village → Region → Farm
                //
                // --------------------------------------------------

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectFarmPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // ======================================================
            // ADD AGRO EXPENSE
            // ======================================================
            _buildMenuCard(
              icon: Icons.inventory_2_outlined,

              title: 'કૃષિ ઉત્પાદનનો ખર્ચ ઉમેરો',

              subtitle: 'ખાતર, દવા અને અન્ય કૃષિ વસ્તુની ખરીદી નોંધો',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AgroExpensePage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // ======================================================
            // ADD NEW FARM / REGION
            // ======================================================
            _buildMenuCard(
              icon: Icons.add_business_outlined,

              title: 'નવું ખેતર / વિસ્તાર ઉમેરો',

              subtitle: 'નવો વિસ્તાર અથવા ખેતર ઉમેરો',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRegionPage(villageId: villageId),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // ======================================================
            // TOTAL EXPENSE
            // ======================================================
            _buildMenuCard(
              icon: Icons.bar_chart_outlined,

              title: 'કુલ ખેતી ખર્ચ જુઓ',

              subtitle: 'વિસ્તાર અને ખેતર પ્રમાણે ખર્ચ જુઓ',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TotalExpensePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // MENU CARD
  // ==============================================================

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(12),

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Row(
            children: [
              // ====================================================
              // ICON
              // ====================================================
              Container(
                height: 55,
                width: 55,

                decoration: BoxDecoration(
                  color: Colors.green.shade50,

                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(icon, size: 30, color: Colors.green.shade700),
              ),

              const SizedBox(width: 16),

              // ====================================================
              // TEXT
              // ====================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,

                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // ====================================================
              // ARROW
              // ====================================================
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
