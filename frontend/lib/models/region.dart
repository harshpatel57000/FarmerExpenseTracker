import 'farm.dart';

class Region {
  final int id;
  final String name;

  // Farms belonging to this region
  final List<Farm> farms;

  Region({
    required this.id,
    required this.name,
    this.farms = const [],
  });

  // JSON → Region
  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'],
      name: json['name'],
      farms: json['farms'] != null
          ? (json['farms'] as List)
              .map(
                (farm) => Farm.fromJson(farm),
              )
              .toList()
          : [],
    );
  }

  // Region → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'farms': farms
          .map(
            (farm) => farm.toJson(),
          )
          .toList(),
    };
  }
}