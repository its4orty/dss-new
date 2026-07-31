class Landlord {
  final String? id;
  final String name;
  final String phone;
  final String email;
  final int propertyCount;

  Landlord({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.propertyCount = 0,
  });

  factory Landlord.fromMap(Map<String, dynamic> map, String documentId) {
    return Landlord(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      propertyCount: (map['propertyCount'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'propertyCount': propertyCount,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Landlord.fromJson(Map<String, dynamic> json) =>
      Landlord.fromMap(json, json['id'] ?? '');

  Landlord copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    int? propertyCount,
  }) {
    return Landlord(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      propertyCount: propertyCount ?? this.propertyCount,
    );
  }

  @override
  String toString() => 'Landlord(id: $id, name: $name)';
}
