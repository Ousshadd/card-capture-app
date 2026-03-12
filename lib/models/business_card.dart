class BusinessCard {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String? company;
  final String? scanDate;

  BusinessCard({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.company,
    this.scanDate,
  });

  // Convert a BusinessCard into a Map to store in SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'scanDate': scanDate ?? DateTime.now().toIso8601String(),
    };
  }

  // Extract a BusinessCard object from a Database Map
  factory BusinessCard.fromMap(Map<String, dynamic> map) {
    return BusinessCard(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      company: map['company'],
      scanDate: map['scanDate'],
    );
  }
}