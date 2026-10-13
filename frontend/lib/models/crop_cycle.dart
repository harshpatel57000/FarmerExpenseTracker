class CropCycle {
  final int id;
  final int farmId;
  final String cropType;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  CropCycle({
    required this.id,
    required this.farmId,
    required this.cropType,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory CropCycle.fromJson(
    Map<String, dynamic> json, {
    required int farmId,
  }) {
    final rawEndDate = json['endDate'];
    final status = (json['status'] ?? '').toString().toUpperCase();

    return CropCycle(
      id: (json['id'] as num).toInt(),
      farmId: farmId,
      cropType: (json['cropName'] ?? '').toString(),
      startDate: DateTime.parse(json['startDate'].toString()),
      endDate: rawEndDate == null
          ? null
          : DateTime.parse(rawEndDate.toString()),
      isActive: status == 'ACTIVE',
    );
  }
}