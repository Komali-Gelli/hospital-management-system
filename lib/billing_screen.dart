import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> _addBill() async {
    final formKey = GlobalKey<FormState>();

    final patientController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController();

    String status = 'Pending';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Bill'),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: patientController,
                          decoration: const InputDecoration(
                            labelText: 'Patient Name',
                            prefixIcon:
                            Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
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

                        TextFormField(
                          controller:
                          descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            prefixIcon:
                            Icon(Icons.description_outlined),
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter description';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: amountController,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Amount (₹)',
                            prefixIcon:
                            Icon(Icons.currency_rupee),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter amount';
                            }

                            if (double.tryParse(
                              value.trim(),
                            ) ==
                                null) {
                              return 'Enter a valid amount';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: dateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            prefixIcon:
                            Icon(Icons.calendar_today_outlined),
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            final selectedDate =
                            await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
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
                              return 'Select date';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            prefixIcon:
                            Icon(Icons.info_outline),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'Paid',
                              child: Text('Paid'),
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
                          'B${DateTime.now().millisecondsSinceEpoch}';

                      final patientName =
                      patientController.text.trim();

                      await _firestore
                          .collection('bills')
                          .doc(id)
                          .set({
                        'id': id,
                        'patientName': patientName,
                        'description':
                        descriptionController.text.trim(),
                        'amount': double.parse(
                          amountController.text.trim(),
                        ),
                        'date': dateController.text.trim(),
                        'status': status,
                        'createdAt':
                        FieldValue.serverTimestamp(),
                      });

                      // Create notification only after the bill
                      // has been successfully saved.
                      await NotificationService.billAdded(
                        patientName,
                      );

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Bill added successfully',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error adding bill: $e',
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
      },
    );

    patientController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    dateController.dispose();
  }

  Future<void> _deleteBill(String id) async {
    try {
      await _firestore
          .collection('bills')
          .doc(id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting bill: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Bill'),
          content: const Text(
            'Are you sure you want to delete this bill?',
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
                _deleteBill(id);
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        title: const Text(
          'Billing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addBill,
        backgroundColor: const Color(0xFF0969D8),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            padding: const EdgeInsets.all(16),

            // NO INTERNAL SEARCH BAR
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('bills')
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading bills:\n'
                          '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final documents =
                    snapshot.data?.docs ?? [];

                // No search/filtering.
                final bills = documents
                    .map((document) {
                  final data =
                  document.data()
                  as Map<String, dynamic>;

                  return data;
                }).toList();

                if (bills.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No bills found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'Tap + to add a bill',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: bills.length,

                  itemBuilder: (context, index) {
                    final bill = bills[index];

                    final amount =
                        bill['amount'] ?? 0;

                    final status =
                        bill['status']
                            ?.toString() ??
                            'Pending';

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      color: Colors.white,
                      elevation: 1,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      child: Padding(
                        padding:
                        const EdgeInsets.all(14),

                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            CircleAvatar(
                              radius: 27,
                              backgroundColor:
                              const Color(0xFFE8F2FF),

                              child: const Icon(
                                Icons.receipt_long_outlined,
                                color:
                                Color(0xFF0969D8),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    bill['patientName']
                                        ?.toString() ??
                                        '',
                                    style:
                                    const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 5),

                                  Text(
                                    bill['description']
                                        ?.toString() ??
                                        '',
                                  ),

                                  const SizedBox(
                                      height: 6),

                                  Text(
                                    'Amount: ₹${amount.toString()}',
                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 4),

                                  Text(
                                    'Date: ${bill['date']?.toString() ?? ''}',
                                  ),

                                  const SizedBox(
                                      height: 8),

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
                                        status,
                                      ).withOpacity(0.12),
                                      borderRadius:
                                      BorderRadius
                                          .circular(20),
                                    ),

                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color:
                                        _statusColor(
                                          status,
                                        ),
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                _showDeleteDialog(
                                  bill['id']
                                      ?.toString() ??
                                      '',
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