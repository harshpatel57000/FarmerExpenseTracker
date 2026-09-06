import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'region_page.dart';

class VillagePage extends StatefulWidget {
  const VillagePage({super.key});

  @override
  State<VillagePage> createState() => _VillagePageState();
}

class _VillagePageState extends State<VillagePage> {
  final TextEditingController villageController =
      TextEditingController();

  final TextEditingController pincodeController =
      TextEditingController();

  List<dynamic> villages = [];

  bool loading = false;
  bool loadingVillages = true;

  @override
  void initState() {
    super.initState();
    loadVillages();
  }

  // ============================================================
  // GET VILLAGES
  // ============================================================

  Future<void> loadVillages() async {
    setState(() {
      loadingVillages = true;
    });

    try {
      final result = await ApiService.getVillages();

      if (!mounted) return;

      setState(() {
        villages = result;
        loadingVillages = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingVillages = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // ============================================================
  // ADD VILLAGE
  // ============================================================

  Future<void> addVillage() async {
    final name = villageController.text.trim();
    final pincode = pincodeController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ગામનું નામ દાખલ કરો'),
        ),
      );
      return;
    }

    if (pincode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('પિનકોડ દાખલ કરો'),
        ),
      );
      return;
    }

    if (pincode.length != 6 ||
        int.tryParse(pincode) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('યોગ્ય 6 અંકનો પિનકોડ દાખલ કરો'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await ApiService.addVillage(
        name: name,
        pinCode: pincode,
      );

      if (!mounted) return;

      villageController.clear();
      pincodeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ગામ સફળતાપૂર્વક ઉમેરાયું'),
        ),
      );

      await loadVillages();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ============================================================
  // SELECT VILLAGE
  // ============================================================

  void selectVillage(int villageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRegionPage(
          villageId: villageId,
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
    pincodeController.dispose();
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ગામ પસંદ કરો'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // ====================================================
            // ADD VILLAGE
            // ====================================================

            TextField(
              controller: villageController,
              decoration: const InputDecoration(
                labelText: 'ગામનું નામ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: pincodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'પિનકોડ',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: loading ? null : addVillage,

                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('ગામ ઉમેરો'),
              ),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // VILLAGE LIST TITLE
            // ====================================================

            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                'ગામની યાદી',

                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ====================================================
            // VILLAGE LIST
            // ====================================================

            Expanded(
              child: loadingVillages

                  ? const Center(
                      child: CircularProgressIndicator(),
                    )

                  : villages.isEmpty

                      ? const Center(
                          child: Text(
                            'કોઈ ગામ મળ્યું નથી',
                          ),
                        )

                      : ListView.builder(
                          itemCount: villages.length,

                          itemBuilder: (context, index) {
                            final village = villages[index];

                            return Card(
                              child: ListTile(

                                title: Text(
                                  village['name']?.toString() ?? '',
                                ),

                                subtitle: Text(
                                  'પિનકોડ: ${village['pinCode'] ?? ''}',
                                ),

                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                ),

                                onTap: () {
                                  final id = village['id'];

                                  if (id == null) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Village ID not found',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  selectVillage(
                                    int.parse(id.toString()),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}