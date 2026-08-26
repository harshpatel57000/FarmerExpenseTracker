class Farm {
  final int id;
  final String name;

  Farm({
    required this.id,
    required this.name,
  });

  // Convert JSON from backend → Farm object
  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'],
      name: json['name'],
    );
  }

  // Convert Farm object → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}