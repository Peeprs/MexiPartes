class Address {
  final String id;
  final String name;
  final String lastNamePaternal;
  final String lastNameMaternal;
  final String street;
  final String postalCode;
  final String extNum;
  final String? intNum;
  final String colony;
  final String phone;
  final String? betweenStreets;

  Address({
    required this.id,
    required this.name,
    required this.lastNamePaternal,
    required this.lastNameMaternal,
    required this.street,
    required this.postalCode,
    required this.extNum,
    this.intNum,
    required this.colony,
    required this.phone,
    this.betweenStreets,
  });

  // Convierte un objeto Address a un Map para poder guardarlo como JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id':
          id, // Si es nuevo, la DB generará uno si se omite, o podemos mandarlo
      'name': name,
      'last_name_paternal': lastNamePaternal,
      'last_name_maternal': lastNameMaternal,
      'street': street,
      'postal_code': postalCode,
      'ext_num': extNum,
      'int_num': intNum,
      'colony': colony,
      'phone': phone,
      'between_streets': betweenStreets,
    };
  }

  // Crea un objeto Address desde un Map (obtenido de un JSON/DB)
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? '', // Manejo seguro de ID
      name: json['name'] ?? '',
      lastNamePaternal: json['last_name_paternal'] ?? '',
      lastNameMaternal: json['last_name_maternal'] ?? '',
      street: json['street'] ?? '',
      postalCode: json['postal_code'] ?? '',
      extNum: json['ext_num'] ?? '',
      intNum: json['int_num'],
      colony: json['colony'] ?? '',
      phone: json['phone'] ?? '',
      betweenStreets: json['between_streets'],
    );
  }
}
