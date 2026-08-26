import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/crop_cycle.dart';

class CropCyclePage extends StatefulWidget {
  final String regionName;
  final String farmName;
  final int farmId;

  const CropCyclePage({
    super.key,
    required this.regionName,
    required this.farmName,
    required this.farmId,
  });

  @override
  State<CropCyclePage> createState() => _CropCyclePageState();
}

class _CropCyclePageState extends State<CropCyclePage> {
  // ============================================================
  // API URL
  // ============================================================

  static const String baseUrl =
      'https://10.0.2.2:8443/api/cropcycle';

  // ============================================================
  // CROP CYCLES
  // ============================================================

  late List<CropCycle> cropCycles;

  // ============================================================
  // CROP LIST
  // ============================================================

  final List<String> cropList = [
    'કપાસ',
    'ઘઉં',
    'મગફળી',
    'બાજરી',
    'મકાઈ',
    'ડાંગર',
    'તુવેર',
    'મગ',
    'ચણા',
    'અન્ય પાક',
  ];

  String? selectedCrop;

  DateTime selectedStartDate = DateTime.now();

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();

    cropCycles = [
      CropCycle(
        id: 1,
        farmId: widget.farmId,
        cropType: _getInitialCrop(),
        startDate: DateTime(2026, 6, 10),
        endDate: null,
        isActive: true,
      ),
    ];
  }

  // ============================================================
  // INITIAL CROP
  // ============================================================

  String _getInitialCrop() {
    switch (widget.farmId) {
      case 1:
        return 'કપાસ';

      case 2:
        return 'ઘઉં';

      case 3:
        return 'મગફળી';

      default:
        return 'પાક નથી';
    }
  }

  // ============================================================
  // CURRENT ACTIVE CROP
  // ============================================================

  CropCycle? get currentCropCycle {
    for (final crop in cropCycles) {
      if (crop.isActive) {
        return crop;
      }
    }

    return null;
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // API DATE FORMAT
  // ============================================================

  String apiDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // START NEW CROP
  // ============================================================

  void startNewCrop() {
    selectedCrop = null;
    selectedStartDate = DateTime.now();

    showModalBottomSheet(
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
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==================================================
                    // TITLE
                    // ==================================================

                    const Text(
                      'નવો પાક શરૂ કરો',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${widget.regionName} → ${widget.farmName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // CROP TYPE
                    // ==================================================

                    DropdownButtonFormField<String>(
                      initialValue: selectedCrop,
                      decoration: InputDecoration(
                        labelText: 'પાકનો પ્રકાર',
                        hintText: 'પાક પસંદ કરો',
                        prefixIcon: const Icon(Icons.grass_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: cropList.map((crop) {
                        return DropdownMenuItem<String>(
                          value: crop,
                          child: Text(crop),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          selectedCrop = value;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // START DATE
                    // ==================================================

                    const Text(
                      'પાક શરૂ થયાની તારીખ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      onTap: () async {
                        final DateTime? picked =
                            await showDatePicker(
                          context: context,
                          initialDate: selectedStartDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setSheetState(() {
                            selectedStartDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              formatDate(selectedStartDate),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_drop_down,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // START CROP BUTTON
                    // ==================================================

                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (selectedCrop == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'પાકનો પ્રકાર પસંદ કરો',
                                ),
                              ),
                            );

                            return;
                          }

                          await _saveNewCrop();

                          if (mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                        ),
                        label: const Text(
                          'પાક શરૂ કરો',
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
      },
    );
  }

  // ============================================================
  // POST - ADD NEW CROP
  // ============================================================

  Future<void> addCrop() async {
    if (selectedCrop == null) {
      return;
    }

    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cropName': selectedCrop,
          'startDate': apiDate(selectedStartDate),
          'status': 'ACTIVE',
          'farmId': widget.farmId,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        print('Crop added successfully');
        print(response.body);
      } else {
        print(
          'Failed to add crop: ${response.statusCode}',
        );
        print(response.body);

        if (mounted) {
          showMessage(
            'પાક ઉમેરવામાં ભૂલ થઈ',
          );
        }
      }
    } catch (e) {
      print('POST error: $e');

      if (mounted) {
        showMessage(
          'સર્વર સાથે કનેક્શન થઈ શક્યું નથી',
        );
      }
    }
  }

  // ============================================================
  // PUT - COMPLETE CROP
  // ============================================================

  Future<bool> completeCropApi(
    int id,
    DateTime endDate,
  ) async {
    final url = Uri.parse(
      '$baseUrl/$id/complete',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'endDate': apiDate(endDate),
        }),
      );

      if (response.statusCode == 200) {
        print('Crop completed successfully');
        print(response.body);

        return true;
      } else {
        print(
          'Failed to complete crop: ${response.statusCode}',
        );
        print(response.body);

        return false;
      }
    } catch (e) {
      print('PUT error: $e');

      return false;
    }
  }

  // ============================================================
  // SAVE NEW CROP
  // ============================================================

  Future<void> _saveNewCrop() async {
    if (selectedCrop == null) {
      return;
    }

    final String newCropName = selectedCrop!;

    // ==========================================================
    // CALL BACKEND POST
    // ==========================================================

    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cropName': newCropName,
          'startDate': apiDate(selectedStartDate),
          'status': 'ACTIVE',
          'farmId': widget.farmId,
        }),
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        print('Crop added successfully');
        print(response.body);

        // ======================================================
        // CREATE LOCAL CROP ONLY AFTER BACKEND SUCCESS
        // ======================================================

        int newId = cropCycles.isEmpty
            ? 1
            : cropCycles
                    .map((crop) => crop.id)
                    .reduce((a, b) => a > b ? a : b) +
                1;

        setState(() {
          cropCycles.add(
            CropCycle(
              id: newId,
              farmId: widget.farmId,
              cropType: newCropName,
              startDate: selectedStartDate,
              endDate: null,
              isActive: true,
            ),
          );
        });

        showMessage(
          '$newCropName નો નવો પાક શરૂ થયો',
        );
      } else {
        print(
          'POST failed: ${response.statusCode}',
        );
        print(response.body);

        showMessage(
          'પાક શરૂ કરવામાં ભૂલ થઈ',
        );
      }
    } catch (e) {
      print('POST error: $e');

      showMessage(
        'સર્વર સાથે કનેક્શન થઈ શક્યું નથી',
      );
    }
  }

  // ============================================================
  // COMPLETE CURRENT CROP
  // ============================================================

  void showCompleteCropDialog(CropCycle crop) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'પાક પૂર્ણ કરો',
          ),

          content: Text(
            'શું ${crop.cropType} પાક પૂર્ણ થઈ ગયો છે?',
          ),

          actions: [
            // ==================================================
            // CANCEL
            // ==================================================

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'રદ કરો',
              ),
            ),

            // ==================================================
            // COMPLETE
            // ==================================================

            ElevatedButton(
              onPressed: () async {
                final DateTime endDate = DateTime.now();

                // Close dialog first
                Navigator.pop(dialogContext);

                // =================================================
                // CALL BACKEND PUT
                // =================================================

                final success = await completeCropApi(
                  crop.id,
                  endDate,
                );

                if (!mounted) {
                  return;
                }

                // =================================================
                // ONLY UPDATE UI IF BACKEND SUCCESS
                // =================================================

                if (success) {
                  setState(() {
                    crop.isActive = false;
                    crop.endDate = endDate;
                  });

                  showMessage(
                    '${crop.cropType} પાક પૂર્ણ થયો',
                  );
                } else {
                  showMessage(
                    'પાક પૂર્ણ કરવામાં ભૂલ થઈ',
                  );
                }
              },
              child: const Text(
                'પૂર્ણ કરો',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BACK
  // ============================================================

  void finishCropSelection() {
    final CropCycle? crop = currentCropCycle;

    Navigator.pop(
      context,
      crop?.cropType,
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
    final activeCrops = cropCycles
        .where((crop) => crop.isActive)
        .toList();

    final completedCrops = cropCycles
        .where((crop) => !crop.isActive)
        .toList();

    return Scaffold(
      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: const Text(
          'પાક સાયકલ',
        ),
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: finishCropSelection,
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              // ==================================================
              // FARM INFORMATION
              // ==================================================

              _buildFarmHeader(),

              const SizedBox(height: 24),

              // ==================================================
              // CURRENT CROP TITLE
              // ==================================================

              const Text(
                'ચાલુ પાક',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // CURRENT CROP
              // ==================================================

              if (activeCrops.isEmpty)
                _buildNoActiveCrop()
              else
                ...activeCrops.map(
                  (crop) =>
                      _buildActiveCropCard(crop),
                ),

              const SizedBox(height: 20),

              // ==================================================
              // NEW CROP BUTTON
              // ==================================================

              SizedBox(
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: startNewCrop,

                  icon: const Icon(
                    Icons.add,
                  ),

                  label: const Text(
                    'નવો પાક શરૂ કરો',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // CROP HISTORY
              // ==================================================

              if (completedCrops.isNotEmpty) ...[
                const Text(
                  'પહેલાના પાક',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...completedCrops.reversed.map(
                  (crop) =>
                      _buildCompletedCropCard(crop),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FARM HEADER
  // ============================================================

  Widget _buildFarmHeader() {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.green.shade50,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              Icons.agriculture,
              color: Colors.green.shade700,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'ખેતર',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.farmName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'વિસ્તાર: ${widget.regionName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
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
  // NO ACTIVE CROP
  // ============================================================

  Widget _buildNoActiveCrop() {
    return Container(
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),

      child: const Column(
        children: [
          Icon(
            Icons.grass_outlined,
            size: 45,
            color: Colors.grey,
          ),

          SizedBox(height: 10),

          Text(
            'હાલ કોઈ ચાલુ પાક નથી',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'નવો પાક શરૂ કરવા માટે નીચેનું બટન દબાવો.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIVE CROP CARD
  // ============================================================

  Widget _buildActiveCropCard(
    CropCycle crop,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: Colors.green.shade300,
          width: 1.5,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [
          // ======================================================
          // CROP NAME
          // ======================================================

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Colors.green.shade50,

                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Icon(
                  Icons.grass,
                  color: Colors.green.shade700,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'ચાલુ પાક',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      crop.cropType,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: Colors.green.shade100,

                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: const Text(
                  'ચાલુ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ======================================================
          // START DATE
          // ======================================================

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Colors.grey,
              ),

              const SizedBox(width: 8),

              Text(
                'શરૂઆત: ${formatDate(crop.startDate)}',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ======================================================
          // COMPLETE CROP
          // ======================================================

          SizedBox(
            height: 48,

            child: OutlinedButton.icon(
              onPressed: () {
                showCompleteCropDialog(crop);
              },

              icon: const Icon(
                Icons.check_circle_outline,
              ),

              label: const Text(
                'પાક પૂર્ણ કરો',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPLETED CROP CARD
  // ============================================================

  Widget _buildCompletedCropCard(
    CropCycle crop,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),

            decoration: BoxDecoration(
              color: Colors.grey.shade200,

              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.grey,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  crop.cropType,

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${formatDate(crop.startDate)} → '
                  '${crop.endDate != null ? formatDate(crop.endDate!) : '-'}',

                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const Text(
            'પૂર્ણ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}