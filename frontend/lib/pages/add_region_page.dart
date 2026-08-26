import 'package:flutter/material.dart';

class AddRegionPage extends StatefulWidget {
  const AddRegionPage({super.key});

  @override
  State<AddRegionPage> createState() => _AddRegionPageState();
}

class _AddRegionPageState extends State<AddRegionPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController villageController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController regionController = TextEditingController();

  // ============================================================
  // LOCAL FRONTEND DATA
  //
  // Backend will be connected later.
  // ============================================================

  final List<Map<String, dynamic>> villages = [
    {
      'id': 1,
      'name': 'Jalsan',
      'pinCode': '388170',
    },
    {
      'id': 2,
      'name': 'Khambhat',
      'pinCode': '388620',
    },
  ];

  final List<Map<String, dynamic>> regions = [];

  // Selected village
  Map<String, dynamic>? selectedVillage;

  // ============================================================
  // ADD VILLAGE
  // ============================================================

  void showAddVillageDialog() {
    villageController.clear();
    pinCodeController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ગામ ઉમેરો'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: villageController,
                decoration: InputDecoration(
                  labelText: 'ગામનું નામ',
                  hintText: 'ઉદાહરણ: જલસણ',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: pinCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Postal PIN Code',
                  hintText: 'ઉદાહરણ: 388170',
                  prefixIcon: const Icon(Icons.pin_drop_outlined),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('રદ કરો'),
            ),

            ElevatedButton(
              onPressed: () {
                addVillage(dialogContext);
              },
              child: const Text('ઉમેરો'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ADD VILLAGE LOGIC
  // ============================================================

  void addVillage(BuildContext dialogContext) {
    final String villageName = villageController.text.trim();
    final String pinCode = pinCodeController.text.trim();

    // Check village name
    if (villageName.isEmpty) {
      showMessage('ગામનું નામ દાખલ કરો');
      return;
    }

    // Check PIN format
    if (!RegExp(r'^\d{6}$').hasMatch(pinCode)) {
      showMessage('યોગ્ય 6 અંકનો PIN Code દાખલ કરો');
      return;
    }

    // Check duplicate PIN
    final bool duplicatePin = villages.any(
      (village) => village['pinCode'] == pinCode,
    );

    if (duplicatePin) {
      showMessage(
        'આ PIN Code સાથેનું ગામ પહેલેથી ઉમેરાયેલ છે',
      );
      return;
    }

    // Check duplicate village name
    final bool duplicateVillage = villages.any(
      (village) =>
          village['name'].toString().toLowerCase() ==
          villageName.toLowerCase(),
    );

    if (duplicateVillage) {
      showMessage('આ ગામ પહેલેથી ઉમેરાયેલ છે');
      return;
    }

    // Generate temporary frontend ID.
    // Backend ID will be used later.
    final int newId = villages.isEmpty
        ? 1
        : villages
                .map((village) => village['id'] as int)
                .reduce((a, b) => a > b ? a : b) +
            1;

    final Map<String, dynamic> newVillage = {
      'id': newId,
      'name': villageName,
      'pinCode': pinCode,
    };

    setState(() {
      villages.add(newVillage);
      selectedVillage = newVillage;
      regions.clear();
    });

    Navigator.pop(dialogContext);

    showMessage('ગામ સફળતાપૂર્વક ઉમેરાયું');
  }

  // ============================================================
  // SELECT VILLAGE
  // ============================================================

  void selectVillage(Map<String, dynamic> village) {
    setState(() {
      selectedVillage = village;

      // For now local data.
      // Later this will load regions from backend
      // using village['id'].
      regions.clear();

      // Demo data
      if (village['id'] == 1) {
        regions.addAll([
          {
            'id': 1,
            'name': 'North Area',
          },
          {
            'id': 2,
            'name': 'South Area',
          },
        ]);
      }
    });

    showMessage('${village['name']} પસંદ કર્યું');
  }

  // ============================================================
  // ADD REGION
  // ============================================================

  void showAddRegionDialog() {
    if (selectedVillage == null) {
      showMessage('પહેલા ગામ પસંદ કરો');
      return;
    }

    regionController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('વિસ્તાર ઉમેરો'),

          content: TextField(
            controller: regionController,
            decoration: InputDecoration(
              labelText: 'વિસ્તારનું નામ',
              hintText: 'ઉદાહરણ: નદી વાળો વિસ્તાર',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('રદ કરો'),
            ),

            ElevatedButton(
              onPressed: () {
                addRegion(dialogContext);
              },
              child: const Text('ઉમેરો'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ADD REGION LOGIC
  // ============================================================

  void addRegion(BuildContext dialogContext) {
    final String regionName = regionController.text.trim();

    if (regionName.isEmpty) {
      showMessage('વિસ્તારનું નામ દાખલ કરો');
      return;
    }

    // Check duplicate region inside selected village
    final bool duplicateRegion = regions.any(
      (region) =>
          region['name'].toString().toLowerCase() ==
          regionName.toLowerCase(),
    );

    if (duplicateRegion) {
      showMessage('આ વિસ્તારમાં પહેલેથી ઉમેરાયેલ છે');
      return;
    }

    final int newId = regions.isEmpty
        ? 1
        : regions
                .map((region) => region['id'] as int)
                .reduce((a, b) => a > b ? a : b) +
            1;

    setState(() {
      regions.add({
        'id': newId,
        'name': regionName,
      });
    });

    Navigator.pop(dialogContext);

    showMessage('વિસ્તાર સફળતાપૂર્વક ઉમેરાયો');
  }

  // ============================================================
  // DELETE REGION
  // ============================================================

  void deleteRegion(int index) {
    final String regionName = regions[index]['name'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('વિસ્તાર કાઢી નાખવો?'),

          content: Text(
            '$regionName કાઢી નાખવામાં આવશે.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('રદ કરો'),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  regions.removeAt(index);
                });

                Navigator.pop(dialogContext);

                showMessage('વિસ્તાર કાઢી નાખવામાં આવ્યો');
              },
              child: const Text('કાઢી નાખો'),
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
        title: const Text('ગામ અને વિસ્તાર'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                'ગામ પસંદ કરો',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'પહેલા ગામ પસંદ કરો અથવા નવું ગામ ઉમેરો.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // ADD VILLAGE BUTTON
              // ==================================================

              SizedBox(
                height: 52,

                child: OutlinedButton.icon(
                  onPressed: showAddVillageDialog,

                  icon: const Icon(Icons.add),

                  label: const Text(
                    'નવું ગામ ઉમેરો',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // VILLAGE LIST
              // ==================================================

              ...List.generate(
                villages.length,
                (index) {
                  return _buildVillageCard(villages[index]);
                },
              ),

              const SizedBox(height: 30),

              // ==================================================
              // SELECTED VILLAGE
              // ==================================================

              if (selectedVillage != null) ...[
                const Divider(),

                const SizedBox(height: 20),

                Text(
                  'પસંદ કરેલ ગામ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  selectedVillage!['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  'PIN: ${selectedVillage!['pinCode']}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // REGION SECTION
                // ==================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      'વિસ્તારો',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    TextButton.icon(
                      onPressed: showAddRegionDialog,

                      icon: const Icon(Icons.add),

                      label: const Text(
                        'વિસ્તાર ઉમેરો',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                if (regions.isEmpty)
                  _buildEmptyRegionState(),

                if (regions.isNotEmpty)
                  ...List.generate(
                    regions.length,
                    (index) {
                      return _buildRegionCard(
                        regions[index],
                        index,
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // VILLAGE CARD
  // ============================================================

  Widget _buildVillageCard(
    Map<String, dynamic> village,
  ) {
    final bool isSelected =
        selectedVillage != null &&
        selectedVillage!['id'] == village['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),

        side: BorderSide(
          color: isSelected
              ? Colors.green
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),

      child: ListTile(
        leading: CircleAvatar(
          child: const Icon(
            Icons.location_city_outlined,
          ),
        ),

        title: Text(
          village['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          'PIN: ${village['pinCode']}',
        ),

        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: Colors.green,
              )
            : const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

        onTap: () {
          selectVillage(village);
        },
      ),
    );
  }

  // ============================================================
  // EMPTY REGION
  // ============================================================

  Widget _buildEmptyRegionState() {
    return Container(
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 45,
            color: Colors.grey.shade500,
          ),

          const SizedBox(height: 10),

          const Text(
            'આ ગામમાં હજુ કોઈ વિસ્તાર નથી.',
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'ઉપરથી નવો વિસ્તાર ઉમેરો.',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REGION CARD
  // ============================================================

  Widget _buildRegionCard(
    Map<String, dynamic> region,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(
            Icons.location_on_outlined,
          ),
        ),

        title: Text(
          region['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          'ગામ: ${selectedVillage!['name']}',
        ),

        trailing: IconButton(
          onPressed: () {
            deleteRegion(index);
          },

          icon: const Icon(
            Icons.delete_outline,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    villageController.dispose();
    pinCodeController.dispose();
    regionController.dispose();

    super.dispose();
  }
}