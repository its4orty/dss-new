class Enquiry {
  final String? id;
  final String propertyId;
  final String tenantId;
  final String status;
  final DateTime? createdAt;

  Enquiry({
    this.id,
    required this.propertyId,
    required this.tenantId,
    this.status = 'new',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Enquiry.fromMap(Map<String, dynamic> map, String documentId) {
    return Enquiry(
      id: documentId,
      propertyId: map['propertyId'] ?? '',
      tenantId: map['tenantId'] ?? '',
      status: map['status'] ?? 'new',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'tenantId': tenantId,
      'status': status,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Enquiry.fromJson(Map<String, dynamic> json) =>
      Enquiry.fromMap(json, json['id'] ?? '');

  Enquiry copyWith({
    String? id,
    String? propertyId,
    String? tenantId,
    String? status,
    DateTime? createdAt,
  }) {
    return Enquiry(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      tenantId: tenantId ?? this.tenantId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Enquiry(id: $id, property: $propertyId, tenant: $tenantId, status: $status)';
}
