import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../services/notification_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() =>
      _AppointmentsScreenState();
}

class _AppointmentsScreenState
    extends State<AppointmentsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // ADD APPOINTMENT
  // ============================================================

  Future<void> _addAppointment() async {
    final formKey = GlobalKey<FormState>();

    final patientNameController =
    TextEditingController();
    final doctorNameController =
    TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final reasonController = TextEditingController();
    final notesController = TextEditingController();

    String status = 'Pending';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Appointment'),

              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        // =================================================
                        // PATIENT NAME
                        // =================================================

                        TextFormField(
                          controller: patientNameController,
                          decoration:
                          const InputDecoration(
                            labelText: 'Patient Name',
                            prefixIcon: Icon(
                              Icons.person_outline,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter patient name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // =================================================
                        // DOCTOR NAME
                        // =================================================

                        TextFormField(
                          controller: doctorNameController,
                          decoration:
                          const InputDecoration(
                            labelText: 'Doctor Name',
                            prefixIcon: Icon(
                              Icons
                                  .medical_services_outlined,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter doctor name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // =================================================
                        // DATE
                        // =================================================

                        TextFormField(
                          controller: dateController,
                          readOnly: true,
                          decoration:
                          const InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(
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
                              firstDate:
                              DateTime(2020),
                              lastDate:
                              DateTime(2100),
                              initialDate:
                              DateTime.now(),
                            );

                            if (selectedDate != null) {
                              final date =
                                  '${selectedDate.day.toString().padLeft(2, '0')}/'
                                  '${selectedDate.month.toString().padLeft(2, '0')}/'
                                  '${selectedDate.year}';

                              setDialogState(() {
                                dateController.text =
                                    date;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Select date';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // =================================================
                        // TIME
                        // =================================================

                        TextFormField(
                          controller: timeController,
                          readOnly: true,
                          decoration:
                          const InputDecoration(
                            labelText: 'Time',
                            prefixIcon: Icon(
                              Icons
                                  .access_time_outlined,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          onTap: () async {
                            final selectedTime =
                            await showTimePicker(
                              context: context,
                              initialTime:
                              TimeOfDay.now(),
                            );

                            if (selectedTime != null) {
                              setDialogState(() {
                                timeController.text =
                                    selectedTime
                                        .format(context);
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Select time';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // =================================================
                        // REASON
                        // =================================================

                        TextFormField(
                          controller: reasonController,
                          decoration:
                          const InputDecoration(
                            labelText: 'Reason',
                            prefixIcon: Icon(
                              Icons
                                  .description_outlined,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter reason';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // =================================================
                        // STATUS
                        // =================================================

                        DropdownButtonFormField<String>(
                          value: status,
                          decoration:
                          const InputDecoration(
                            labelText: 'Status',
                            prefixIcon: Icon(
                              Icons.info_outline,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'Confirmed',
                              child: Text('Confirmed'),
                            ),
                            DropdownMenuItem(
                              value: 'Completed',
                              child: Text('Completed'),
                            ),
                            DropdownMenuItem(
                              value: 'Cancelled',
                              child: Text('Cancelled'),
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

                        // =================================================
                        // NOTES
                        // =================================================

                        TextFormField(
                          controller: notesController,
                          maxLines: 3,
                          decoration:
                          const InputDecoration(
                            labelText: 'Notes',
                            prefixIcon: Icon(
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
              // DIALOG BUTTONS
              // ==========================================================

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('CANCEL'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!
                        .validate()) {
                      return;
                    }

                    try {
                      // =================================================
                      // CREATE APPOINTMENT ID
                      // =================================================

                      final id =
                          'A${DateTime.now().millisecondsSinceEpoch}';

                      // =================================================
                      // CREATE APPOINTMENT OBJECT
                      // =================================================

                      final appointment =
                      Appointment(
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
                        date:
                        dateController.text.trim(),
                        time:
                        timeController.text.trim(),
                        reason:
                        reasonController.text.trim(),
                        status: status,
                        notes:
                        notesController.text.trim(),
                      );

                      // =================================================
                      // SAVE TO FIRESTORE
                      // =================================================

                      await _firestore
                          .collection('appointments')
                          .doc(id)
                          .set(
                        appointment.toMap(),
                      );

                      // =================================================
                      // CREATE NOTIFICATION
                      // =================================================

                      await NotificationService
                          .appointmentAdded(
                        appointment.patientName,
                      );

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Appointment added successfully',
                          ),
                          backgroundColor:
                          Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error adding appointment: $e',
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
                    const Color(0xFF0969D8),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ADD'),
                ),
              ],
            );
          },
        );
      },
    );

    // ============================================================
    // DISPOSE CONTROLLERS
    // ============================================================

    patientNameController.dispose();
    doctorNameController.dispose();
    dateController.dispose();
    timeController.dispose();
    reasonController.dispose();
    notesController.dispose();
  }

  // ============================================================
  // DELETE APPOINTMENT
  // ============================================================

  Future<void> _deleteAppointment(
      String id) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Appointment deleted successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting appointment: $e',
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
          title: const Text(
            'Delete Appointment',
          ),
          content: const Text(
            'Are you sure you want to delete this appointment?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCEL'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteAppointment(id);
              },
              style:
              ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('DELETE'),
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
      case 'Confirmed':
        return Colors.green;

      case 'Completed':
        return Colors.blue;

      case 'Cancelled':
        return Colors.red;

      default:
        return Colors.orange;
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

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),

      // ==========================================================
      // ADD BUTTON
      // ==========================================================

      floatingActionButton:
      FloatingActionButton(
        onPressed: _addAppointment,
        backgroundColor:
        const Color(0xFF0969D8),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints:
            const BoxConstraints(
              maxWidth: 500,
            ),
            padding:
            const EdgeInsets.all(16),

            child: Column(
              children: [
                // ==================================================
                // APPOINTMENT LIST
                // ==================================================

                Expanded(
                  child:
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('appointments')
                        .snapshots(),

                    builder:
                        (context, snapshot) {
                      // =================================================
                      // LOADING
                      // =================================================

                      if (snapshot
                          .connectionState ==
                          ConnectionState
                              .waiting) {
                        return const Center(
                          child:
                          CircularProgressIndicator(),
                        );
                      }

                      // =================================================
                      // ERROR
                      // =================================================

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading appointments:\n'
                                '${snapshot.error}',
                            textAlign:
                            TextAlign.center,
                          ),
                        );
                      }

                      final documents =
                          snapshot.data?.docs ??
                              [];

                      // =================================================
                      // CONVERT FIRESTORE DATA
                      // =================================================

                      final appointments =
                      documents.map((document) {
                        final data =
                        document.data()
                        as Map<String,
                            dynamic>;

                        return Appointment.fromMap(
                          data,
                        );
                      }).toList();

                      // =================================================
                      // EMPTY LIST
                      // =================================================

                      if (appointments.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                            children: [
                              Icon(
                                Icons
                                    .calendar_month_outlined,
                                size: 60,
                                color: Colors.grey,
                              ),

                              SizedBox(height: 12),

                              Text(
                                'No appointments found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),

                              SizedBox(height: 6),

                              Text(
                                'Tap + to add an appointment',
                                style: TextStyle(
                                  color:
                                  Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // =================================================
                      // APPOINTMENT LIST
                      // =================================================

                      return ListView.builder(
                        itemCount:
                        appointments.length,

                        itemBuilder:
                            (context, index) {
                          final appointment =
                          appointments[index];

                          return Card(
                            margin:
                            const EdgeInsets
                                .only(
                              bottom: 12,
                            ),
                            color: Colors.white,
                            elevation: 1,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(12),
                            ),

                            child: Padding(
                              padding:
                              const EdgeInsets
                                  .all(14),

                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [
                                  // =================================================
                                  // ICON
                                  // =================================================

                                  CircleAvatar(
                                    radius: 27,
                                    backgroundColor:
                                    const Color(
                                      0xFFE8F2FF,
                                    ),
                                    child:
                                    const Icon(
                                      Icons
                                          .calendar_month_outlined,
                                      color:
                                      Color(
                                        0xFF0969D8,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  // =================================================
                                  // APPOINTMENT DETAILS
                                  // =================================================

                                  Expanded(
                                    child:
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                      children: [
                                        // Patient
                                        Text(
                                          appointment
                                              .patientName,
                                          style:
                                          const TextStyle(
                                            fontSize:
                                            17,
                                            fontWeight:
                                            FontWeight
                                                .bold,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 4),

                                        // Doctor
                                        Text(
                                          'Doctor: ${appointment.doctorName}',
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
                                            height: 7),

                                        // Date
                                        Text(
                                          'Date: ${appointment.date}',
                                        ),

                                        const SizedBox(
                                            height: 4),

                                        // Time
                                        Text(
                                          'Time: ${appointment.time}',
                                        ),

                                        const SizedBox(
                                            height: 4),

                                        // Reason
                                        Text(
                                          'Reason: ${appointment.reason}',
                                        ),

                                        const SizedBox(
                                            height: 8),

                                        // Status
                                        Container(
                                          padding:
                                          const EdgeInsets
                                              .symmetric(
                                            horizontal:
                                            10,
                                            vertical: 5,
                                          ),
                                          decoration:
                                          BoxDecoration(
                                            color:
                                            _statusColor(
                                              appointment
                                                  .status,
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
                                            appointment
                                                .status,
                                            style:
                                            TextStyle(
                                              color:
                                              _statusColor(
                                                appointment
                                                    .status,
                                              ),
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              fontSize:
                                              12,
                                            ),
                                          ),
                                        ),

                                        // Notes
                                        if (appointment
                                            .notes
                                            .isNotEmpty) ...[
                                          const SizedBox(
                                              height: 7),
                                          Text(
                                            'Notes: ${appointment.notes}',
                                            style:
                                            const TextStyle(
                                              color:
                                              Colors
                                                  .grey,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // =================================================
                                  // DELETE
                                  // =================================================

                                  IconButton(
                                    onPressed: () {
                                      _showDeleteDialog(
                                        appointment.id,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}