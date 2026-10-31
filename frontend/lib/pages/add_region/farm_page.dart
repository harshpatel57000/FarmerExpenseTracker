
import 'package:flutter/material.dart';
import 'package:frontend/pages/services/api_service.dart';

const String farmBackgroundImage =
    'assets/images/Add_region_image.png';

const Color farmPrimaryGreen = Color(0xFF276555);
const Color farmDarkGreen = Color(0xFF164638);

class FarmPage extends StatefulWidget {
  final int regionId;
  final String regionName;

  const FarmPage({
    super.key,
    required this.regionId,
    required this.regionName,
  });

  @override
  State<FarmPage> createState() => _FarmPageState();
}

class _FarmPageState extends State<FarmPage> {
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  List<dynamic> _farms = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  Future<void> _loadFarms() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final allFarms = await ApiService.getFarms();

      // Display only the farms belonging to this selected region.
      final regionFarms = allFarms.where((item) {
        if (item is! Map) return false;
        return _toInt(item['regionId']) == widget.regionId;
      }).toList();

      if (!mounted) return;
      setState(() {
        _farms = regionFarms;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'ખેતરો લોડ થઈ શક્યાં નથી. ફરી પ્રયાસ કરો.';
      });
    }
  }

  Future<void> _addFarm() async {
    final name = _farmNameController.text.trim();
    final areaText = _areaController.text.trim();
    final area = double.tryParse(areaText);

    if (name.isEmpty) {
      _showMessage('કૃપા કરીને ખેતરનું નામ લખો.');
      return;
    }

    if (area == null || !area.isFinite || area <= 0) {
      _showMessage('ખેતરનું યોગ્ય ક્ષેત્રફળ દાખલ કરો.');
      return;
    }

    setState(() => _saving = true);

    try {
      await ApiService.addFarm(
        name: name,
        area: area,
        regionId: widget.regionId,
      );

      if (!mounted) return;
      _farmNameController.clear();
      _areaController.clear();
      FocusScope.of(context).unfocus();

      _showMessage('ખેતર સફળતાપૂર્વક ઉમેરાયું.');
      await _loadFarms();
    } catch (e) {
      if (mounted) {
        _showMessage('ખેતર ઉમેરાયું નથી. વિગતો તપાસીને ફરી પ્રયાસ કરો.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteFarm(Map<String, dynamic> farm) async {
    final farmId = _toInt(farm['id']);

    if (farmId == null) {
      _showMessage('ખેતરની ID મળી નથી.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ખેતર કાઢી નાખવું છે?'),
        content: Text(
          '"${farm['name'] ?? 'ખેતર'}" કાઢી નાખવા માંગો છો?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('રદ કરો'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('કાઢી નાખો'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.deleteFarm(farmId);
      if (!mounted) return;

      _showMessage('ખેતર કાઢી નાખ્યું.');
      await _loadFarms();
    } catch (e) {
      if (mounted) {
        _showMessage(
          'ખેતર કાઢી શકાયું નથી. તેમાં પાક અથવા ખર્ચ જોડાયેલા હોય તો તપાસો.',
        );
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          farmBackgroundImage,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFE1EDE3),
          ),
        ),
        Container(color: farmDarkGreen.withValues(alpha: 0.53)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'તમારા ખેતરો',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'ફરી લોડ કરો',
            onPressed: _loadFarms,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadFarms,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                children: [
                  const Icon(
                    Icons.agriculture_rounded,
                    size: 58,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.regionName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'આ વિસ્તારનાં ખેતરો અહીં ઉમેરો અને જુઓ.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 24),

                  // Add farm card
                  Card(
                    color: const Color(0xFFFFFEF8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'નવું ખેતર ઉમેરો',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: farmDarkGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F2E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: farmPrimaryGreen,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'વિસ્તાર: ${widget.regionName}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: farmDarkGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _farmNameController,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              labelText: 'ખેતરનું નામ',
                              hintText: 'ઉદાહરણ: ખેતર નંબર 1',
                              prefixIcon: const Icon(
                                Icons.grass,
                                color: farmPrimaryGreen,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _areaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              labelText: 'ખેતરનું ક્ષેત્રફળ',
                              hintText: 'ઉદાહરણ: 2.5',
                              helperText: 'ક્ષેત્રફળ એકર પ્રમાણે દાખલ કરો',
                              prefixIcon: const Icon(
                                Icons.square_foot,
                                color: farmPrimaryGreen,
                              ),
                              suffixText: 'એકર',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: _saving ? null : _addFarm,
                              icon: _saving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.add),
                              label: Text(
                                _saving ? 'ઉમેરાઈ રહ્યું છે...' : 'ખેતર ઉમેરો',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: farmPrimaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Farm list heading
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'આ વિસ્તારનાં ખેતરો',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '${_farms.length}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: farmDarkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else if (_error != null)
                    _emptyState(
                      icon: Icons.cloud_off,
                      message: _error!,
                      buttonText: 'ફરી પ્રયાસ કરો',
                      onPressed: _loadFarms,
                    )
                  else if (_farms.isEmpty)
                    _emptyState(
                      icon: Icons.grass,
                      message: 'આ વિસ્તારમાં હજી કોઈ ખેતર ઉમેર્યું નથી.',
                      buttonText: 'યાદી ફરી લોડ કરો',
                      onPressed: _loadFarms,
                    )
                  else
                    ..._farms.map((item) {
                      final farm = Map<String, dynamic>.from(item as Map);
                      final farmName =
                          farm['name']?.toString() ?? 'નામ વગરનું ખેતર';
                      final area = _toDouble(farm['area']);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: const Color(0xFFFFFEF8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          leading: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0EFE3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.agriculture,
                              color: farmPrimaryGreen,
                              size: 29,
                            ),
                          ),
                          title: Text(
                            farmName,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: farmDarkGreen,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              area == null
                                  ? 'ક્ષેત્રફળ ઉપલબ્ધ નથી'
                                  : 'ક્ષેત્રફળ: ${area.toString()} એકર',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteFarm(farm);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('ખેતર કાઢી નાખો'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: farmPrimaryGreen),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: farmDarkGreen),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
