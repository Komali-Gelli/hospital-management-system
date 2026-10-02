import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'appointments_screen.dart';
import 'billing_screen.dart';
import 'doctors_screen.dart';
import 'medical_records_screen.dart';
import 'patients_screen.dart';
import 'pharmacy_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onBottomNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: _buildSelectedScreen(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onBottomNavigationTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: _notificationBell(),
            activeIcon: _notificationBell(),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATION BELL
  // ============================================================

  Widget _notificationBell() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .snapshots(),
      builder: (context, snapshot) {
        int unreadCount = 0;

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data();

            // Missing read field or read == false means unread.
            if (data['read'] != true) {
              unreadCount++;
            }
          }
        }

        final hasUnread = unreadCount > 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_outlined,
              size: 26,
              color: Color(0xFF0969D8),
            ),
            if (hasUnread)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    unreadCount > 99
                        ? '99+'
                        : unreadCount.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SELECTED SCREEN
  // ============================================================

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const _HomeContent();

      case 1:
        return const _GlobalSearchScreen();

      case 2:
        return const _NotificationsScreen();

      case 3:
        return const ProfileScreen();

      default:
        return const _HomeContent();
    }
  }
}

// ============================================================
// HOME
// ============================================================

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  String _getName() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'Admin';
    }

    if (user.displayName != null &&
        user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }

    if (user.email != null && user.email!.contains('@')) {
      return user.email!.split('@').first;
    }

    return 'Admin';
  }

  void _openScreen(
      BuildContext context,
      Widget screen,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _getName();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ======================================================
          // HOSPITAL SERVICES
          // ======================================================

          const Text(
            'Hospital Services',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _ServiceCard(
                title: 'Patients',
                icon: Icons.people,
                onTap: () {
                  _openScreen(
                    context,
                    const PatientsScreen(),
                  );
                },
              ),
              _ServiceCard(
                title: 'Doctors',
                icon: Icons.medical_services,
                onTap: () {
                  _openScreen(
                    context,
                    const DoctorsScreen(),
                  );
                },
              ),
              _ServiceCard(
                title: 'Appointments',
                icon: Icons.calendar_month,
                onTap: () {
                  _openScreen(
                    context,
                    const AppointmentsScreen(),
                  );
                },
              ),
              _ServiceCard(
                title: 'Medical Records',
                icon: Icons.folder_shared,
                onTap: () {
                  _openScreen(
                    context,
                    const MedicalRecordsScreen(),
                  );
                },
              ),
              _ServiceCard(
                title: 'Pharmacy',
                icon: Icons.local_pharmacy,
                onTap: () {
                  _openScreen(
                    context,
                    const PharmacyScreen(),
                  );
                },
              ),
              _ServiceCard(
                title: 'Billing',
                icon: Icons.receipt_long,
                onTap: () {
                  _openScreen(
                    context,
                    const BillingScreen(),
                  );
                },
              ),
              _ServiceCard(
                title: 'Reports',
                icon: Icons.bar_chart,
                onTap: () {
                  _openScreen(
                    context,
                    const ReportsScreen(),
                  );
                },
              ),
              _ServiceCard(
                title: 'Settings',
                icon: Icons.settings,
                onTap: () {
                  _openScreen(
                    context,
                    const SettingsScreen(),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ======================================================
          // TODAY'S OVERVIEW
          // ======================================================

          const Text(
            "Today's Overview",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _FirestoreCountCard(
                  title: 'Patients',
                  icon: Icons.people,
                  collection: 'patients',
                  onTap: () {
                    _openScreen(
                      context,
                      const PatientsScreen(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FirestoreCountCard(
                  title: 'Doctors',
                  icon: Icons.medical_services,
                  collection: 'doctors',
                  onTap: () {
                    _openScreen(
                      context,
                      const DoctorsScreen(),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _FirestoreCountCard(
                  title: 'Appointments',
                  icon: Icons.calendar_today,
                  collection: 'appointments',
                  onTap: () {
                    _openScreen(
                      context,
                      const AppointmentsScreen(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PendingBillsCard(
                  onTap: () {
                    _openScreen(
                      context,
                      const BillingScreen(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SERVICE CARD
// ============================================================

class _ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.icon,
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
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: const Color(0xFF0969D8),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FIRESTORE COUNT CARD
// ============================================================

class _FirestoreCountCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String collection;
  final VoidCallback onTap;

  const _FirestoreCountCard({
    required this.title,
    required this.icon,
    required this.collection,
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
          child: StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(collection)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error');
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const SizedBox(
                  height: 45,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              final count =
                  snapshot.data?.docs.length ?? 0;

              return Row(
                children: [
                  Icon(
                    icon,
                    size: 30,
                    color: const Color(0xFF0969D8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          count.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          title,
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
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PENDING BILLS
// ============================================================

class _PendingBillsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PendingBillsCard({
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
          child: StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('bills')
                .where(
              'status',
              isEqualTo: 'Pending',
            )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error');
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const SizedBox(
                  height: 45,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              final count =
                  snapshot.data?.docs.length ?? 0;

              return Row(
                children: [
                  const Icon(
                    Icons.receipt,
                    size: 30,
                    color: Color(0xFF0969D8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          count.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Pending Bills',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GLOBAL SEARCH
// ============================================================

class _GlobalSearchScreen extends StatefulWidget {
  const _GlobalSearchScreen();

  @override
  State<_GlobalSearchScreen> createState() =>
      _GlobalSearchScreenState();
}

class _GlobalSearchScreenState
    extends State<_GlobalSearchScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  bool _searching = false;

  List<_SearchResult> _results = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SEARCH ALL FIRESTORE COLLECTIONS
  // ==========================================================

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
      // ======================================================
      // PATIENTS
      // ======================================================

      final patients = await FirebaseFirestore.instance
          .collection('patients')
          .get();

      for (final doc in patients.docs) {
        final data = doc.data();

        final name =
            data['name']?.toString() ?? '';
        final phone =
            data['phone']?.toString() ?? '';
        final disease =
            data['disease']?.toString() ?? '';
        final bloodGroup =
            data['bloodGroup']?.toString() ?? '';

        if (_contains(
          query,
          [
            name,
            phone,
            disease,
            bloodGroup,
          ],
        )) {
          results.add(
            _SearchResult(
              title:
              name.isEmpty ? 'Patient' : name,
              subtitle:
              'Patient • ${disease.isEmpty ? 'No disease' : disease}',
              icon: Icons.person,
              type: 'Patient',
              data: data,
            ),
          );
        }
      }

      // ======================================================
      // DOCTORS
      // ======================================================

      final doctors = await FirebaseFirestore.instance
          .collection('doctors')
          .get();

      for (final doc in doctors.docs) {
        final data = doc.data();

        final name =
            data['name']?.toString() ?? '';
        final specialization =
            data['specialization']?.toString() ?? '';
        final department =
            data['department']?.toString() ?? '';
        final phone =
            data['phone']?.toString() ?? '';

        if (_contains(
          query,
          [
            name,
            specialization,
            department,
            phone,
          ],
        )) {
          results.add(
            _SearchResult(
              title:
              name.isEmpty ? 'Doctor' : name,
              subtitle:
              'Doctor • ${specialization.isEmpty ? department : specialization}',
              icon: Icons.medical_services,
              type: 'Doctor',
              data: data,
            ),
          );
        }
      }

      // ======================================================
      // APPOINTMENTS
      // ======================================================

      final appointments =
      await FirebaseFirestore.instance
          .collection('appointments')
          .get();

      for (final doc in appointments.docs) {
        final data = doc.data();

        final patientName =
            data['patientName']?.toString() ?? '';
        final doctorName =
            data['doctorName']?.toString() ?? '';
        final date =
            data['date']?.toString() ?? '';
        final time =
            data['time']?.toString() ?? '';
        final reason =
            data['reason']?.toString() ?? '';
        final status =
            data['status']?.toString() ?? '';

        if (_contains(
          query,
          [
            patientName,
            doctorName,
            date,
            time,
            reason,
            status,
          ],
        )) {
          results.add(
            _SearchResult(
              title: patientName.isEmpty
                  ? 'Appointment'
                  : patientName,
              subtitle:
              'Appointment • Dr. $doctorName • $date $time',
              icon: Icons.calendar_month,
              type: 'Appointment',
              data: data,
            ),
          );
        }
      }

      // ======================================================
      // MEDICAL RECORDS
      // ======================================================

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
        final treatment =
            data['treatment']?.toString() ?? '';
        final prescription =
            data['prescription']?.toString() ?? '';

        if (_contains(
          query,
          [
            patientName,
            doctorName,
            diagnosis,
            treatment,
            prescription,
          ],
        )) {
          results.add(
            _SearchResult(
              title: patientName.isEmpty
                  ? 'Medical Record'
                  : patientName,
              subtitle:
              'Medical Record • $diagnosis',
              icon: Icons.folder_shared,
              type: 'Medical Record',
              data: data,
            ),
          );
        }
      }

      // ======================================================
      // PHARMACY
      // ======================================================

      final medicines =
      await FirebaseFirestore.instance
          .collection('medicines')
          .get();

      for (final doc in medicines.docs) {
        final data = doc.data();

        final name =
            data['name']?.toString() ?? '';
        final medicineName =
            data['medicineName']?.toString() ?? '';
        final expiry =
            data['expiry']?.toString() ?? '';

        final actualName =
        name.isNotEmpty ? name : medicineName;

        if (_contains(
          query,
          [
            actualName,
            expiry,
          ],
        )) {
          results.add(
            _SearchResult(
              title: actualName.isEmpty
                  ? 'Medicine'
                  : actualName,
              subtitle:
              'Pharmacy • Medicine',
              icon: Icons.local_pharmacy,
              type: 'Medicine',
              data: data,
            ),
          );
        }
      }

      // ======================================================
      // BILLING
      // ======================================================

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

        if (_contains(
          query,
          [
            patientName,
            description,
            status,
            date,
          ],
        )) {
          results.add(
            _SearchResult(
              title: patientName.isEmpty
                  ? 'Bill'
                  : patientName,
              subtitle:
              'Billing • $description • $status',
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
          content: Text(
            'Search error: $e',
          ),
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
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon: IconButton(
                  onPressed: _searchAll,
                  icon: const Icon(
                    Icons.arrow_forward,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
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
                        'Search the entire hospital system',
                        textAlign:
                        TextAlign.center,
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
                  itemBuilder:
                      (context, index) {
                    final result =
                    _results[index];

                    return Card(
                      margin:
                      const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          const Color(
                            0xFFE8F2FF,
                          ),
                          child: Icon(
                            result.icon,
                            color:
                            const Color(
                              0xFF0969D8,
                            ),
                          ),
                        ),
                        title: Text(
                          result.title,
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          result.subtitle,
                        ),
                        trailing:
                        const Icon(
                          Icons
                              .arrow_forward_ios,
                          size: 15,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                  _SearchDetailScreen(
                                    result: result,
                                  ),
                            ),
                          );
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
// SEARCH RESULT MODEL
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

  String _value(String key) {
    final value = result.data[key];

    if (value == null) {
      return '';
    }

    if (value is Timestamp) {
      final date = value.toDate();

      return '${date.day}/${date.month}/${date.year}';
    }

    return value.toString();
  }

  Widget _detailRow(
      String label,
      String value,
      ) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _patientDetails() {
    return [
      _detailRow('Name', _value('name')),
      _detailRow('Age', _value('age')),
      _detailRow('Gender', _value('gender')),
      _detailRow('Disease', _value('disease')),
      _detailRow('Phone', _value('phone')),
      _detailRow('Address', _value('address')),
      _detailRow(
        'Blood Group',
        _value('bloodGroup'),
      ),
    ];
  }

  List<Widget> _doctorDetails() {
    return [
      _detailRow('Name', _value('name')),
      _detailRow(
        'Specialization',
        _value('specialization'),
      ),
      _detailRow(
        'Experience',
        _value('experience'),
      ),
      _detailRow('Phone', _value('phone')),
      _detailRow('Email', _value('email')),
      _detailRow(
        'Department',
        _value('department'),
      ),
      _detailRow(
        'Availability',
        _value('availability'),
      ),
    ];
  }

  List<Widget> _appointmentDetails() {
    return [
      _detailRow(
        'Patient',
        _value('patientName'),
      ),
      _detailRow(
        'Doctor',
        _value('doctorName'),
      ),
      _detailRow('Date', _value('date')),
      _detailRow('Time', _value('time')),
      _detailRow('Reason', _value('reason')),
      _detailRow('Status', _value('status')),
      _detailRow('Notes', _value('notes')),
    ];
  }

  List<Widget> _medicalRecordDetails() {
    return [
      _detailRow(
        'Patient',
        _value('patientName'),
      ),
      _detailRow(
        'Doctor',
        _value('doctorName'),
      ),
      _detailRow(
        'Diagnosis',
        _value('diagnosis'),
      ),
      _detailRow(
        'Date',
        _value('date'),
      ),
      _detailRow(
        'Treatment',
        _value('treatment'),
      ),
      _detailRow(
        'Prescription',
        _value('prescription'),
      ),
      _detailRow(
        'Blood Pressure',
        _value('bloodPressure'),
      ),
      _detailRow(
        'Temperature',
        _value('temperature'),
      ),
      _detailRow(
        'Status',
        _value('status'),
      ),
      _detailRow(
        'Notes',
        _value('notes'),
      ),
    ];
  }

  List<Widget> _medicineDetails() {
    return [
      _detailRow(
        'Medicine',
        _value('name').isNotEmpty
            ? _value('name')
            : _value('medicineName'),
      ),
      _detailRow(
        'Medicine ID',
        _value('id'),
      ),
      _detailRow(
        'Price',
        _value('price'),
      ),
      _detailRow(
        'Stock',
        _value('stock'),
      ),
      _detailRow(
        'Expiry',
        _value('expiry'),
      ),
    ];
  }

  List<Widget> _billingDetails() {
    return [
      _detailRow(
        'Patient',
        _value('patientName'),
      ),
      _detailRow(
        'Description',
        _value('description'),
      ),
      _detailRow(
        'Amount',
        _value('amount'),
      ),
      _detailRow(
        'Status',
        _value('status'),
      ),
      _detailRow(
        'Date',
        _value('date'),
      ),
    ];
  }

  List<Widget> _getDetails() {
    switch (result.type) {
      case 'Patient':
        return _patientDetails();

      case 'Doctor':
        return _doctorDetails();

      case 'Appointment':
        return _appointmentDetails();

      case 'Medical Record':
        return _medicalRecordDetails();

      case 'Medicine':
        return _medicineDetails();

      case 'Bill':
        return _billingDetails();

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _getDetails();

    return Scaffold(
      appBar: AppBar(
        title: Text(result.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor:
                const Color(0xFFE8F2FF),
                child: Icon(
                  result.icon,
                  size: 45,
                  color:
                  const Color(0xFF0969D8),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Center(
              child: Text(
                result.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

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

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: details,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// NOTIFICATIONS
// ============================================================

class _NotificationsScreen extends StatelessWidget {
  const _NotificationsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .orderBy(
              'createdAt',
              descending: true,
            )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Unable to load notifications.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }

              final documents =
                  snapshot.data?.docs ?? [];

              if (documents.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'No notifications',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding:
                const EdgeInsets.all(16),
                itemCount: documents.length,
                itemBuilder:
                    (context, index) {
                  final data =
                  documents[index].data();

                  final String title =
                      data['title']?.toString() ??
                          'Notification';

                  final String message =
                      data['message']?.toString() ??
                          '';

                  final String type =
                      data['type']?.toString() ??
                          '';

                  IconData icon =
                      Icons.notifications;

                  if (type == 'patient') {
                    icon = Icons.person_add;
                  } else if (type == 'doctor') {
                    icon =
                        Icons.medical_services;
                  } else if (type ==
                      'appointment') {
                    icon =
                        Icons.calendar_month;
                  } else if (type ==
                      'medical_record') {
                    icon =
                        Icons.description;
                  } else if (type == 'medicine') {
                    icon = Icons.medication;
                  } else if (type == 'bill') {
                    icon =
                        Icons.receipt_long;
                  }

                  String time = '';

                  final createdAt =
                  data['createdAt'];

                  if (createdAt is Timestamp) {
                    final dateTime =
                    createdAt.toDate();

                    time =
                    '${dateTime.day.toString().padLeft(2, '0')}/'
                        '${dateTime.month.toString().padLeft(2, '0')}/'
                        '${dateTime.year} '
                        '${dateTime.hour.toString().padLeft(2, '0')}:'
                        '${dateTime.minute.toString().padLeft(2, '0')}';
                  }

                  return _NotificationCard(
                    documentId:
                    documents[index].id,
                    icon: icon,
                    title: title,
                    message: message,
                    time: time,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NOTIFICATION CARD
// ============================================================

class _NotificationCard extends StatelessWidget {
  final String documentId;
  final IconData icon;
  final String title;
  final String message;
  final String time;

  const _NotificationCard({
    required this.documentId,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
  });

  Future<void> _openNotification(
      BuildContext context,
      ) async {
    try {
      // Mark notification as read.
      // The notification is NOT deleted.
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(documentId)
          .update({
        'read': true,
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Unable to mark notification as read: $e',
            ),
          ),
        );
      }
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                const Color(0xFFE8F2FF),
                child: Icon(
                  icon,
                  color:
                  const Color(0xFF0969D8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0969D8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF0969D8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
      const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: InkWell(
        borderRadius:
        BorderRadius.circular(12),
        onTap: () =>
            _openNotification(context),
        child: ListTile(
          contentPadding:
          const EdgeInsets.all(14),
          leading: CircleAvatar(
            backgroundColor:
            const Color(0xFFE8F2FF),
            child: Icon(
              icon,
              color:
              const Color(0xFF0969D8),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0969D8),
            ),
          ),
          subtitle: Padding(
            padding:
            const EdgeInsets.only(top: 5),
            child: Text(message),
          ),
          trailing: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              const Icon(
                Icons.arrow_forward_ios,
                size: 13,
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
// REPORTS
// ============================================================

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() =>
      _ReportsScreenState();
}

class _ReportsScreenState
    extends State<ReportsScreen> {
  bool _generating = false;
  bool _reportGenerated = false;

  int _patients = 0;
  int _doctors = 0;
  int _appointments = 0;
  int _medicalRecords = 0;
  int _medicines = 0;
  int _pendingBills = 0;

  // ==========================================================
  // GENERATE PDF REPORT
  // ==========================================================

  Future<void> _generateReport() async {
    setState(() {
      _generating = true;
    });

    try {
      final firestore =
          FirebaseFirestore.instance;

      // ======================================================
      // GET PATIENTS
      // ======================================================

      final patientsSnapshot =
      await firestore
          .collection('patients')
          .get();

      // ======================================================
      // GET DOCTORS
      // ======================================================

      final doctorsSnapshot =
      await firestore
          .collection('doctors')
          .get();

      // ======================================================
      // GET APPOINTMENTS
      // ======================================================

      final appointmentsSnapshot =
      await firestore
          .collection('appointments')
          .get();

      // ======================================================
      // GET MEDICAL RECORDS
      // ======================================================

      final medicalRecordsSnapshot =
      await firestore
          .collection('medical_records')
          .get();

      // ======================================================
      // GET MEDICINES
      // ======================================================

      final medicinesSnapshot =
      await firestore
          .collection('medicines')
          .get();

      // ======================================================
      // GET PENDING BILLS
      // ======================================================

      final pendingBillsSnapshot =
      await firestore
          .collection('bills')
          .where(
        'status',
        isEqualTo: 'Pending',
      )
          .get();

      if (!mounted) return;

      setState(() {
        _patients =
            patientsSnapshot.docs.length;
        _doctors =
            doctorsSnapshot.docs.length;
        _appointments =
            appointmentsSnapshot.docs.length;
        _medicalRecords =
            medicalRecordsSnapshot.docs.length;
        _medicines =
            medicinesSnapshot.docs.length;
        _pendingBills =
            pendingBillsSnapshot.docs.length;

        _reportGenerated = true;
        _generating = false;
      });

      // ======================================================
      // CREATE PDF
      // ======================================================

      final pdf = pw.Document();

      final now = DateTime.now();

      final date =
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/'
          '${now.year}';

      final time =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';

      // ======================================================
      // PDF PAGE
      // ======================================================

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin:
          const pw.EdgeInsets.all(32),
          build: (pw.Context pdfContext) {
            return [
              // ==================================================
              // HEADER
              // ==================================================

              pw.Center(
                child: pw.Text(
                  'HOSPITAL MANAGEMENT SYSTEM',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight:
                    pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 8),

              pw.Center(
                child: pw.Text(
                  'Hospital Report',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight:
                    pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Center(
                child: pw.Text(
                  'Generated on $date at $time',
                  style:
                  const pw.TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),

              pw.SizedBox(height: 25),

              // ==================================================
              // SUMMARY
              // ==================================================

              pw.Text(
                'SUMMARY',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Table(
                border:
                pw.TableBorder.all(
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(
                    3,
                  ),
                  1: const pw.FlexColumnWidth(
                    1,
                  ),
                },
                children: [
                  _pdfSummaryRow(
                    'Total Patients',
                    _patients.toString(),
                  ),
                  _pdfSummaryRow(
                    'Total Doctors',
                    _doctors.toString(),
                  ),
                  _pdfSummaryRow(
                    'Total Appointments',
                    _appointments.toString(),
                  ),
                  _pdfSummaryRow(
                    'Medical Records',
                    _medicalRecords.toString(),
                  ),
                  _pdfSummaryRow(
                    'Medicines',
                    _medicines.toString(),
                  ),
                  _pdfSummaryRow(
                    'Pending Bills',
                    _pendingBills.toString(),
                  ),
                ],
              ),

              pw.SizedBox(height: 25),

              // ==================================================
              // PATIENT DETAILS
              // ==================================================

              pw.Text(
                'PATIENT DETAILS',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              if (patientsSnapshot.docs.isEmpty)
                pw.Text(
                  'No patient records found.',
                )
              else
                pw.Table(
                  border:
                  pw.TableBorder.all(
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(
                      1.2,
                    ),
                    1: const pw.FlexColumnWidth(
                      2,
                    ),
                    2: const pw.FlexColumnWidth(
                      1,
                    ),
                    3: const pw.FlexColumnWidth(
                      1.5,
                    ),
                    4: const pw.FlexColumnWidth(
                      1.5,
                    ),
                  },
                  children: [
                    _pdfHeaderRow([
                      'ID',
                      'Name',
                      'Age',
                      'Gender',
                      'Disease',
                    ]),
                    ...patientsSnapshot.docs.map(
                          (doc) {
                        final data =
                        doc.data();

                        return _pdfDataRow([
                          _pdfValue(
                            data['id'],
                          ),
                          _pdfValue(
                            data['name'],
                          ),
                          _pdfValue(
                            data['age'],
                          ),
                          _pdfValue(
                            data['gender'],
                          ),
                          _pdfValue(
                            data['disease'],
                          ),
                        ]);
                      },
                    ),
                  ],
                ),

              pw.SizedBox(height: 25),

              // ==================================================
              // DOCTOR DETAILS
              // ==================================================

              pw.Text(
                'DOCTOR DETAILS',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              if (doctorsSnapshot.docs.isEmpty)
                pw.Text(
                  'No doctor records found.',
                )
              else
                pw.Table(
                  border:
                  pw.TableBorder.all(
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(
                      1.2,
                    ),
                    1: const pw.FlexColumnWidth(
                      2,
                    ),
                    2: const pw.FlexColumnWidth(
                      2,
                    ),
                    3: const pw.FlexColumnWidth(
                      1.5,
                    ),
                    4: const pw.FlexColumnWidth(
                      1.5,
                    ),
                  },
                  children: [
                    _pdfHeaderRow([
                      'ID',
                      'Name',
                      'Specialization',
                      'Phone',
                      'Department',
                    ]),
                    ...doctorsSnapshot.docs.map(
                          (doc) {
                        final data =
                        doc.data();

                        return _pdfDataRow([
                          _pdfValue(
                            data['id'],
                          ),
                          _pdfValue(
                            data['name'],
                          ),
                          _pdfValue(
                            data['specialization'],
                          ),
                          _pdfValue(
                            data['phone'],
                          ),
                          _pdfValue(
                            data['department'],
                          ),
                        ]);
                      },
                    ),
                  ],
                ),

              pw.SizedBox(height: 25),

              // ==================================================
              // APPOINTMENT DETAILS
              // ==================================================

              pw.Text(
                'APPOINTMENT DETAILS',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              if (appointmentsSnapshot.docs.isEmpty)
                pw.Text(
                  'No appointment records found.',
                )
              else
                pw.Table(
                  border:
                  pw.TableBorder.all(
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(
                      1.2,
                    ),
                    1: const pw.FlexColumnWidth(
                      2,
                    ),
                    2: const pw.FlexColumnWidth(
                      2,
                    ),
                    3: const pw.FlexColumnWidth(
                      1.5,
                    ),
                    4: const pw.FlexColumnWidth(
                      1.5,
                    ),
                  },
                  children: [
                    _pdfHeaderRow([
                      'ID',
                      'Patient',
                      'Doctor',
                      'Date',
                      'Status',
                    ]),
                    ...appointmentsSnapshot.docs.map(
                          (doc) {
                        final data =
                        doc.data();

                        return _pdfDataRow([
                          _pdfValue(
                            data['id'],
                          ),
                          _pdfValue(
                            data['patientName'],
                          ),
                          _pdfValue(
                            data['doctorName'],
                          ),
                          _pdfValue(
                            data['date'],
                          ),
                          _pdfValue(
                            data['status'],
                          ),
                        ]);
                      },
                    ),
                  ],
                ),

              pw.SizedBox(height: 30),

              // ==================================================
              // FOOTER
              // ==================================================

              pw.Divider(),

              pw.SizedBox(height: 8),

              pw.Center(
                child: pw.Text(
                  'Generated by Hospital Management System',
                  style:
                  const pw.TextStyle(
                    fontSize: 9,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // ========================================================
      // OPEN PDF PREVIEW / SAVE / SHARE
      // ========================================================

      await Printing.layoutPdf(
        onLayout:
            (PdfPageFormat format) async {
          return pdf.save();
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'PDF report generated successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _generating = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to generate PDF: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // PDF SUMMARY ROW
  // ============================================================

  pw.TableRow _pdfSummaryRow(
      String title,
      String value,
      ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding:
          const pw.EdgeInsets.all(7),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight:
              pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Padding(
          padding:
          const pw.EdgeInsets.all(7),
          child: pw.Text(value),
        ),
      ],
    );
  }

  // ============================================================
  // PDF HEADER ROW
  // ============================================================

  pw.TableRow _pdfHeaderRow(
      List<String> values,
      ) {
    return pw.TableRow(
      children: values.map(
            (value) {
          return pw.Container(
            padding:
            const pw.EdgeInsets.all(6),
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight:
                pw.FontWeight.bold,
                fontSize: 9,
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // PDF DATA ROW
  // ============================================================

  pw.TableRow _pdfDataRow(
      List<String> values,
      ) {
    return pw.TableRow(
      children: values.map(
            (value) {
          return pw.Container(
            padding:
            const pw.EdgeInsets.all(6),
            child: pw.Text(
              value,
              style:
              const pw.TextStyle(
                fontSize: 8,
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // FIRESTORE VALUE
  // ============================================================

  String _pdfValue(dynamic value) {
    if (value == null) {
      return '-';
    }

    if (value is Timestamp) {
      final date = value.toDate();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return value.toString();
  }

  // ============================================================
  // REPORT CARD
  // ============================================================

  Widget _reportCard(
      String title,
      int value,
      IconData icon,
      ) {
    return Card(
      elevation: 2,
      margin:
      const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                const Color(0xFFE8F2FF),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color:
                const Color(0xFF0969D8),
                size: 26,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
                color:
                Color(0xFF0969D8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Reports'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints:
          const BoxConstraints(
            maxWidth: 500,
          ),
          padding:
          const EdgeInsets.all(20),
          child: _reportGenerated
              ? _buildGeneratedReport()
              : _buildReportHome(),
        ),
      ),
    );
  }

  // ============================================================
  // REPORT HOME
  // ============================================================

  Widget _buildReportHome() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          const Icon(
            Icons.picture_as_pdf,
            size: 80,
            color: Color(0xFF0969D8),
          ),

          const SizedBox(height: 20),

          const Text(
            'Hospital Reports',
            style: TextStyle(
              fontSize: 24,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Generate a PDF report containing the latest hospital data.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _generating
                  ? null
                  : _generateReport,
              icon: _generating
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.picture_as_pdf,
              ),
              label: Text(
                _generating
                    ? 'Generating PDF...'
                    : 'Generate Report',
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF0969D8),
                foregroundColor:
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GENERATED REPORT SCREEN
  // ============================================================

  Widget _buildGeneratedReport() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Hospital Report',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                onPressed: _generating
                    ? null
                    : _generateReport,
                tooltip:
                'Generate PDF again',
                icon: const Icon(
                  Icons.picture_as_pdf,
                  color:
                  Color(0xFF0969D8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Current Firestore data',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          _reportCard(
            'Total Patients',
            _patients,
            Icons.people,
          ),

          _reportCard(
            'Total Doctors',
            _doctors,
            Icons.medical_services,
          ),

          _reportCard(
            'Total Appointments',
            _appointments,
            Icons.calendar_month,
          ),

          _reportCard(
            'Medical Records',
            _medicalRecords,
            Icons.folder_shared,
          ),

          _reportCard(
            'Medicines',
            _medicines,
            Icons.local_pharmacy,
          ),

          _reportCard(
            'Pending Bills',
            _pendingBills,
            Icons.receipt_long,
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _generating
                  ? null
                  : _generateReport,
              icon: const Icon(
                Icons.picture_as_pdf,
              ),
              label: const Text(
                'Download PDF Report',
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF0969D8),
                foregroundColor:
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}