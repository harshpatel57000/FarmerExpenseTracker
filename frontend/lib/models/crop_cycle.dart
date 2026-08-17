class CropCycle {
  final int id;
  final int farmId;
  final String cropType;
  final DateTime startDate;
  DateTime? endDate;
  bool isActive;

  CropCycle({
    required this.id,
    required this.farmId,
    required this.cropType,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });
}