class Tenant {
  final String? id;
  final String fullname;
  final String phone;
  final String email;
  final String preferredArea;
  final String benefitType;
  final DateTime? moveDate;

  Tenant({
    this.id,
    required this.fullname,
    required this.phone,
    required this.email,
    required this.preferredArea,
    required this.benefitType,
    this.moveDate,
  });

  factory Tenant.fromMap(Map<String, dynamic> map, String documentId) {
    return Tenant(
      id: documentId,
      fullname: map['fullname'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      preferredArea: map['preferredArea'] ?? '',
      benefitType: map['benefitType'] ?? '',
      moveDate: map['moveDate'] != null
          ? (map['moveDate'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullname': fullname,
      'phone': phone,
      'email': email,
      'preferredArea': preferredArea,
      'benefitType': benefitType,
      'moveDate': moveDate,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Tenant.fromJson(Map<String, dynamic> json) =>
      Tenant.fromMap(json, json['id'] ?? '');

  Tenant copyWith({
    String? id,
    String? fullname,
    String? phone,
    String? email,
    String? preferredArea,
    String? benefitType,
    DateTime? moveDate,
  }) {
    return Tenant(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      preferredArea: preferredArea ?? this.preferredArea,
      benefitType: benefitType ?? this.benefitType,
      moveDate: moveDate ?? this.moveDate,
    );
  }

  @override
  String toString() => 'Tenant(id: $id, name: $fullname)';
}
