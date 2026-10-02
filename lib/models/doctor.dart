class Doctor {
  final String id;
  final String name;
  final String specialization;
  final int experience;
  final String phone;
  final String email;
  final String department;
  final String availability;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.phone,
    required this.email,
    required this.department,
    required this.availability,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'experience': experience,
      'phone': phone,
      'email': email,
      'department': department,
      'availability': availability,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      specialization:
      map['specialization']?.toString() ?? '',
      experience:
      int.tryParse(map['experience']?.toString() ?? '0') ?? 0,
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      department:
      map['department']?.toString() ?? '',
      availability:
      map['availability']?.toString() ?? '',
    );
  }
}