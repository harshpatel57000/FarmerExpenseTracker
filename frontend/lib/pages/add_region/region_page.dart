
import 'package:flutter/material.dart';
import 'package:frontend/pages/add_region/farm_page.dart';
import 'package:frontend/pages/services/api_service.dart';

// Change this path to use your own background image.
const String backgroundImage = 'assets/images/Add_region_image.png';

const Color primaryGreen = Color(0xFF276555);
const Color darkGreen = Color(0xFF164638);

class AddRegionPage extends StatefulWidget {
  const AddRegionPage({super.key});

  @override
  State<AddRegionPage> createState() => _AddRegionPageState();
}

class _AddRegionPageState extends State<AddRegionPage> {
  final TextEditingController _regionController = TextEditingController();

  List<dynamic> _regions = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  @override
  void dispose() {
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final regions = await ApiService.getRegions();
      if (!mounted) return;

      setState(() {
        _regions = regions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'વિસ્તારો લોડ થઈ શક્યા નથી. ફરી પ્રયાસ કરો.';
      });
    }
  }

  Future<void> _addRegion() async {
    final name = _regionController.text.trim();

    if (name.isEmpty) {
      _showMessage('કૃપા કરીને વિસ્તારનું નામ લખો.');
      return;
    }

    setState(() => _saving = true);

    try {
      await ApiService.addRegion(name: name);
      if (!mounted) return;

      _regionController.clear();
      FocusScope.of(context).unfocus();

      _showMessage('વિસ્તાર સફળતાપૂર્વક ઉમેરાયો.');
      await _loadRegions();
    } catch (e) {
      if (mounted) {
        _showMessage('વિસ્તાર ઉમેરાયો નથી. ફરી પ્રયાસ કરો.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteRegion(Map<String, dynamic> region) async {
    final id = _toInt(region['id']);
    if (id == null) {
      _showMessage('વિસ્તારની ID મળી નથી.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('વિસ્તાર કાઢી નાખવો છે?'),
        content: Text(
          '"${region['name'] ?? 'વિસ્તાર'}" કાઢી નાખવા માંગો છો?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('રદ કરો'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('કાઢી નાખો'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.deleteRegion(id);
      if (!mounted) return;
      _showMessage('વિસ્તાર કાઢી નાખ્યો.');
      await _loadRegions();
    } catch (e) {
      if (mounted) {
        _showMessage(
          'વિસ્તાર કાઢી શકાયો નથી. તેમાં ખેતરો જોડાયેલા હોય તો પહેલાં તપાસો.',
        );
      }
    }
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
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
          backgroundImage,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFE1EDE3),
          ),
        ),
        Container(color: darkGreen.withValues(alpha: 0.52)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'તમારા વિસ્તારો',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'ફરી લોડ કરો',
            onPressed: _loadRegions,
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
              onRefresh: _loadRegions,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                children: [
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.landscape_rounded,
                    size: 58,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'તમારી ખેતીનું આયોજન કરો',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'નવો વિસ્તાર ઉમેરો અને તેમાં તમારા ખેતરો ગોઠવો.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 24),

                  // Add region card
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
                            'નવો વિસ્તાર ઉમેરો',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ઉદાહરણ: ગામનું નામ અથવા વિસ્તાર',
                            style: TextStyle(fontSize: 15, color: Colors.black54),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _regionController,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              labelText: 'વિસ્તારનું નામ',
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                                color: primaryGreen,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1DED5),
                                ),
                              ),
                            ),
                            onSubmitted: (_) {
                              if (!_saving) _addRegion();
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: _saving ? null : _addRegion,
                              icon: _saving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.add_location_alt),
                              label: Text(
                                _saving ? 'ઉમેરાઈ રહ્યો છે...' : 'વિસ્તાર ઉમેરો',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: primaryGreen,
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

                  // All regions heading
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'તમારા ઉમેરેલા વિસ્તારો',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
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
                          '${_regions.length}',
                          style: const TextStyle(
                            color: darkGreen,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
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
                    _emptyOrError(
                      icon: Icons.cloud_off,
                      message: _error!,
                      actionLabel: 'ફરી પ્રયાસ કરો',
                      onPressed: _loadRegions,
                    )
                  else if (_regions.isEmpty)
                    _emptyOrError(
                      icon: Icons.location_searching,
                      message: 'હજુ કોઈ વિસ્તાર ઉમેર્યો નથી.',
                      actionLabel: 'વિસ્તાર ઉમેરો',
                      onPressed: () {},
                    )
                  else
                    ..._regions.map((item) {
                      final region = Map<String, dynamic>.from(item as Map);
                      final regionId = _toInt(region['id']);
                      final regionName =
                          region['name']?.toString() ?? 'નામ વગરનો વિસ્તાર';

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
                              Icons.map_outlined,
                              color: primaryGreen,
                              size: 29,
                            ),
                          ),
                          title: Text(
                            regionName,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              'ખેતરો જોવા માટે પસંદ કરો',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteRegion(region);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('વિસ્તાર કાઢી નાખો'),
                              ),
                            ],
                          ),
                          onTap: regionId == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FarmPage(
                                        regionId: regionId,
                                        regionName: regionName,
                                      ),
                                    ),
                                  );
                                },
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

  Widget _emptyOrError({
    required IconData icon,
    required String message,
    required String actionLabel,
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
          Icon(icon, size: 42, color: primaryGreen),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: darkGreen),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onPressed,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
