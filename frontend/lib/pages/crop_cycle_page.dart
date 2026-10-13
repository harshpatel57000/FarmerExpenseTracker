
import 'package:flutter/material.dart';

import '../models/crop_cycle.dart';
import 'services/api_service.dart';

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
  List<CropCycle> cropCycles = [];

  bool isLoading = true;
  bool isSaving = false;
  String? loadError;

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

  @override
  void initState() {
    super.initState();
    loadCropCycles();
  }

  // ------------------------------------------------------------
  // Load actual crop cycles from backend
  // ------------------------------------------------------------

  Future<void> loadCropCycles() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        loadError = null;
      });
    }

    try {
      final List<dynamic> response =
          await ApiService.getCropCyclesByFarm(widget.farmId);

      final List<CropCycle> loadedCrops = response.map((item) {
        final Map<String, dynamic> json =
            Map<String, dynamic>.from(item as Map);

        final String status =
            (json['status'] ?? 'ACTIVE').toString().toUpperCase();

        return CropCycle(
          id: (json['id'] as num).toInt(),
          farmId: widget.farmId,
          cropType: (json['cropName'] ?? '').toString(),
          startDate: DateTime.parse(json['startDate'].toString()),
          endDate: json['endDate'] == null
              ? null
              : DateTime.parse(json['endDate'].toString()),
          isActive: status == 'ACTIVE',
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        cropCycles = loadedCrops;
        isLoading = false;
      });
    }catch (e, stackTrace) {
  debugPrint('========== CROP CYCLE LOAD ERROR ==========');
  debugPrint('Farm ID: ${widget.farmId}');
  debugPrint('Error: $e');
  debugPrintStack(stackTrace: stackTrace);

  if (!mounted) return;

  setState(() {
    isLoading = false;
    loadError = 'પાકની માહિતી લોડ થઈ શકી નથી: $e';
  });
}

  }

  // ------------------------------------------------------------
  // Current active crop
  // ------------------------------------------------------------

  CropCycle? get currentCropCycle {
    for (final crop in cropCycles) {
      if (crop.isActive) return crop;
    }
    return null;
  }

  // ------------------------------------------------------------
  // Date formatting
  // ------------------------------------------------------------

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String apiDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ------------------------------------------------------------
  // Add new crop bottom sheet
  // ------------------------------------------------------------

  void startNewCrop() {
    if (isSaving) return;

    selectedCrop = null;
    selectedStartDate = DateTime.now();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
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
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Icon(
                      Icons.agriculture,
                      color: Color(0xFF237A3B),
                      size: 42,
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'નવો પાક શરૂ કરો',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      '${widget.regionName}  •  ${widget.farmName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 26),

                    DropdownButtonFormField<String>(
                      value: selectedCrop,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'પાકનો પ્રકાર',
                        hintText: 'પાક પસંદ કરો',
                        prefixIcon: const Icon(Icons.grass),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
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

                    const SizedBox(height: 20),

                    const Text(
                      'પાક શરૂ થયાની તારીખ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 9),

                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: sheetContext,
                          initialDate: selectedStartDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );

                        if (picked != null) {
                          setSheetState(() {
                            selectedStartDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Color(0xFF237A3B),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              formatDate(selectedStartDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (selectedCrop == null) {
                                  showMessage('પાકનો પ્રકાર પસંદ કરો');
                                  return;
                                }

                                if (currentCropCycle != null) {
                                  showMessage(
                                    'પહેલા ચાલુ પાક પૂર્ણ કરો',
                                  );
                                  return;
                                }

                                final success = await saveNewCrop();

                                if (success && sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF237A3B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(
                          isSaving ? 'મહેરબાની કરીને રાહ જુઓ...' : 'પાક શરૂ કરો',
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
  }

  // ------------------------------------------------------------
  // POST - save one crop cycle
  // ------------------------------------------------------------

  Future<bool> saveNewCrop() async {
    if (selectedCrop == null || isSaving) return false;

    setState(() => isSaving = true);

    try {
      await ApiService.addCropCycle(
        body: {
          'cropName': selectedCrop,
          'startDate': apiDate(selectedStartDate),
          'status': 'ACTIVE',
          'farmId': widget.farmId,
        },
      );

      if (!mounted) return false;

      setState(() => isSaving = false);

      // Reload server data instead of creating a fake local crop.
      await loadCropCycles();

      if (!mounted) return false;

      showMessage('${selectedCrop!} નો નવો પાક શરૂ થયો');
      return true;
    } catch (e) {
      if (mounted) {
        setState(() => isSaving = false);
        showMessage('પાક શરૂ કરવામાં ભૂલ થઈ');
      }

      debugPrint('Add crop cycle error: $e');
      return false;
    }
  }

  // ------------------------------------------------------------
  // Complete crop confirmation
  // ------------------------------------------------------------

  void showCompleteCropDialog(CropCycle crop) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool completing = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('પાક પૂર્ણ કરો'),
              content: Text(
                'શું ${crop.cropType} પાક પૂર્ણ થઈ ગયો છે?\n\n'
                'પૂર્ણ થયાની તારીખ આજની તારીખ રહેશે.',
              ),
              actions: [
                TextButton(
                  onPressed: completing
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('રદ કરો'),
                ),
                ElevatedButton(
                  onPressed: completing
                      ? null
                      : () async {
                          setDialogState(() => completing = true);

                          final success = await completeCropApi(
                            crop,
                            DateTime.now(),
                          );

                          if (!dialogContext.mounted) return;

                          Navigator.pop(dialogContext);

                          if (success && mounted) {
                            showMessage('${crop.cropType} પાક પૂર્ણ થયો');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF237A3B),
                    foregroundColor: Colors.white,
                  ),
                  child: completing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('પૂર્ણ કરો'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // PUT - complete crop cycle
  // ------------------------------------------------------------

  Future<bool> completeCropApi(
    CropCycle crop,
    DateTime endDate,
  ) async {
    try {
      await ApiService.completeCropCycle(
        crop.id,
        endDate: apiDate(endDate),
      );

      if (!mounted) return false;

      await loadCropCycles();

      return true;
    } catch (e) {
      debugPrint('Complete crop cycle error: $e');

      if (mounted) {
        showMessage('પાક પૂર્ણ કરવામાં ભૂલ થઈ');
      }

      return false;
    }
  }

  // ------------------------------------------------------------
  // Back - return selected active crop
  // ------------------------------------------------------------

  void finishCropSelection() {
    Navigator.pop(context, currentCropCycle?.cropType);
  }

  // ------------------------------------------------------------
  // Snackbar
  // ------------------------------------------------------------

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ------------------------------------------------------------
  // Build page
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final activeCrops = cropCycles.where((c) => c.isActive).toList();

    final completedCrops = cropCycles.where((c) => !c.isActive).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        title: const Text(
          'પાક સાયકલ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: finishCropSelection,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadCropCycles,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _buildFarmHeader(),
              const SizedBox(height: 25),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ચાલુ પાક',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _countBadge(activeCrops.length, Colors.green),
                ],
              ),
              const SizedBox(height: 12),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (loadError != null)
                _buildLoadError()
              else if (activeCrops.isEmpty)
                _buildNoActiveCrop()
              else
                ...activeCrops.map(_buildActiveCropCard),

              const SizedBox(height: 18),

              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: isLoading || isSaving ? null : startNewCrop,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text(
                    'નવો પાક શરૂ કરો',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF237A3B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'પહેલાના પાક',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _countBadge(completedCrops.length, Colors.grey),
                ],
              ),
              const SizedBox(height: 12),

              if (!isLoading && loadError == null)
                if (completedCrops.isEmpty)
                  _buildNoHistory()
                else
                  ...completedCrops.map(_buildCompletedCropCard),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Farm header
  // ------------------------------------------------------------

  Widget _buildFarmHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF5FAF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.agriculture,
              color: Color(0xFF237A3B),
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ખેતરની માહિતી',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.farmName,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'વિસ્તાર: ${widget.regionName}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Loading error
  // ------------------------------------------------------------

  Widget _buildLoadError() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 42,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 10),
          Text(
            loadError!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: loadCropCycles,
            icon: const Icon(Icons.refresh),
            label: const Text('ફરી પ્રયાસ કરો'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // No active crop
  // ------------------------------------------------------------

  Widget _buildNoActiveCrop() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.grass_outlined,
              size: 38,
              color: Color(0xFF237A3B),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'હાલ કોઈ ચાલુ પાક નથી',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'નવો પાક શરૂ કરવા માટે નીચેનું બટન દબાવો.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // No crop history
  // ------------------------------------------------------------

  Widget _buildNoHistory() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: Colors.grey.shade500, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'હજુ સુધી કોઈ પાક પૂર્ણ થયો નથી.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Active crop card
  // ------------------------------------------------------------

  Widget _buildActiveCropCard(CropCycle crop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFB7DDBD),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.grass,
                  size: 29,
                  color: Color(0xFF237A3B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ચાલુ પાક',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ચાલુ',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 19,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 9),
                const Text(
                  'શરૂઆત',
                  style: TextStyle(fontSize: 13),
                ),
                const Spacer(),
                Text(
                  formatDate(crop.startDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 47,
            child: OutlinedButton.icon(
              onPressed: () => showCompleteCropDialog(crop),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'પાક પૂર્ણ કરો',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF237A3B),
                side: const BorderSide(color: Color(0xFF8BC695)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Completed crop card
  // ------------------------------------------------------------

  Widget _buildCompletedCropCard(CropCycle crop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.grey.shade600,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop.cropType,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'શરૂઆત: ${formatDate(crop.startDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'પૂર્ણ: ${crop.endDate == null ? '-' : formatDate(crop.endDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'પૂર્ણ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
