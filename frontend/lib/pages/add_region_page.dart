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

  final TextEditingController regionController =
      TextEditingController();

  final TextEditingController farmController =
      TextEditingController();

  // ============================================================
  // SAVED DATA
  //
  // Temporary local data for frontend development.
  //
  // Later this will come from Spring Boot + MySQL.
  // ============================================================

  final List<Map<String, dynamic>> regions = [];

  // ============================================================
  // ADD REGION
  // ============================================================

  void addRegion() {
    final String regionName =
        regionController.text.trim();

    if (regionName.isEmpty) {
      showMessage('વિસ્તારનું નામ દાખલ કરો');
      return;
    }

    // Check duplicate region
    final bool alreadyExists = regions.any(
      (region) =>
          region['name'].toString().toLowerCase() ==
          regionName.toLowerCase(),
    );

    if (alreadyExists) {
      showMessage('આ વિસ્તાર પહેલેથી ઉમેરાયેલ છે');
      return;
    }

    setState(() {
      regions.add({
        'name': regionName,

        // Every region starts with empty farm list.
        'farms': <String>[],

        // Future crop cycles can be stored here.
        'cropCycles': <Map<String, dynamic>>[],
      });

      regionController.clear();
    });

    showMessage('વિસ્તાર સફળતાપૂર્વક ઉમેરાયો');
  }

  // ============================================================
  // ADD FARM TO REGION
  // ============================================================

  void addFarm(int regionIndex) {
    farmController.clear();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'ખેતર ઉમેરો',
          ),

          content: TextField(
            controller: farmController,

            decoration: InputDecoration(
              labelText: 'ખેતરનું નામ',
              hintText: 'ઉદાહરણ: ખેતર નંબર 1',

              prefixIcon: const Icon(
                Icons.agriculture_outlined,
              ),

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
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
                final String farmName =
                    farmController.text.trim();

                if (farmName.isEmpty) {
                  showMessage(
                    'ખેતરનું નામ દાખલ કરો',
                  );
                  return;
                }

                final List<String> farms =
                    List<String>.from(
                  regions[regionIndex]['farms'],
                );

                // Check duplicate farm
                if (farms.any(
                  (farm) =>
                      farm.toLowerCase() ==
                      farmName.toLowerCase(),
                )) {
                  showMessage(
                    'આ ખેતર પહેલેથી ઉમેરાયેલ છે',
                  );
                  return;
                }

                setState(() {
                  regions[regionIndex]['farms']
                      .add(farmName);
                });

                Navigator.pop(context);

                showMessage(
                  'ખેતર સફળતાપૂર્વક ઉમેરાયું',
                );
              },

              child: const Text(
                'ઉમેરો',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DELETE REGION
  // ============================================================

  void deleteRegion(int index) {
    final String regionName =
        regions[index]['name'];

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'વિસ્તાર કાઢી નાખવો?',
          ),

          content: Text(
            '$regionName અને તેની અંદરના ખેતરો કાઢી નાખવામાં આવશે.',
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
                setState(() {
                  regions.removeAt(index);
                });

                Navigator.pop(context);

                showMessage(
                  'વિસ્તાર કાઢી નાખવામાં આવ્યો',
                );
              },

              child: const Text(
                'કાઢી નાખો',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DELETE FARM
  // ============================================================

  void deleteFarm(
    int regionIndex,
    int farmIndex,
  ) {
    setState(() {
      regions[regionIndex]['farms']
          .removeAt(farmIndex);
    });

    showMessage(
      'ખેતર કાઢી નાખવામાં આવ્યું',
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
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
      appBar: AppBar(
        title: const Text(
          'વિસ્તાર અને ખેતર',
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [

              // ==================================================
              // HEADER
              // ==================================================

              const Text(
                'તમારા વિસ્તાર ઉમેરો',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'તમારા ગામ પ્રમાણે વિસ્તારનું નામ આપો અને તેમાં ખેતરો ઉમેરો.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // REGION INPUT
              // ==================================================

              TextField(
                controller:
                    regionController,

                decoration:
                    InputDecoration(
                  labelText:
                      'વિસ્તારનું નામ',

                  hintText:
                      'ઉદાહરણ: નદી વાળો વિસ્તાર',

                  prefixIcon:
                      const Icon(
                    Icons.location_on_outlined,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // ADD REGION BUTTON
              // ==================================================

              SizedBox(
                height: 52,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      addRegion,

                  icon:
                      const Icon(
                    Icons.add_location_alt_outlined,
                  ),

                  label:
                      const Text(
                    'વિસ્તાર ઉમેરો',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // SAVED REGIONS
              // ==================================================

              if (regions.isEmpty)
                _buildEmptyState(),

              if (regions.isNotEmpty)
                ...List.generate(
                  regions.length,
                  (index) {
                    return _buildRegionCard(
                      index,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      padding:
          const EdgeInsets.all(30),

      decoration:
          BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Column(
        children: [

          Icon(
            Icons.location_off_outlined,
            size: 50,
            color: Colors.grey.shade500,
          ),

          const SizedBox(height: 12),

          const Text(
            'હજુ કોઈ વિસ્તાર ઉમેરાયો નથી',
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'ઉપરથી તમારો પ્રથમ વિસ્તાર ઉમેરો.',
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
    int regionIndex,
  ) {
    final Map<String, dynamic> region =
        regions[regionIndex];

    final String regionName =
        region['name'];

    final List<String> farms =
        List<String>.from(
      region['farms'],
    );

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 15,
      ),

      elevation: 2,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // REGION HEADER
            // ==================================================

            Row(
              children: [

                Container(
                  padding:
                      const EdgeInsets.all(
                    10,
                  ),

                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                    color: Colors
                        .green
                        .withValues(
                      alpha: 0.1,
                    ),
                  ),

                  child:
                      const Icon(
                    Icons.location_on_outlined,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        'વિસ્તાર',
                        style:
                            TextStyle(
                          fontSize: 12,
                          color:
                              Colors.grey,
                        ),
                      ),

                      Text(
                        regionName,

                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    deleteRegion(
                      regionIndex,
                    );
                  },

                  icon:
                      const Icon(
                    Icons.delete_outline,
                  ),
                ),
              ],
            ),

            const Divider(
              height: 25,
            ),

            // ==================================================
            // FARM TITLE
            // ==================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                Text(
                  'ખેતરો (${farms.length})',

                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                TextButton.icon(
                  onPressed: () {
                    addFarm(
                      regionIndex,
                    );
                  },

                  icon:
                      const Icon(
                    Icons.add,
                  ),

                  label:
                      const Text(
                    'ખેતર ઉમેરો',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // ==================================================
            // FARMS
            // ==================================================

            if (farms.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.all(
                  12,
                ),

                child:
                    const Text(
                  'આ વિસ્તારમાં હજુ કોઈ ખેતર નથી.',
                  style:
                      TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),
              ),

            if (farms.isNotEmpty)
              ...List.generate(
                farms.length,
                (farmIndex) {
                  return _buildFarmRow(
                    regionIndex,
                    farmIndex,
                    farms[farmIndex],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FARM ROW
  // ============================================================

  Widget _buildFarmRow(
    int regionIndex,
    int farmIndex,
    String farmName,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      decoration:
          BoxDecoration(
        border:
            Border.all(
          color:
              Colors.grey.shade300,
        ),

        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),

      child: Row(
        children: [

          const Icon(
            Icons.agriculture_outlined,
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              farmName,

              style:
                  const TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              deleteFarm(
                regionIndex,
                farmIndex,
              );
            },

            icon:
                const Icon(
              Icons.delete_outline,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}