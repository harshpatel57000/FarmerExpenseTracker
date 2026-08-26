import 'region.dart';

class Village {
  final int id;
  final String name;
  final String pinCode;

  // Regions belonging to this village
  final List<Region> regions;

  Village({
    required this.id,
    required this.name,
    required this.pinCode,
    this.regions = const [],
  });

  // JSON → Village
  factory Village.fromJson(
    Map<String, dynamic> json,
  ) {
    return Village(
      id: json['id'],
      name: json['name'],
      pinCode: json['pinCode'] ?? '',
      regions: json['regions'] != null
          ? (json['regions'] as List)
              .map(
                (region) =>
                    Region.fromJson(region),
              )
              .toList()
          : [],
    );
  }

  // Village → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pinCode': pinCode,
      'regions': regions
          .map(
            (region) => region.toJson(),
          )
          .toList(),
    };
  }
}