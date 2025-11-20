// Medicine object and its data structure
class Medicine {
  final int? id;
  // English fields
  final String name;
  final String dosage;
  final String usage;
  final String sideEffects;
  final String precautions;

  // Tagalog fields
  final String? nameTagalog;
  final String? dosageTagalog;
  final String? usageTagalog;
  final String? sideEffectsTagalog;
  final String? precautionsTagalog;

// Constructor for creating a Medicine object
  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    required this.usage,
    required this.sideEffects,
    required this.precautions,
    this.nameTagalog,
    this.dosageTagalog,
    this.usageTagalog,
    this.sideEffectsTagalog,
    this.precautionsTagalog,
  });

// Converts a Medicine object into a Map (for saving to SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'usage': usage,
      'sideEffects': sideEffects,
      'precautions': precautions,
      'name_tagalog': nameTagalog,
      'dosage_tagalog': dosageTagalog,
      'usage_tagalog': usageTagalog,
      'sideEffects_tagalog': sideEffectsTagalog,
      'precautions_tagalog': precautionsTagalog,
    };
  }

// Factory constructor: creates a Medicine object from a Map (from SQLite)
  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'] ?? '',
      usage: map['usage'] ?? '',
      sideEffects: map['sideEffects'] ?? '',
      precautions: map['precautions'] ?? '',
      nameTagalog: map['name_tagalog'] ?? '',
      dosageTagalog: map['dosage_tagalog'] ?? '',
      usageTagalog: map['usage_tagalog'] ?? '',
      sideEffectsTagalog: map['sideEffects_tagalog'] ?? '',
      precautionsTagalog: map['precautions_tagalog'] ?? '',
    );
  }
}
