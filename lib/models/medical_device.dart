class MedicalDevice {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String imageUrl; // URL Gambar Alat Medis
  final int stock;
  final Map<String, dynamic> specifications;
  bool isFavorite;

  MedicalDevice({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.stock,
    required this.specifications,
    this.isFavorite = false,
  });

  factory MedicalDevice.fromJson(Map<String, dynamic> json) {
    return MedicalDevice(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '', // Mapping dari database (image_url)
      stock: json['stock'] ?? 0,
      specifications: json['specifications'] is Map 
          ? Map<String, dynamic>.from(json['specifications']) 
          : {},
      isFavorite: false, // Local state, default to false
    );
  }

  MedicalDevice copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? description,
    String? imageUrl,
    int? stock,
    Map<String, dynamic>? specifications,
    bool? isFavorite,
  }) {
    return MedicalDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      specifications: specifications ?? this.specifications,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
