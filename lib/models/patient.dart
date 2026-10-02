class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String disease;
  final String phone;
  final String address;
  final String bloodGroup;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.disease,
    required this.phone,
    required this.address,
    required this.bloodGroup,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'disease': disease,
      'phone': phone,
      'address': address,
      'bloodGroup': bloodGroup,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      age: int.tryParse(map['age']?.toString() ?? '0') ?? 0,
      gender: map['gender']?.toString() ?? '',
      disease: map['disease']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      bloodGroup: map['bloodGroup']?.toString() ?? '',
    );
  }
}