import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GlobalSearchScreen extends StatefulWidget {
const GlobalSearchScreen({super.key});

@override
State<GlobalSearchScreen> createState() =>
_GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
final TextEditingController _searchController =
TextEditingController();

bool _searching = false;

List<_SearchResult> _results = [];

@override
void dispose() {
_searchController.dispose();
super.dispose();
}

Future<void> _searchAll() async {
final query =
_searchController.text.trim().toLowerCase();

if (query.isEmpty) {
setState(() {
_results = [];
_searching = false;
});
return;
}

setState(() {
_searching = true;
_results = [];
});

final results = <_SearchResult>[];

try {
// ==========================================================
// PATIENTS
// ==========================================================

final patients = await FirebaseFirestore.instance
    .collection('patients')
    .get();

for (final doc in patients.docs) {
final data = doc.data();

final name = data['name']?.toString() ?? '';
final age = data['age']?.toString() ?? '';
final gender = data['gender']?.toString() ?? '';
final disease = data['disease']?.toString() ?? '';
final phone = data['phone']?.toString() ?? '';
final address = data['address']?.toString() ?? '';
final bloodGroup =
data['bloodGroup']?.toString() ?? '';

if (_contains(query, [
name,
age,
gender,
disease,
phone,
address,
bloodGroup,
])) {
results.add(
_SearchResult(
title: name.isEmpty ? 'Patient' : name,
subtitle: 'Patient',
icon: Icons.person,
type: 'Patient',
data: data,
),
);
}
}

// ==========================================================
// DOCTORS
// ==========================================================

final doctors = await FirebaseFirestore.instance
    .collection('doctors')
    .get();

for (final doc in doctors.docs) {
final data = doc.data();

final name = data['name']?.toString() ?? '';
final specialization =
data['specialization']?.toString() ?? '';
final experience =
data['experience']?.toString() ?? '';
final phone = data['phone']?.toString() ?? '';
final email = data['email']?.toString() ?? '';
final department =
data['department']?.toString() ?? '';
final availability =
data['availability']?.toString() ?? '';

if (_contains(query, [
name,
specialization,
experience,
phone,
email,
department,
availability,
])) {
results.add(
_SearchResult(
title: name.isEmpty ? 'Doctor' : name,
subtitle: 'Doctor',
icon: Icons.medical_services,
type: 'Doctor',
data: data,
),
);
}
}

// ==========================================================
// APPOINTMENTS
// ==========================================================

final appointments = await FirebaseFirestore.instance
    .collection('appointments')
    .get();

for (final doc in appointments.docs) {
final data = doc.data();

final patientName =
data['patientName']?.toString() ?? '';
final doctorName =
data['doctorName']?.toString() ?? '';
final date = data['date']?.toString() ?? '';
final time = data['time']?.toString() ?? '';
final reason = data['reason']?.toString() ?? '';
final status = data['status']?.toString() ?? '';
final notes = data['notes']?.toString() ?? '';

if (_contains(query, [
patientName,
doctorName,
date,
time,
reason,
status,
notes,
])) {
results.add(
_SearchResult(
title: patientName.isEmpty
? 'Appointment'
    : patientName,
subtitle: 'Appointment',
icon: Icons.calendar_month,
type: 'Appointment',
data: data,
),
);
}
}

// ==========================================================
// MEDICAL RECORDS
// ==========================================================

final records = await FirebaseFirestore.instance
    .collection('medical_records')
    .get();

for (final doc in records.docs) {
final data = doc.data();

final patientName =
data['patientName']?.toString() ?? '';
final doctorName =
data['doctorName']?.toString() ?? '';
final diagnosis =
data['diagnosis']?.toString() ?? '';
final date = data['date']?.toString() ?? '';
final treatment =
data['treatment']?.toString() ?? '';
final prescription =
data['prescription']?.toString() ?? '';
final bloodPressure =
data['bloodPressure']?.toString() ?? '';
final temperature =
data['temperature']?.toString() ?? '';
final status = data['status']?.toString() ?? '';
final notes = data['notes']?.toString() ?? '';

if (_contains(query, [
patientName,
doctorName,
diagnosis,
date,
treatment,
prescription,
bloodPressure,
temperature,
status,
notes,
])) {
results.add(
_SearchResult(
title: patientName.isEmpty
? 'Medical Record'
    : patientName,
subtitle: 'Medical Record',
icon: Icons.folder_shared,
type: 'Medical Record',
data: data,
),
);
}
}

// ==========================================================
// PHARMACY
// ==========================================================

final medicines = await FirebaseFirestore.instance
    .collection('medicines')
    .get();

for (final doc in medicines.docs) {
final data = doc.data();

final name = data['name']?.toString() ?? '';
final medicineName =
data['medicineName']?.toString() ?? '';
final expiry =
data['expiry']?.toString() ?? '';
final stock =
data['stock']?.toString() ?? '';
final price =
data['price']?.toString() ?? '';

final actualName =
name.isNotEmpty ? name : medicineName;

if (_contains(query, [
actualName,
expiry,
stock,
price,
])) {
results.add(
_SearchResult(
title: actualName.isEmpty
? 'Medicine'
    : actualName,
subtitle: 'Pharmacy',
icon: Icons.local_pharmacy,
type: 'Medicine',
data: data,
),
);
}
}

// ==========================================================
// BILLING
// ==========================================================

final bills = await FirebaseFirestore.instance
    .collection('bills')
    .get();

for (final doc in bills.docs) {
final data = doc.data();

final patientName =
data['patientName']?.toString() ?? '';
final description =
data['description']?.toString() ?? '';
final status =
data['status']?.toString() ?? '';
final date =
data['date']?.toString() ?? '';
final amount =
data['amount']?.toString() ?? '';

if (_contains(query, [
patientName,
description,
status,
date,
amount,
])) {
results.add(
_SearchResult(
title: patientName.isEmpty
? 'Bill'
    : patientName,
subtitle: 'Billing',
icon: Icons.receipt_long,
type: 'Bill',
data: data,
),
);
}
}
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Search error: $e'),
),
);
}

