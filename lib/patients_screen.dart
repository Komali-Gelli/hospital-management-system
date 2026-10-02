import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/patient.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({
    super.key,
  });

  @override
  State<PatientsScreen> createState() =>
      _PatientsScreenState();
}

class _PatientsScreenState
    extends State<PatientsScreen> {
  final CollectionReference<Map<String, dynamic>>
  _patientsCollection =
  FirebaseFirestore.instance.collection('patients');

  // ============================================================
// ADD PATIENT
// ============================================================

  Future<void> _addPatient() async {
    final result = await showDialog<Patient>(
      context: context,
      builder: (context) {
        return const _PatientDialog();
      },
    );

    if (result == null) return;

    try {
      // ----------------------------------------------------------
      // SAVE PATIENT TO FIRESTORE
      // ----------------------------------------------------------

      await _patientsCollection
          .doc(result.id)
          .set(result.toMap());

      // ----------------------------------------------------------
      // CREATE NOTIFICATION
      // ----------------------------------------------------------

      await FirebaseFirestore.instance
          .collection('notifications')
          .add({
        'title': 'New Patient',
        'message':
        '${result.name} has been added as a new patient.',
        'type': 'patient',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      // ----------------------------------------------------------
      // SUCCESS MESSAGE
      // ----------------------------------------------------------

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Patient added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to add patient: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // ============================================================
  // DELETE PATIENT
  // ============================================================

  Future<void> _deletePatient(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Patient',
          ),
          content: const Text(
            'Are you sure you want to delete this patient?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _patientsCollection
          .doc(id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Patient deleted successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete patient: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // EDIT PATIENT
  // ============================================================

  Future<void> _editPatient(
      Patient patient,
      ) async {
    final result = await showDialog<Patient>(
      context: context,
      builder: (context) {
        return _PatientDialog(
          patient: patient,
        );
      },
    );

    if (result == null) return;

    try {
      await _patientsCollection
          .doc(result.id)
          .update(result.toMap());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Patient updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update patient: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      // --------------------------------------------------------
      // APP BAR
      // --------------------------------------------------------

      appBar: AppBar(
        title: const Text(
          'Patients',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),

      // --------------------------------------------------------
      // ADD BUTTON
      // --------------------------------------------------------

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _addPatient,
        backgroundColor:
        const Color(0xFF0969D8),
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.person_add,
        ),
        label: const Text(
          'Add Patient',
        ),
      ),

      // --------------------------------------------------------
      // BODY
      // --------------------------------------------------------

      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                // ------------------------------------------------
                // PATIENT LIST
                // ------------------------------------------------

                Expanded(
                  child: StreamBuilder<
                      QuerySnapshot<
                          Map<String, dynamic>>>(
                    stream:
                    _patientsCollection.snapshots(),

                    builder:
                        (context, snapshot) {

                      // ------------------------------------------------
                      // LOADING
                      // ------------------------------------------------

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
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
                            'Error loading patients:\n'
                                '${snapshot.error}',
                            textAlign:
                            TextAlign.center,
                          ),
                        );
                      }

                      // ------------------------------------------------
                      // FIRESTORE DOCUMENTS
                      // ------------------------------------------------

                      final documents =
                          snapshot.data?.docs ?? [];

                      // ------------------------------------------------
                      // CONVERT TO PATIENT OBJECTS
                      // ------------------------------------------------

                      final patients =
                      documents
                          .map(
                            (doc) =>
                            Patient.fromMap(
                              doc.data(),
                            ),
                      )
                          .toList();

                      // ------------------------------------------------
                      // EMPTY
                      // ------------------------------------------------

                      if (patients.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [

                              Icon(
                                Icons
                                    .people_outline,
                                size: 70,
                                color:
                                Colors.grey,
                              ),

                              SizedBox(
                                height: 15,
                              ),

                              Text(
                                'No patients found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),

                              SizedBox(
                                height: 5,
                              ),

                              Text(
                                'Tap "Add Patient" to create a patient.',
                                textAlign:
                                TextAlign.center,
                                style: TextStyle(
                                  color:
                                  Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // ------------------------------------------------
                      // PATIENT CARDS
                      // ------------------------------------------------

                      return ListView.builder(
                        itemCount:
                        patients.length,

                        itemBuilder:
                            (context, index) {

                          final patient =
                          patients[index];

                          return Card(
                            color: Colors.white,
                            margin:
                            const EdgeInsets.only(
                              bottom: 12,
                            ),
                            elevation: 1,

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),

                            child: Padding(
                              padding:
                              const EdgeInsets.all(
                                15,
                              ),

                              child: Column(
                                children: [

                                  // ======================================
                                  // PATIENT HEADER
                                  // ======================================

                                  Row(
                                    children: [

                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                        const Color(
                                          0xFFE8F2FF,
                                        ),
                                        child:
                                        const Icon(
                                          Icons.person,
                                          color:
                                          Color(
                                            0xFF0969D8,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 12,
                                      ),

                                      Expanded(
                                        child:
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [

                                            Text(
                                              patient.name,
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
                                              height: 4,
                                            ),

                                            Text(
                                              '${patient.age} years • '
                                                  '${patient.gender}',
                                              style:
                                              const TextStyle(
                                                color:
                                                Colors
                                                    .grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ==================================
                                      // MENU
                                      // ==================================

                                      PopupMenuButton<
                                          String>(
                                        onSelected:
                                            (value) {

                                          if (value ==
                                              'edit') {
                                            _editPatient(
                                              patient,
                                            );
                                          }

                                          if (value ==
                                              'delete') {
                                            _deletePatient(
                                              patient.id,
                                            );
                                          }
                                        },

                                        itemBuilder:
                                            (context) =>
                                        const [

                                          PopupMenuItem(
                                            value:
                                            'edit',
                                            child:
                                            Row(
                                              children: [

                                                Icon(
                                                  Icons
                                                      .edit_outlined,
                                                ),

                                                SizedBox(
                                                  width:
                                                  8,
                                                ),

                                                Text(
                                                  'Edit',
                                                ),
                                              ],
                                            ),
                                          ),

                                          PopupMenuItem(
                                            value:
                                            'delete',
                                            child:
                                            Row(
                                              children: [

                                                Icon(
                                                  Icons
                                                      .delete_outline,
                                                  color:
                                                  Colors
                                                      .red,
                                                ),

                                                SizedBox(
                                                  width:
                                                  8,
                                                ),

                                                Text(
                                                  'Delete',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const Divider(
                                    height: 25,
                                  ),

                                  // ======================================
                                  // DISEASE
                                  // ======================================

                                  _infoRow(
                                    Icons
                                        .medical_information_outlined,
                                    'Disease',
                                    patient.disease,
                                  ),

                                  // ======================================
                                  // BLOOD GROUP
                                  // ======================================

                                  _infoRow(
                                    Icons
                                        .bloodtype_outlined,
                                    'Blood Group',
                                    patient.bloodGroup,
                                  ),

                                  // ======================================
                                  // PHONE
                                  // ======================================

                                  _infoRow(
                                    Icons.phone_outlined,
                                    'Phone',
                                    patient.phone,
                                  ),

                                  // ======================================
                                  // ADDRESS
                                  // ======================================

                                  _infoRow(
                                    Icons
                                        .location_on_outlined,
                                    'Address',
                                    patient.address,
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

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _infoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 8),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            size: 19,
            color: const Color(0xFF0969D8),
          ),

          const SizedBox(
            width: 8,
          ),

          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADD / EDIT PATIENT DIALOG
// ============================================================

class _PatientDialog extends StatefulWidget {
  final Patient? patient;

  const _PatientDialog({
    this.patient,
  });

  @override
  State<_PatientDialog> createState() =>
      _PatientDialogState();
}

class _PatientDialogState
    extends State<_PatientDialog> {

  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _nameController;

  late final TextEditingController
  _ageController;

  late final TextEditingController
  _diseaseController;

  late final TextEditingController
  _phoneController;

  late final TextEditingController
  _addressController;

  String _gender = 'Male';

  String _bloodGroup = 'A+';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final patient =
        widget.patient;

    _nameController =
        TextEditingController(
          text: patient?.name ?? '',
        );

    _ageController =
        TextEditingController(
          text: patient != null
              ? patient.age.toString()
              : '',
        );

    _diseaseController =
        TextEditingController(
          text: patient?.disease ?? '',
        );

    _phoneController =
        TextEditingController(
          text: patient?.phone ?? '',
        );

    _addressController =
        TextEditingController(
          text: patient?.address ?? '',
        );

    if (patient != null) {
      _gender = patient.gender;
      _bloodGroup =
          patient.bloodGroup;
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _diseaseController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  void _save() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final patient = Patient(
      id: widget.patient?.id ??
          'P${DateTime.now().millisecondsSinceEpoch}',

      name:
      _nameController.text.trim(),

      age: int.parse(
        _ageController.text.trim(),
      ),

      gender: _gender,

      disease:
      _diseaseController.text.trim(),

      phone:
      _phoneController.text.trim(),

      address:
      _addressController.text.trim(),

      bloodGroup: _bloodGroup,
    );

    Navigator.pop(
      context,
      patient,
    );
  }

  // ============================================================
  // BUILD DIALOG
  // ============================================================

  @override
  Widget build(BuildContext context) {

    final isEditing =
        widget.patient != null;

    return AlertDialog(
      title: Text(
        isEditing
            ? 'Edit Patient'
            : 'Add Patient',
      ),

      content: SizedBox(
        width: 450,

        child: SingleChildScrollView(
          child: Form(
            key: _formKey,

            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              children: [

                // ------------------------------------------------
                // NAME
                // ------------------------------------------------

                TextFormField(
                  controller:
                  _nameController,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Patient Name',
                    prefixIcon:
                    Icon(
                      Icons.person_outline,
                    ),
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

                const SizedBox(
                  height: 12,
                ),

                // ------------------------------------------------
                // AGE
                // ------------------------------------------------

                TextFormField(
                  controller:
                  _ageController,
                  keyboardType:
                  TextInputType.number,
                  decoration:
                  const InputDecoration(
                    labelText: 'Age',
                    prefixIcon:
                    Icon(
                      Icons
                          .calendar_today_outlined,
                    ),
                  ),
                  validator: (value) {

                    final age =
                    int.tryParse(
                      value?.trim() ??
                          '',
                    );

                    if (age == null ||
                        age <= 0) {
                      return
                        'Enter a valid age';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                // ------------------------------------------------
                // GENDER
                // ------------------------------------------------

                DropdownButtonFormField<
                    String>(
                  value: _gender,

                  decoration:
                  const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon:
                    Icon(
                      Icons
                          .person_outline,
                    ),
                  ),

                  items: const [

                    DropdownMenuItem(
                      value: 'Male',
                      child:
                      Text('Male'),
                    ),

                    DropdownMenuItem(
                      value: 'Female',
                      child:
                      Text('Female'),
                    ),

                    DropdownMenuItem(
                      value: 'Other',
                      child:
                      Text('Other'),
                    ),
                  ],

                  onChanged:
                      (value) {
                    if (value != null) {
                      setState(() {
                        _gender = value;
                      });
                    }
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                // ------------------------------------------------
                // DISEASE
                // ------------------------------------------------

                TextFormField(
                  controller:
                  _diseaseController,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Disease',
                    prefixIcon:
                    Icon(
                      Icons
                          .medical_information_outlined,
                    ),
                  ),
                  validator: (value) {

                    if (value == null ||
                        value.trim().isEmpty) {
                      return
                        'Enter disease';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                // ------------------------------------------------
                // BLOOD GROUP
                // ------------------------------------------------

                DropdownButtonFormField<
                    String>(
                  value: _bloodGroup,

                  decoration:
                  const InputDecoration(
                    labelText:
                    'Blood Group',
                    prefixIcon:
                    Icon(
                      Icons
                          .bloodtype_outlined,
                    ),
                  ),

                  items: const [

                    DropdownMenuItem(
                      value: 'A+',
                      child:
                      Text('A+'),
                    ),

                    DropdownMenuItem(
                      value: 'A-',
                      child:
                      Text('A-'),
                    ),

                    DropdownMenuItem(
                      value: 'B+',
                      child:
                      Text('B+'),
                    ),

                    DropdownMenuItem(
                      value: 'B-',
                      child:
                      Text('B-'),
                    ),

                    DropdownMenuItem(
                      value: 'AB+',
                      child:
                      Text('AB+'),
                    ),

                    DropdownMenuItem(
                      value: 'AB-',
                      child:
                      Text('AB-'),
                    ),

                    DropdownMenuItem(
                      value: 'O+',
                      child:
                      Text('O+'),
                    ),

                    DropdownMenuItem(
                      value: 'O-',
                      child:
                      Text('O-'),
                    ),
                  ],

                  onChanged:
                      (value) {
                    if (value != null) {
                      setState(() {
                        _bloodGroup =
                            value;
                      });
                    }
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                // ------------------------------------------------
                // PHONE
                // ------------------------------------------------

                TextFormField(
                  controller:
                  _phoneController,
                  keyboardType:
                  TextInputType.phone,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Phone',
                    prefixIcon:
                    Icon(
                      Icons
                          .phone_outlined,
                    ),
                  ),
                  validator: (value) {

                    if (value == null ||
                        value.trim().length <
                            10) {
                      return
                        'Enter a valid phone number';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                // ------------------------------------------------
                // ADDRESS
                // ------------------------------------------------

                TextFormField(
                  controller:
                  _addressController,
                  maxLines: 2,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Address',
                    prefixIcon:
                    Icon(
                      Icons
                          .location_on_outlined,
                    ),
                  ),
                  validator: (value) {

                    if (value == null ||
                        value.trim().isEmpty) {
                      return
                        'Enter address';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      // ----------------------------------------------------------
      // BUTTONS
      // ----------------------------------------------------------

      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child:
          const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: _save,
          style:
          ElevatedButton.styleFrom(
            backgroundColor:
            const Color(0xFF0969D8),
            foregroundColor:
            Colors.white,
          ),
          child: Text(
            isEditing
                ? 'Update'
                : 'Save',
          ),
        ),
      ],
    );
  }
}