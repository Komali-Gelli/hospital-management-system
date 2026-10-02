import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/medical_record.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() =>
      _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState
    extends State<MedicalRecordsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // ADD MEDICAL RECORD
  // ============================================================

  Future<void> _addMedicalRecord() async {
    final formKey = GlobalKey<FormState>();

    final patientNameController = TextEditingController();
    final doctorNameController = TextEditingController();
    final diagnosisController = TextEditingController();
    final dateController = TextEditingController();
    final treatmentController = TextEditingController();
    final prescriptionController = TextEditingController();
    final bloodPressureController = TextEditingController();
    final temperatureController = TextEditingController();
    final notesController = TextEditingController();

    String status = 'Active';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Medical Record'),

              content: SizedBox(
                width: 450,

                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,

                    child: Column(
                      children: [

                        // ------------------------------------------------
                        // PATIENT NAME
                        // ------------------------------------------------

                        TextFormField(
                          controller:
                          patientNameController,

                          decoration:
                          const InputDecoration(
                            labelText: 'Patient Name',
                            prefixIcon:
                            Icon(
                              Icons.person_outline,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return
                                'Enter patient name';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // DOCTOR NAME
                        // ------------------------------------------------

                        TextFormField(
                          controller:
                          doctorNameController,

                          decoration:
                          const InputDecoration(
                            labelText: 'Doctor Name',
                            prefixIcon:
                            Icon(
                              Icons
                                  .medical_services_outlined,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return
                                'Enter doctor name';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // DIAGNOSIS
                        // ------------------------------------------------

                        TextFormField(
                          controller:
                          diagnosisController,

                          maxLines: 2,

                          decoration:
                          const InputDecoration(
                            labelText: 'Diagnosis',
                            prefixIcon:
                            Icon(
                              Icons
                                  .health_and_safety_outlined,
                            ),
                            border:
                            OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return
                                'Enter diagnosis';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // DATE
                        // ------------------------------------------------

                        TextFormField(
                          controller:
                          dateController,

                          readOnly: true,

                          decoration:
                          const InputDecoration(
                            labelText: 'Date',
                            prefixIcon:
                            Icon(
                              Icons
                                  .calendar_today_outlined,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),

                          onTap: () async {
                            final selectedDate =
                            await showDatePicker(
                              context: context,
                              initialDate:
                              DateTime.now(),
                              firstDate:
                              DateTime(2020),
                              lastDate:
                              DateTime(2100),
                            );

                            if (selectedDate != null) {
                              setDialogState(() {
                                dateController.text =
                                '${selectedDate.day.toString().padLeft(2, '0')}/'
                                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                                    '${selectedDate.year}';
                              });
                            }
                          },

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return
                                'Select date';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // TREATMENT
                        // ------------------------------------------------

                        TextFormField(
                          controller:
                          treatmentController,

                          maxLines: 2,

                          decoration:
                          const InputDecoration(
                            labelText: 'Treatment',
                            prefixIcon:
                            Icon(
                              Icons
                                  .healing_outlined,
                            ),
                            border:
                            OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return
                                'Enter treatment';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // PRESCRIPTION
                        // ------------------------------------------------

                        TextFormField(
                          controller:
                          prescriptionController,

                          maxLines: 2,

                          decoration:
                          const InputDecoration(
                            labelText: 'Prescription',
                            prefixIcon:
                            Icon(
                              Icons
                                  .medication_outlined,
                            ),
                            border:
                            OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // BLOOD PRESSURE
                        // ------------------------------------------------

                        TextFormField(
                          controller:
                          bloodPressureController,

                          decoration:
                          const InputDecoration(
                            labelText:
                            'Blood Pressure',
                            hintText:
                            'Example: 120/80',
                            prefixIcon:
                            Icon(
                              Icons
                                  .favorite_outline,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // TEMPERATURE
                        // ------------------------------------------------

                        TextFormField(
                          controller:
                          temperatureController,

                          keyboardType:
                          const TextInputType
                              .numberWithOptions(
                            decimal: true,
                          ),

                          decoration:
                          const InputDecoration(
                            labelText:
                            'Temperature',
                            hintText:
                            'Example: 98.6 °F',
                            prefixIcon:
                            Icon(
                              Icons
                                  .thermostat_outlined,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // STATUS
                        // ------------------------------------------------

                        DropdownButtonFormField<String>(
                          initialValue: status,

                          decoration:
                          const InputDecoration(
                            labelText: 'Status',
                            prefixIcon:
                            Icon(
                              Icons.info_outline,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),

                          items: const [
                            DropdownMenuItem(
                              value: 'Active',
                              child:
                              Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'Completed',
                              child:
                              Text('Completed'),
                            ),
                            DropdownMenuItem(
                              value: 'Follow-up',
                              child:
                              Text('Follow-up'),
                            ),
                          ],

                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                status = value;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // NOTES
                        // ------------------------------------------------

                        TextFormField(
                          controller:
                          notesController,

                          maxLines: 3,

                          decoration:
                          const InputDecoration(
                            labelText: 'Notes',
                            prefixIcon:
                            Icon(
                              Icons.notes_outlined,
                            ),
                            border:
                            OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==========================================================
              // BUTTONS
              // ==========================================================

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                  const Text('CANCEL'),
                ),

                ElevatedButton(
                  onPressed: () async {

                    if (!formKey.currentState!
                        .validate()) {
                      return;
                    }

                    try {

                      // --------------------------------------------------
                      // CREATE MEDICAL RECORD
                      // --------------------------------------------------

                      final id =
                          'MR${DateTime.now().millisecondsSinceEpoch}';

                      final record =
                      MedicalRecord(
                        id: id,

                        patientId: '',

                        patientName:
                        patientNameController
                            .text
                            .trim(),

                        doctorId: '',

                        doctorName:
                        doctorNameController
                            .text
                            .trim(),

                        diagnosis:
                        diagnosisController
                            .text
                            .trim(),

                        date:
                        dateController
                            .text
                            .trim(),

                        treatment:
                        treatmentController
                            .text
                            .trim(),

                        prescription:
                        prescriptionController
                            .text
                            .trim(),

                        bloodPressure:
                        bloodPressureController
                            .text
                            .trim(),

                        temperature:
                        temperatureController
                            .text
                            .trim(),

                        status: status,

                        notes:
                        notesController
                            .text
                            .trim(),
                      );

                      // --------------------------------------------------
                      // SAVE MEDICAL RECORD
                      // --------------------------------------------------

                      await _firestore
                          .collection(
                          'medical_records')
                          .doc(id)
                          .set(
                        record.toMap(),
                      );

                      // --------------------------------------------------
                      // CREATE NOTIFICATION
                      // --------------------------------------------------

                      await _firestore
                          .collection(
                          'notifications')
                          .add({
                        'title':
                        'New Medical Record',

                        'message':
                        'Medical record for '
                            '${record.patientName} '
                            'has been added.',

                        'type':
                        'medical_record',

                        'createdAt':
                        FieldValue
                            .serverTimestamp(),

                        'read': false,
                      });

                      // --------------------------------------------------
                      // SUCCESS
                      // --------------------------------------------------

                      if (!mounted) return;

                      Navigator.pop(
                        dialogContext,
                      );

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Medical record added successfully',
                          ),
                          backgroundColor:
                          Colors.green,
                        ),
                      );

                    } catch (e) {

                      if (!mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error adding medical record: $e',
                          ),
                          backgroundColor:
                          Colors.red,
                        ),
                      );
                    }
                  },

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(
                      0xFF0969D8,
                    ),
                    foregroundColor:
                    Colors.white,
                  ),

                  child:
                  const Text('ADD'),
                ),
              ],
            );
          },
        );
      },
    );

    // ==========================================================
    // DISPOSE CONTROLLERS
    // ==========================================================

    patientNameController.dispose();
    doctorNameController.dispose();
    diagnosisController.dispose();
    dateController.dispose();
    treatmentController.dispose();
    prescriptionController.dispose();
    bloodPressureController.dispose();
    temperatureController.dispose();
    notesController.dispose();
  }

  // ============================================================
  // DELETE MEDICAL RECORD
  // ============================================================

  Future<void> _deleteRecord(String id) async {
    try {
      await _firestore
          .collection('medical_records')
          .doc(id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Medical record deleted successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting medical record: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
          const Text('Delete Medical Record'),

          content: const Text(
            'Are you sure you want to delete this medical record?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
              const Text('CANCEL'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _deleteRecord(id);
              },

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.red,
                foregroundColor:
                Colors.white,
              ),

              child:
              const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;

      case 'Follow-up':
        return Colors.orange;

      default:
        return Colors.blue;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F9FC),

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBar: AppBar(
        title: const Text(
          'Medical Records',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
        Colors.white,

        surfaceTintColor:
        Colors.white,

        elevation: 0,
      ),

      // ----------------------------------------------------------
      // ADD BUTTON
      // ----------------------------------------------------------

      floatingActionButton:
      FloatingActionButton(
        onPressed:
        _addMedicalRecord,

        backgroundColor:
        const Color(0xFF0969D8),

        foregroundColor:
        Colors.white,

        child:
        const Icon(Icons.add),
      ),

      // ----------------------------------------------------------
      // BODY
      // ----------------------------------------------------------

      body: SafeArea(
        child: Center(
          child: Container(
            width:
            double.infinity,

            constraints:
            const BoxConstraints(
              maxWidth: 500,
            ),

            padding:
            const EdgeInsets.all(16),

            // NO INTERNAL SEARCH BAR
            child:
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(
                  'medical_records')
                  .snapshots(),

              builder:
                  (context, snapshot) {

                // ------------------------------------------------
                // LOADING
                // ------------------------------------------------

                if (snapshot
                    .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                // ------------------------------------------------
                // ERROR
                // ------------------------------------------------

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading medical records:\n'
                          '${snapshot.error}',
                      textAlign:
                      TextAlign.center,
                    ),
                  );
                }

                // ------------------------------------------------
                // DOCUMENTS
                // ------------------------------------------------

                final documents =
                    snapshot.data?.docs ??
                        [];

                // ------------------------------------------------
                // CONVERT TO MEDICAL RECORDS
                // ------------------------------------------------

                final records =
                documents.map((document) {

                  final data =
                  document.data()
                  as Map<String,
                      dynamic>;

                  return MedicalRecord
                      .fromMap(data);

                }).toList();

                // ------------------------------------------------
                // EMPTY
                // ------------------------------------------------

                if (records.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                      children: [

                        Icon(
                          Icons
                              .folder_shared_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),

                        SizedBox(
                          height: 12,
                        ),

                        Text(
                          'No medical records found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        SizedBox(
                          height: 6,
                        ),

                        Text(
                          'Tap + to add a medical record',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // ------------------------------------------------
                // RECORD LIST
                // ------------------------------------------------

                return ListView.builder(
                  itemCount:
                  records.length,

                  itemBuilder:
                      (context, index) {

                    final record =
                    records[index];

                    return Card(
                      margin:
                      const EdgeInsets
                          .only(
                        bottom: 12,
                      ),

                      color:
                      Colors.white,

                      elevation: 1,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          12,
                        ),
                      ),

                      child:
                      Padding(
                        padding:
                        const EdgeInsets
                            .all(
                          14,
                        ),

                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            // ------------------------------------------
                            // ICON
                            // ------------------------------------------

                            CircleAvatar(
                              radius: 27,

                              backgroundColor:
                              const Color(
                                0xFFE8F2FF,
                              ),

                              child:
                              const Icon(
                                Icons
                                    .folder_shared_outlined,

                                color:
                                Color(
                                  0xFF0969D8,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            // ------------------------------------------
                            // DETAILS
                            // ------------------------------------------

                            Expanded(
                              child:
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [

                                  Text(
                                    record
                                        .patientName,

                                    style:
                                    const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    'Doctor: ${record.doctorName}',

                                    style:
                                    const TextStyle(
                                      color:
                                      Color(
                                        0xFF0969D8,
                                      ),
                                      fontWeight:
                                      FontWeight
                                          .w600,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Text(
                                    'Diagnosis: ${record.diagnosis}',
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    'Date: ${record.date}',
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    'Treatment: ${record.treatment}',
                                  ),

                                  if (record
                                      .prescription
                                      .isNotEmpty) ...[
                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      'Prescription: '
                                          '${record.prescription}',
                                    ),
                                  ],

                                  if (record
                                      .bloodPressure
                                      .isNotEmpty) ...[
                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      'Blood Pressure: '
                                          '${record.bloodPressure}',
                                    ),
                                  ],

                                  if (record
                                      .temperature
                                      .isNotEmpty) ...[
                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      'Temperature: '
                                          '${record.temperature}',
                                    ),
                                  ],

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  // ----------------------------------------
                                  // STATUS
                                  // ----------------------------------------

                                  Container(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),

                                    decoration:
                                    BoxDecoration(
                                      color:
                                      _statusColor(
                                        record.status,
                                      ).withOpacity(
                                        0.12,
                                      ),

                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        20,
                                      ),
                                    ),

                                    child:
                                    Text(
                                      record.status,

                                      style:
                                      TextStyle(
                                        color:
                                        _statusColor(
                                          record.status,
                                        ),

                                        fontWeight:
                                        FontWeight
                                            .bold,

                                        fontSize:
                                        12,
                                      ),
                                    ),
                                  ),

                                  // ----------------------------------------
                                  // NOTES
                                  // ----------------------------------------

                                  if (record
                                      .notes
                                      .isNotEmpty) ...[
                                    const SizedBox(
                                      height: 7,
                                    ),

                                    Text(
                                      'Notes: ${record.notes}',

                                      style:
                                      const TextStyle(
                                        color:
                                        Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // ------------------------------------------
                            // DELETE
                            // ------------------------------------------

                            IconButton(
                              onPressed: () {
                                _showDeleteDialog(
                                  record.id,
                                );
                              },

                              icon:
                              const Icon(
                                Icons
                                    .delete_outline,
                                color:
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}