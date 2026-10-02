import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> _addMedicine() async {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final expiryController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Medicine'),
          content: SizedBox(
            width: 450,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medicine Name',
                        prefixIcon:
                        Icon(Icons.medication_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter medicine name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: priceController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        prefixIcon:
                        Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter price';
                        }

                        if (double.tryParse(value.trim()) ==
                            null) {
                          return 'Enter a valid price';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity',
                        prefixIcon:
                        Icon(Icons.inventory_2_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter stock quantity';
                        }

                        if (int.tryParse(value.trim()) ==
                            null) {
                          return 'Enter a valid quantity';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry',
                        hintText: 'Example: Dec 2027',
                        prefixIcon:
                        Icon(Icons.event_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter expiry';
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
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),

            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                try {
                  final id =
                      'M${DateTime.now().millisecondsSinceEpoch}';

                  final medicineName =
                  nameController.text.trim();

                  await _firestore
                      .collection('medicines')
                      .doc(id)
                      .set({
                    'id': id,
                    'name': medicineName,
                    'price': double.parse(
                      priceController.text.trim(),
                    ),
                    'stock': int.parse(
                      stockController.text.trim(),
                    ),
                    'expiry':
                    expiryController.text.trim(),
                    'createdAt':
                    FieldValue.serverTimestamp(),
                  });

                  // Notification is created only after
                  // the medicine is successfully added.
                  await NotificationService.medicineAdded(
                    medicineName,
                  );

                  if (!mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Medicine added successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error adding medicine: $e',
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

    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    expiryController.dispose();
  }

  Future<void> _deleteMedicine(String id) async {
    try {
      await _firestore
          .collection('medicines')
          .doc(id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Medicine deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text('Error deleting medicine: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Medicine'),
          content: Text(
            'Are you sure you want to delete $name?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteMedicine(id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F9FC),

      appBar: AppBar(
        title: const Text(
          'Pharmacy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),

      floatingActionButton:
      FloatingActionButton(
        onPressed: _addMedicine,
        backgroundColor:
        const Color(0xFF0969D8),
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

            // =================================================
            // NO INTERNAL SEARCH BAR
            // =================================================

            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('medicines')
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading medicines:\n'
                          '${snapshot.error}',
                      textAlign:
                      TextAlign.center,
                    ),
                  );
                }

                final documents =
                    snapshot.data?.docs ?? [];

                // =================================================
                // NO SEARCH FILTERING
                // =================================================

                final medicines =
                documents.toList();

                if (medicines.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons
                              .medication_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No medicines found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'Tap + to add a medicine',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: medicines.length,

                  itemBuilder:
                      (context, index) {
                    final document =
                    medicines[index];

                    final data =
                    document.data()
                    as Map<String, dynamic>;

                    final id =
                        data['id']?.toString() ??
                            document.id;

                    final name =
                        data['name']?.toString() ??
                            '';

                    final price =
                        data['price']
                            ?.toString() ??
                            '0';

                    final stock =
                        int.tryParse(
                          data['stock']
                              ?.toString() ??
                              '0',
                        ) ??
                            0;

                    final expiry =
                        data['expiry']
                            ?.toString() ??
                            '';

                    final bool lowStock =
                        stock <= 10;

                    return Card(
                      margin:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                      color: Colors.white,
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
                          14,
                        ),

                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [
                            CircleAvatar(
                              radius: 27,
                              backgroundColor:
                              const Color(
                                0xFFE8F2FF,
                              ),

                              child: const Icon(
                                Icons
                                    .medication_outlined,
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
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [
                                  Text(
                                    name,
                                    style:
                                    const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Text(
                                    'Price: ₹$price',
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    'Stock: $stock',
                                    style: TextStyle(
                                      color: lowStock
                                          ? Colors.red
                                          : Colors
                                          .black87,
                                      fontWeight:
                                      lowStock
                                          ? FontWeight
                                          .bold
                                          : FontWeight
                                          .normal,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    'Expiry: $expiry',
                                  ),

                                  if (lowStock) ...[
                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Container(
                                      padding:
                                      const EdgeInsets
                                          .symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),

                                      decoration:
                                      BoxDecoration(
                                        color: Colors
                                            .red
                                            .withOpacity(
                                          0.1,
                                        ),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          20,
                                        ),
                                      ),

                                      child:
                                      const Text(
                                        'LOW STOCK',
                                        style:
                                        TextStyle(
                                          color:
                                          Colors.red,
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                _confirmDelete(
                                  id,
                                  name,
                                );
                              },

                              icon: const Icon(
                                Icons
                                    .delete_outline,
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