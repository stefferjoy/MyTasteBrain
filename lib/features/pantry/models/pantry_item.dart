class PantryItem {
  final int? id;
  final String name;
  final String category;
  final String? quantity;
  final String? unit;
  final DateTime? expiryDate;
  final String? storageLocation;
  final bool isLeftover;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PantryItem({
    this.id,
    required this.name,
    this.category = 'other',
    this.quantity,
    this.unit,
    this.expiryDate,
    this.storageLocation,
    this.isLeftover = false,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PantryItem.fromMap(Map<String, Object?> map) {
    return PantryItem(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'other',
      quantity: map['quantity'] as String?,
      unit: map['unit'] as String?,
      expiryDate: DateTime.tryParse(map['expiry_date'] as String? ?? ''),
      storageLocation: map['storage_location'] as String?,
      isLeftover: (map['is_leftover'] as int? ?? 0) == 1,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name.trim().toLowerCase(),
      'category': category.trim().toLowerCase(),
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate?.toIso8601String(),
      'storage_location': storageLocation,
      'is_leftover': isLeftover ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isExpiringSoon {
    final expiry = expiryDate;
    if (expiry == null) return false;
    final now = DateTime.now();
    return expiry.isAfter(now.subtract(const Duration(days: 1))) &&
        expiry.isBefore(now.add(const Duration(days: 3)));
  }

  PantryItem copyWith({
    int? id,
    String? name,
    String? category,
    String? quantity,
    String? unit,
    DateTime? expiryDate,
    String? storageLocation,
    bool? isLeftover,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      storageLocation: storageLocation ?? this.storageLocation,
      isLeftover: isLeftover ?? this.isLeftover,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
