import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
static final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

static Future<bool> _notificationsEnabled() async {
final prefs = await SharedPreferences.getInstance();

return prefs.getBool('notifications') ?? true;
}

// ============================================================
// CREATE NOTIFICATION
// ============================================================

static Future<void> addNotification({
required String title,
required String message,
required String type,
Map<String, dynamic>? data,
String? collection,
String? documentId,
}) async {
final enabled = await _notificationsEnabled();

if (!enabled) {
return;
}

await _firestore.collection('notifications').add({
'title': title,
'message': message,
'type': type,

// Exact record data
'data': data ?? {},

// Where the original record is stored
'collection': collection ?? '',
'documentId': documentId ?? '',

// Used for red unread number
'isRead': false,

'createdAt': FieldValue.serverTimestamp(),
});
}

// ============================================================
// PATIENT
// ============================================================

static Future<void> patientAdded(
String patientName, {
Map<String, dynamic>? data,
String? documentId,
}) async {
await addNotification(
title: 'New Patient',
message: '$patientName was added',
type: 'patient',
data: data,
collection: 'patients',
documentId: documentId,
);
}

// ============================================================
// DOCTOR
// ============================================================

static Future<void> doctorAdded(
String doctorName, {
Map<String, dynamic>? data,
String? documentId,
}) async {
await addNotification(
title: 'New Doctor',
message: '$doctorName was added',
type: 'doctor',
data: data,
collection: 'doctors',
documentId: documentId,
);
}

// ============================================================
// APPOINTMENT
// ============================================================

static Future<void> appointmentAdded(
String patientName, {
Map<String, dynamic>? data,
String? documentId,
}) async {
await addNotification(
title: 'New Appointment',
message: 'Appointment for $patientName was added',
type: 'appointment',
data: data,
collection: 'appointments',
documentId: documentId,
);
}

// ============================================================
// MEDICAL RECORD
// ============================================================

static Future<void> medicalRecordAdded(
String patientName, {
Map<String, dynamic>? data,
String? documentId,
}) async {
await addNotification(
title: 'New Medical Record',
message: 'Medical record for $patientName was added',
type: 'medical_record',
data: data,
collection: 'medical_records',
documentId: documentId,
);
}

// ============================================================
// MEDICINE
// ============================================================

static Future<void> medicineAdded(
String medicineName, {
Map<String, dynamic>? data,
String? documentId,
}) async {
await addNotification(
title: 'New Medicine',
message: '$medicineName was added',
type: 'medicine',
data: data,
collection: 'medicines',
documentId: documentId,
);
}

// ============================================================
// BILL
// ============================================================

static Future<void> billAdded(
String patientName, {
Map<String, dynamic>? data,
String? documentId,
}) async {
await addNotification(
title: 'New Bill',
message: 'Bill for $patientName was added',
type: 'bill',
data: data,
collection: 'bills',
documentId: documentId,
);
}

// ============================================================
// MARK AS READ
// ============================================================

static Future<void> markAsRead(
String notificationId,
) async {
await _firestore
    .collection('notifications')
    .doc(notificationId)
    .update({
'isRead': true,
});
}

// ============================================================
// MARK ALL AS READ
// ============================================================

static Future<void> markAllAsRead() async {
final snapshot = await _firestore
    .collection('notifications')
    .get();

final batch = _firestore.batch();

for (final doc in snapshot.docs) {
final data = doc.data();

if (data['isRead'] != true) {
batch.update(
doc.reference,
{
'isRead': true,
},
);
}
}

await batch.commit();
}
}

