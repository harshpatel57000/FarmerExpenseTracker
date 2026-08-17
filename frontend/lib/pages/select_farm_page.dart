import 'package:flutter/material.dart';

import 'crop_cycle_page.dart';
import 'farm_expense_page.dart';

class SelectFarmPage extends StatelessWidget {
  const SelectFarmPage({super.key});

  // ============================================================
  // DEMO FARM DATA
  // ============================================================

  final List<Map<String, dynamic>> farms = const [
    {
      'id': 1,
      'regionName': 'મુખ્ય વિસ્તાર',
      'farmName': 'રમેશભાઈનું ખેતર',
      'area': '3 એકર',
      'currentCrop': 'કપાસ',
    },
    {
      'id': 2,
      'regionName': 'મુખ્ય વિસ્તાર',
      'farmName': 'મહેશભાઈનું ખેતર',
      'area': '2 એકર',
      'currentCrop': 'ઘઉં',
    },
    {
      'id': 3,
      'regionName': 'મુખ્ય વિસ્તાર',
      'farmName': 'ભરતભાઈનું ખેતર',
      'area': '4 એકર',
      'currentCrop': 'મગફળી',
    },
  ];

  // ============================================================
  // OPEN CROP CYCLE
  // ============================================================

  void openCropCycle(BuildContext context, Map<String, dynamic> farm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropCyclePage(
          regionName: farm['regionName'],
          farmName: farm['farmName'],
          farmId: farm['id'],
        ),
      ),
    );
  }

  // ============================================================
  // OPEN FARM EXPENSE
  // ============================================================

  void openFarmExpense(BuildContext context, Map<String, dynamic> farm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmExpensePage(
          regionName: farm['regionName'],
          farmName: farm['farmName'],
          farmId: farm['id'],
          cropType: farm['currentCrop'],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ખેતર પસંદ કરો'), centerTitle: true),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            // ==================================================
            // REGION HEADER
            // ==================================================
            _buildRegionHeader(),

            const SizedBox(height: 25),

            // ==================================================
            // FARM TITLE
            // ==================================================
            const Text(
              'તમારા ખેતર',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              '${farms.length} ખેતર ઉપલબ્ધ છે',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // FARM LIST
            // ==================================================
            ...farms.map(
              (farm) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: _buildFarmCard(context, farm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REGION HEADER
  // ============================================================

  Widget _buildRegionHeader() {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),

      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              Icons.location_on_outlined,
              color: Colors.green.shade700,
              size: 32,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'વિસ્તાર',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                SizedBox(height: 3),

                Text(
                  'મુખ્ય વિસ્તાર',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 2),

                Text(
                  'આ વિસ્તારના ખેતર',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FARM CARD
  // ============================================================

  Widget _buildFarmCard(BuildContext context, Map<String, dynamic> farm) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // ==================================================
            // FARM INFORMATION
            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // FARM ICON
                // ==================================================
                Container(
                  height: 54,
                  width: 54,

                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(
                    Icons.agriculture_outlined,
                    color: Colors.green.shade700,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 14),

                // ==================================================
                // FARM DETAILS
                // ==================================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        farm['farmName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'જમીન: ${farm['area']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Icon(
                            Icons.grass_outlined,
                            size: 16,
                            color: Colors.green.shade700,
                          ),

                          const SizedBox(width: 5),

                          Flexible(
                            child: Text(
                              'ચાલુ પાક: ${farm['currentCrop']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ==================================================
                // CROP CYCLE BUTTON
                // TOP RIGHT
                // ==================================================
                _buildCropCycleButton(context, farm),
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // FARM EXPENSE BUTTON
            // BOTTOM
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: () {
                  openFarmExpense(context, farm);
                },

                icon: const Icon(Icons.add_card_outlined),

                label: const Text(
                  'ખેતરનો ખર્ચ ઉમેરો',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade50,

                  foregroundColor: Colors.green.shade800,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CROP CYCLE BUTTON
  // ============================================================

  Widget _buildCropCycleButton(
    BuildContext context,
    Map<String, dynamic> farm,
  ) {
    return InkWell(
      onTap: () {
        openCropCycle(context, farm);
      },

      borderRadius: BorderRadius.circular(12),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

        decoration: BoxDecoration(
          color: Colors.green.shade50,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(color: Colors.green.shade200),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(Icons.grass, size: 22, color: Colors.green.shade700),

            const SizedBox(height: 3),

            Text(
              'પાક સાયકલ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