if (!mounted) return;

setState(() {
_results = results;
_searching = false;
});
}

bool _contains(
String query,
List<String> values,
) {
for (final value in values) {
if (value.toLowerCase().contains(query)) {
return true;
}
}

return false;
}

void _openResult(_SearchResult result) {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
_SearchDetailScreen(result: result),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Search'),
),
body: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
TextField(
controller: _searchController,
textInputAction: TextInputAction.search,
onSubmitted: (_) {
_searchAll();
},
decoration: InputDecoration(
hintText:
'Search patients, doctors, appointments...',
prefixIcon: const Icon(Icons.search),
suffixIcon: IconButton(
onPressed: _searchAll,
icon: const Icon(Icons.arrow_forward),
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
),

const SizedBox(height: 16),

if (_searching)
const Padding(
padding: EdgeInsets.all(20),
child: CircularProgressIndicator(),
),

if (!_searching)
Expanded(
child: _results.isEmpty
? const Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.search,
size: 60,
color: Colors.grey,
),
SizedBox(height: 12),
Text(
'Search for a person or record',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.grey,
fontSize: 15,
),
),
],
),
)
    : ListView.builder(
itemCount: _results.length,
itemBuilder: (context, index) {
final result = _results[index];

return Card(
margin: const EdgeInsets.only(
bottom: 10,
),
child: ListTile(
leading: CircleAvatar(
backgroundColor:
const Color(0xFFE8F2FF),
child: Icon(
result.icon,
color:
const Color(0xFF0969D8),
),
),
title: Text(
result.title,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
subtitle: Text(
result.subtitle,
),
trailing: const Icon(
Icons.arrow_forward_ios,
size: 15,
),
onTap: () {
_openResult(result);
},
),
);
},
),
),
],
),
),
);
}
}

// ============================================================
// SEARCH RESULT
// ============================================================

class _SearchResult {
final String title;
final String subtitle;
final IconData icon;
final String type;
final Map<String, dynamic> data;

const _SearchResult({
required this.title,
required this.subtitle,
required this.icon,
required this.type,
required this.data,
});
}

// ============================================================
// SEARCH DETAIL SCREEN
// ============================================================

class _SearchDetailScreen extends StatelessWidget {
final _SearchResult result;

const _SearchDetailScreen({
required this.result,
});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text(result.title),
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Center(
child: CircleAvatar(
radius: 40,
backgroundColor:
const Color(0xFFE8F2FF),
child: Icon(
result.icon,
size: 42,
color: const Color(0xFF0969D8),
),
),
),

const SizedBox(height: 15),

Center(
child: Text(
result.title,
style: const TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
),
),
),

const SizedBox(height: 5),

Center(
child: Text(
result.type,
style: const TextStyle(
color: Colors.grey,
fontSize: 15,
),
),
),

const SizedBox(height: 25),

..._buildFields(),
],
),
),
);
}

List<Widget> _buildFields() {
final fields = <Widget>[];

void addField(
String label,
String key,
) {
final value =
result.data[key]?.toString() ?? '';

if (value.trim().isEmpty) {
return;
}

fields.add(
Container(
width: double.infinity,
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
boxShadow: const [
BoxShadow(
blurRadius: 4,
color: Color(0x18000000),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
label,
style: const TextStyle(
fontSize: 13,
color: Colors.grey,
),
),
const SizedBox(height: 5),
Text(
value,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
),
),
],
),
),
);
}

if (result.type == 'Patient') {
addField('Name', 'name');
addField('Age', 'age');
addField('Gender', 'gender');
addField('Disease', 'disease');
addField('Phone', 'phone');
addField('Address', 'address');
addField('Blood Group', 'bloodGroup');
}

if (result.type == 'Doctor') {
addField('Name', 'name');
addField('Specialization', 'specialization');
addField('Experience', 'experience');
addField('Phone', 'phone');
addField('Email', 'email');
addField('Department', 'department');
addField('Availability', 'availability');
}

if (result.type == 'Appointment') {
addField('Patient', 'patientName');
addField('Doctor', 'doctorName');
addField('Date', 'date');
addField('Time', 'time');
addField('Reason', 'reason');
addField('Status', 'status');
addField('Notes', 'notes');
}

if (result.type == 'Medical Record') {
addField('Patient', 'patientName');
addField('Doctor', 'doctorName');
addField('Diagnosis', 'diagnosis');
addField('Date', 'date');
addField('Treatment', 'treatment');
addField('Prescription', 'prescription');
addField('Blood Pressure', 'bloodPressure');
addField('Temperature', 'temperature');
addField('Status', 'status');
addField('Notes', 'notes');
}

if (result.type == 'Medicine') {
addField('Medicine Name', 'name');
addField('Medicine Name', 'medicineName');
addField('Price', 'price');
addField('Stock', 'stock');
addField('Expiry', 'expiry');
}

if (result.type == 'Bill') {
addField('Patient', 'patientName');
addField('Description', 'description');
addField('Amount', 'amount');
addField('Date', 'date');
addField('Status', 'status');
}

return fields;
}
}
