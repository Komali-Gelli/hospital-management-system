import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection('patients')
                .snapshots(),
            builder: (context, patientSnapshot) {
              return StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore
                    .collection('doctors')
                    .snapshots(),
                builder: (context, doctorSnapshot) {
                  return StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: _firestore
                        .collection('appointments')
                        .snapshots(),
                    builder: (context, appointmentSnapshot) {
                      return StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                        stream: _firestore
                            .collection('medical_records')
                            .snapshots(),
                        builder: (
                            context,
                            medicalRecordSnapshot,
                            ) {
                          return StreamBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            stream: _firestore
                                .collection('medicines')
                                .snapshots(),
                            builder: (
                                context,
                                medicineSnapshot,
                                ) {
                              return StreamBuilder<
                                  QuerySnapshot<
                                      Map<String, dynamic>>>(
                                stream: _firestore
                                    .collection('bills')
                                    .snapshots(),
                                builder: (
                                    context,
                                    billSnapshot,
                                    ) {
                                  if (patientSnapshot
                                      .connectionState ==
                                      ConnectionState.waiting ||
                                      doctorSnapshot
                                          .connectionState ==
                                          ConnectionState.waiting ||
                                      appointmentSnapshot
                                          .connectionState ==
                                          ConnectionState.waiting ||
                                      medicalRecordSnapshot
                                          .connectionState ==
                                          ConnectionState.waiting ||
                                      medicineSnapshot
                                          .connectionState ==
                                          ConnectionState.waiting ||
                                      billSnapshot
                                          .connectionState ==
                                          ConnectionState.waiting) {
                                    return const Center(
                                      child:
                                      CircularProgressIndicator(),
                                    );
                                  }

                                  if (patientSnapshot.hasError ||
                                      doctorSnapshot.hasError ||
                                      appointmentSnapshot.hasError ||
                                      medicalRecordSnapshot.hasError ||
                                      medicineSnapshot.hasError ||
                                      billSnapshot.hasError) {
                                    return const Center(
                                      child: Padding(
                                        padding:
                                        EdgeInsets.all(20),
                                        child: Text(
                                          'Unable to load report data.',
                                          textAlign:
                                          TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final patientCount =
                                      patientSnapshot
                                          .data
                                          ?.docs
                                          .length ??
                                          0;

                                  final doctorCount =
                                      doctorSnapshot
                                          .data
                                          ?.docs
                                          .length ??
                                          0;

                                  final appointmentCount =
                                      appointmentSnapshot
                                          .data
                                          ?.docs
                                          .length ??
                                          0;

                                  final medicalRecordCount =
                                      medicalRecordSnapshot
                                          .data
                                          ?.docs
                                          .length ??
                                          0;

                                  final medicineCount =
                                      medicineSnapshot
                                          .data
                                          ?.docs
                                          .length ??
                                          0;

                                  final billCount =
                                      billSnapshot
                                          .data
                                          ?.docs
                                          .length ??
                                          0;

                                  return SingleChildScrollView(
                                    padding:
                                    const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        const Text(
                                          'Hospital Reports',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        const Text(
                                          'Live data stored in Firestore',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 25,
                                        ),

                                        _ReportCard(
                                          title: 'Patients',
                                          icon: Icons.people,
                                          count: patientCount,
                                          color: const Color(
                                            0xFF0969D8,
                                          ),
                                          onTap: () {
                                            _showPatientReport(
                                              context,
                                              patientSnapshot
                                                  .data
                                                  ?.docs ??
                                                  [],
                                            );
                                          },
                                        ),

                                        const SizedBox(
                                          height: 12,
                                        ),

                                        _ReportCard(
                                          title: 'Doctors',
                                          icon: Icons
                                              .medical_services,
                                          count: doctorCount,
                                          color: const Color(
                                            0xFF0969D8,
                                          ),
                                          onTap: () {
                                            _showDoctorReport(
                                              context,
                                              doctorSnapshot
                                                  .data
                                                  ?.docs ??
                                                  [],
                                            );
                                          },
                                        ),

                                        const SizedBox(
                                          height: 12,
                                        ),

                                        _ReportCard(
                                          title: 'Appointments',
                                          icon: Icons
                                              .calendar_month,
                                          count:
                                          appointmentCount,
                                          color: const Color(
                                            0xFF0969D8,
                                          ),
                                          onTap: () {
                                            _showAppointmentReport(
                                              context,
                                              appointmentSnapshot
                                                  .data
                                                  ?.docs ??
                                                  [],
                                            );
                                          },
                                        ),

                                        const SizedBox(
                                          height: 12,
                                        ),

                                        _ReportCard(
                                          title:
                                          'Medical Records',
                                          icon: Icons
                                              .folder_shared,
                                          count:
                                          medicalRecordCount,
                                          color: const Color(
                                            0xFF0969D8,
                                          ),
                                          onTap: () {
                                            _showMedicalRecordReport(
                                              context,
                                              medicalRecordSnapshot
                                                  .data
                                                  ?.docs ??
                                                  [],
                                            );
                                          },
                                        ),

                                        const SizedBox(
                                          height: 12,
                                        ),

                                        _ReportCard(
                                          title: 'Pharmacy',
                                          icon: Icons
                                              .local_pharmacy,
                                          count: medicineCount,
                                          color: const Color(
                                            0xFF0969D8,
                                          ),
                                          onTap: () {
                                            _showMedicineReport(
                                              context,
                                              medicineSnapshot
                                                  .data
                                                  ?.docs ??
                                                  [],
                                            );
                                          },
                                        ),

                                        const SizedBox(
                                          height: 12,
                                        ),

                                        _ReportCard(
                                          title: 'Billing',
                                          icon: Icons
                                              .receipt_long,
                                          count: billCount,
                                          color: const Color(
                                            0xFF0969D8,
                                          ),
                                          onTap: () {
                                            _showBillReport(
                                              context,
                                              billSnapshot
                                                  .data
                                                  ?.docs ??
                                                  [],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PATIENT REPORT
  // ============================================================

  void _showPatientReport(
      BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) {
    _showReportDialog(
      context: context,
      title: 'Patient Report',
      icon: Icons.people,
      children: docs.isEmpty
          ? [
        const Text(
          'No patients found.',
        ),
      ]
          : docs.map((doc) {
        final data = doc.data();

        return _DetailCard(
          title:
          data['name']?.toString() ?? 'Patient',
          details: [
            'Age: ${data['age'] ?? ''}',
            'Gender: ${data['gender'] ?? ''}',
            'Disease: ${data['disease'] ?? ''}',
            'Blood Group: ${data['bloodGroup'] ?? ''}',
            'Phone: ${data['phone'] ?? ''}',
            'Address: ${data['address'] ?? ''}',
          ],
        );
      }).toList(),
    );
  }

  // ============================================================
  // DOCTOR REPORT
  // ============================================================

  void _showDoctorReport(
      BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) {
    _showReportDialog(
      context: context,
      title: 'Doctor Report',
      icon: Icons.medical_services,
      children: docs.isEmpty
          ? [
        const Text(
          'No doctors found.',
        ),
      ]
          : docs.map((doc) {
        final data = doc.data();

        return _DetailCard(
          title:
          data['name']?.toString() ?? 'Doctor',
          details: [
            'Specialization: '
                '${data['specialization'] ?? ''}',
            'Experience: '
                '${data['experience'] ?? ''} years',
            'Phone: ${data['phone'] ?? ''}',
            'Email: ${data['email'] ?? ''}',
            'Department: '
                '${data['department'] ?? ''}',
            'Availability: '
                '${data['availability'] ?? ''}',
          ],
        );
      }).toList(),
    );
  }

  // ============================================================
  // APPOINTMENT REPORT
  // ============================================================

  void _showAppointmentReport(
      BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) {
    _showReportDialog(
      context: context,
      title: 'Appointment Report',
      icon: Icons.calendar_month,
      children: docs.isEmpty
          ? [
        const Text(
          'No appointments found.',
        ),
      ]
          : docs.map((doc) {
        final data = doc.data();

        return _DetailCard(
          title: data['patientName']?.toString() ??
              'Appointment',
          details: [
            'Doctor: '
                '${data['doctorName'] ?? ''}',
            'Date: ${data['date'] ?? ''}',
            'Time: ${data['time'] ?? ''}',
            'Reason: ${data['reason'] ?? ''}',
            'Status: ${data['status'] ?? ''}',
            'Notes: ${data['notes'] ?? ''}',
          ],
        );
      }).toList(),
    );
  }

  // ============================================================
  // MEDICAL RECORD REPORT
  // ============================================================

  void _showMedicalRecordReport(
      BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) {
    _showReportDialog(
      context: context,
      title: 'Medical Records Report',
      icon: Icons.folder_shared,
      children: docs.isEmpty
          ? [
        const Text(
          'No medical records found.',
        ),
      ]
          : docs.map((doc) {
        final data = doc.data();

        return _DetailCard(
          title: data['patientName']?.toString() ??
              'Medical Record',
          details: [
            'Doctor: '
                '${data['doctorName'] ?? ''}',
            'Diagnosis: '
                '${data['diagnosis'] ?? ''}',
            'Date: ${data['date'] ?? ''}',
            'Treatment: '
                '${data['treatment'] ?? ''}',
            'Prescription: '
                '${data['prescription'] ?? ''}',
            'Blood Pressure: '
                '${data['bloodPressure'] ?? ''}',
            'Temperature: '
                '${data['temperature'] ?? ''}',
            'Status: ${data['status'] ?? ''}',
            'Notes: ${data['notes'] ?? ''}',
          ],
        );
      }).toList(),
    );
  }

  // ============================================================
  // PHARMACY REPORT
  // ============================================================

  void _showMedicineReport(
      BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) {
    _showReportDialog(
      context: context,
      title: 'Pharmacy Report',
      icon: Icons.local_pharmacy,
      children: docs.isEmpty
          ? [
        const Text(
          'No medicines found.',
        ),
      ]
          : docs.map((doc) {
        final data = doc.data();

        final medicineName =
        data['name']?.toString().isNotEmpty == true
            ? data['name']
            : data['medicineName'];

        return _DetailCard(
          title:
          medicineName?.toString() ?? 'Medicine',
          details: [
            'Medicine ID: '
                '${data['id'] ?? doc.id}',
            'Price: ${data['price'] ?? ''}',
            'Stock: ${data['stock'] ?? ''}',
            'Expiry: ${data['expiry'] ?? ''}',
          ],
        );
      }).toList(),
    );
  }

  // ============================================================
  // BILL REPORT
  // ============================================================

  void _showBillReport(
      BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) {
    _showReportDialog(
      context: context,
      title: 'Billing Report',
      icon: Icons.receipt_long,
      children: docs.isEmpty
          ? [
        const Text(
          'No bills found.',
        ),
      ]
          : docs.map((doc) {
        final data = doc.data();

        return _DetailCard(
          title:
          data['patientName']?.toString() ?? 'Bill',
          details: [
            'Description: '
                '${data['description'] ?? ''}',
            'Amount: ${data['amount'] ?? ''}',
            'Date: ${data['date'] ?? ''}',
            'Status: ${data['status'] ?? ''}',
          ],
        );
      }).toList(),
    );
  }

  // ============================================================
  // COMMON REPORT DIALOG
  // ============================================================

  void _showReportDialog({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 650,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: const Color(0xFF0969D8),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const Divider(),

                const SizedBox(height: 8),

                Expanded(
                  child: ListView(
                    children: children,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// REPORT CARD
// ============================================================

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor:
                const Color(0xFFE8F2FF),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '$count records',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DETAIL CARD
// ============================================================

class _DetailCard extends StatelessWidget {
  final String title;
  final List<String> details;

  const _DetailCard({
    required this.title,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ...details.map(
                  (detail) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 4,
                ),
                child: Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}