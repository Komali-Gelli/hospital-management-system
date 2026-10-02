class MedicalRecord {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String diagnosis;
  final String date;
  final String treatment;
  final String prescription;
  final String bloodPressure;
  final String temperature;
  final String status;
  final String notes;

  MedicalRecord({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.diagnosis,
    required this.date,
    required this.treatment,
    required this.prescription,
    required this.bloodPressure,
    required this.temperature,
    required this.status,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'diagnosis': diagnosis,
      'date': date,
      'treatment': treatment,
      'prescription': prescription,
      'bloodPressure': bloodPressure,
      'temperature': temperature,
      'status': status,
      'notes': notes,
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id']?.toString() ?? '',
      patientId: map['patientId']?.toString() ?? '',
      patientName: map['patientName']?.toString() ?? '',
      doctorId: map['doctorId']?.toString() ?? '',
      doctorName: map['doctorName']?.toString() ?? '',
      diagnosis: map['diagnosis']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      treatment: map['treatment']?.toString() ?? '',
      prescription: map['prescription']?.toString() ?? '',
      bloodPressure:
      map['bloodPressure']?.toString() ?? '',
      temperature:
      map['temperature']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Active',
      notes: map['notes']?.toString() ?? '',
    );
  }
}