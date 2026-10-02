import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Unable to load notifications.\n\n'
                          '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Get notifications from Firestore only
              final documents = snapshot.data?.docs ?? [];

              // No notifications
              if (documents.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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

              // Convert Firestore documents to a list
              final notifications =
              documents.map((document) {
                final data = document.data();

                return {
                  'title':
                  data['title']?.toString() ??
                      'Notification',
                  'message':
                  data['message']?.toString() ??
                      '',
                  'type':
                  data['type']?.toString() ??
                      'general',
                  'createdAt':
                  data['createdAt'],
                };
              }).toList();

              // Sort newest notification first
              notifications.sort((a, b) {
                final timestampA = a['createdAt'];
                final timestampB = b['createdAt'];

                if (timestampA is Timestamp &&
                    timestampB is Timestamp) {
                  return timestampB
                      .compareTo(timestampA);
                }

                if (timestampA is Timestamp) {
                  return -1;
                }

                if (timestampB is Timestamp) {
                  return 1;
                }

                return 0;
              });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification =
                  notifications[index];

                  return _buildNotificationCard(
                    context: context,
                    title:
                    notification['title']
                        ?.toString() ??
                        'Notification',
                    message:
                    notification['message']
                        ?.toString() ??
                        '',
                    type:
                    notification['type']
                        ?.toString() ??
                        'general',
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required String title,
    required String message,
    required String type,
  }) {
    IconData icon;

    switch (type) {
      case 'patient':
        icon = Icons.person_add;

        break;

      case 'doctor':
        icon = Icons.medical_services;

        break;

      case 'appointment':
        icon = Icons.calendar_month;

        break;

      case 'medical_record':
        icon = Icons.folder_shared;

        break;

      case 'medicine':
        icon = Icons.medication;

        break;

      case 'bill':
        icon = Icons.receipt_long;

        break;

      default:
        icon = Icons.notifications;

        break;
    }

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(12),
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.10),
              ),
              child: Icon(
                icon,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),

            const SizedBox(width: 12),

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

                  const SizedBox(height: 5),

                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}