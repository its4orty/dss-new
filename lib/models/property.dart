class Property {
  final String? id;
  final String title;
  final String address;
  final String postcode;
  final int bedrooms;
  final int bathrooms;
  final double rent;
  final double? deposit;
  final String description;
  final List<String> images;
  final String furnishedStatus;
  final bool available;

  Property({
    this.id,
    required this.title,
    required this.address,
    required this.postcode,
    required this.bedrooms,
    required this.bathrooms,
    required this.rent,
    this.deposit,
    required this.description,
    this.images = const [],
    this.furnishedStatus = 'Unfurnished',
    this.available = true,
  });

  factory Property.fromMap(Map<String, dynamic> map, String documentId) {
    return Property(
      id: documentId,
      title: map['title'] ?? '',
      address: map['address'] ?? '',
      postcode: map['postcode'] ?? '',
      bedrooms: (map['bedrooms'] ?? 0).toInt(),
      bathrooms: (map['bathrooms'] ?? 0).toInt(),
      rent: (map['rent'] ?? 0.0).toDouble(),
      deposit: map['deposit']?.toDouble(),
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      furnishedStatus: map['furnishedStatus'] ?? 'Unfurnished',
      available: map['available'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'address': address,
      'postcode': postcode,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'rent': rent,
      'deposit': deposit,
      'description': description,
      'images': images,
      'furnishedStatus': furnishedStatus,
      'available': available,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Property.fromJson(Map<String, dynamic> json) =>
      Property.fromMap(json, json['id'] ?? '');

  Property copyWith({
    String? id,
    String? title,
    String? address,
    String? postcode,
    int? bedrooms,
    int? bathrooms,
    double? rent,
    double? deposit,
    String? description,
    List<String>? images,
    String? furnishedStatus,
    bool? available,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      postcode: postcode ?? this.postcode,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      rent: rent ?? this.rent,
      deposit: deposit ?? this.deposit,
      description: description ?? this.description,
      images: images ?? this.images,
      furnishedStatus: furnishedStatus ?? this.furnishedStatus,
      available: available ?? this.available,
    );
  }

  @override
  String toString() => 'Property(id: $id, title: $title, rent: £$rent)';
}
