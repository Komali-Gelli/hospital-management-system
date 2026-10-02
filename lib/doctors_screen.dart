import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../services/notification_service.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // ADD DOCTOR
  // ============================================================

  Future<void> addDoctor() async {
    final nameController = TextEditingController();
    final specializationController = TextEditingController();
    final experienceController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final departmentController = TextEditingController();
    final availabilityController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add Doctor',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // Doctor Name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Doctor Name',
                        border: OutlineInputBorder(),
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

                    // Specialization
                    TextFormField(
                      controller:
                      specializationController,
                      decoration: const InputDecoration(
                        labelText: 'Specialization',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter specialization';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Experience
                    TextFormField(
                      controller: experienceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Experience in Years',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter experience';
                        }

                        if (int.tryParse(value.trim()) ==
                            null) {
                          return 'Enter a valid number';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Phone
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: emailController,
                      keyboardType:
                      TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter email';
                        }

                        if (!value.contains('@')) {
                          return 'Enter valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Department
                    TextFormField(
                      controller: departmentController,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter department';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Availability
                    TextFormField(
                      controller: availabilityController,
                      decoration: const InputDecoration(
                        labelText: 'Availability',
                        hintText:
                        'Example: Mon-Fri 9 AM - 5 PM',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter availability';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCEL'),
            ),

            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                try {
                  final id =
                      'D${DateTime.now().millisecondsSinceEpoch}';

                  final doctor = Doctor(
                    id: id,
                    name: nameController.text.trim(),
                    specialization:
                    specializationController.text.trim(),
                    experience: int.parse(
                      experienceController.text.trim(),
                    ),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    department:
                    departmentController.text.trim(),
                    availability:
                    availabilityController.text.trim(),
                  );

                  // Save doctor to Firestore
                  await _firestore
                      .collection('doctors')
                      .doc(id)
                      .set(doctor.toMap());

                  // Create notification
                  await NotificationService.doctorAdded(
                    doctor.name,
                  );

                  if (!mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Doctor added successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error adding doctor: $e',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
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

    // Dispose controllers
    nameController.dispose();
    specializationController.dispose();
    experienceController.dispose();
    phoneController.dispose();
    emailController.dispose();
    departmentController.dispose();
    availabilityController.dispose();
  }

  // ============================================================
  // DELETE DOCTOR
  // ============================================================

  Future<void> deleteDoctor(String id) async {
    try {
      await _firestore
          .collection('doctors')
          .doc(id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Doctor deleted successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting doctor: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  void showDeleteDialog(
      String id,
      String name,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Doctor',
          ),
          content: Text(
            'Are you sure you want to delete Dr. $name?',
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
                deleteDoctor(id);
              },
              style: ElevatedButton.styleFrom(
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'Doctors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),

      // ========================================================
      // ADD DOCTOR BUTTON
      // ========================================================

      floatingActionButton: FloatingActionButton(
        onPressed: addDoctor,
        backgroundColor: const Color(0xFF0969D8),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            padding: const EdgeInsets.all(16),

            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('doctors')
                  .snapshots(),

              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading doctors:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final documents =
                    snapshot.data?.docs ?? [];

                // Convert Firestore data to Doctor objects
                final doctors = documents.map((document) {
                  final data = document.data();

                  return Doctor.fromMap(data);
                }).toList();

                // =================================================
                // NO DOCTORS
                // =================================================

                if (doctors.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No doctors found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'Tap + to add a doctor',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // =================================================
                // DOCTOR LIST
                // =================================================

                return ListView.builder(
                  itemCount: doctors.length,

                  itemBuilder: (context, index) {
                    final doctor = doctors[index];

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),

                      color: Colors.white,

                      elevation: 1,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(14),

                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            // ====================================
                            // DOCTOR ICON
                            // ====================================

                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                              const Color(0xFFE8F2FF),

                              child: const Icon(
                                Icons
                                    .medical_services_outlined,
                                color:
                                Color(0xFF0969D8),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // ====================================
                            // DOCTOR INFORMATION
                            // ====================================

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    doctor.specialization,
                                    style:
                                    const TextStyle(
                                      color:
                                      Color(0xFF0969D8),
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    '${doctor.experience} years experience',
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Department: '
                                        '${doctor.department}',
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Phone: '
                                        '${doctor.phone}',
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Email: '
                                        '${doctor.email}',
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Available: '
                                        '${doctor.availability}',
                                  ),
                                ],
                              ),
                            ),

                            // ====================================
                            // DELETE BUTTON
                            // ====================================

                            IconButton(
                              onPressed: () {
                                showDeleteDialog(
                                  doctor.id,
                                  doctor.name,
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
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