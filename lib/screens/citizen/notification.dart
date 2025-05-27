import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Our parking\'s up in 5 minutes.',
      'subtitle': 'parking for CEM1233 will over in 5 minutes.',
      'date': 'Today',
      'time': '9:40 AM',
      'type': 'parking_expiry',
      'isRead': false,
    },
    {
      'title': 'Our parking\'s up in 20 minutes.',
      'subtitle': 'parking for CEM1233 will over in 10 minutes.',
      'date': 'Today',
      'time': '9:21 AM',
      'type': 'parking_expiry',
      'isRead': false,
    },
    {
      'title': 'Uh-oh, we have be fined',
      'subtitle': 'VFK4567 have been fined for parking.',
      'date': 'Yesterday',
      'time': '2:00 PM',
      'type': 'fine',
      'isRead': true,
    },
    {
      'title': 'Our parking is up!',
      'subtitle': 'parking for VFK4567 is expired.',
      'date': '21 April 2025',
      'time': '4:00 PM',
      'type': 'parking_expired',
      'isRead': true,
    },
    {
      'title': 'Our parking\'s up in 5 minutes.',
      'subtitle': 'parking for VFK4567 will over in 5 minutes.',
      'date': '21 April 2025',
      'time': '3:55 PM',
      'type': 'parking_expiry',
      'isRead': true,
    },
    {
      'title': 'Our parking\'s up in 20 minutes.',
      'subtitle': 'parking for VFK4567 will over in 20 minutes.',
      'date': '21 April 2025',
      'time': '3:40 PM',
      'type': 'parking_expiry',
      'isRead': true,
    },
  ];

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'fine':
        return Icons.warning_rounded;
      case 'parking_expired':
        return Icons.timer_off_rounded;
      case 'parking_expiry':
      default:
        return Icons.timer_rounded;
    }
  }

  Color _getNotificationIconColor(String type) {
    switch (type) {
      case 'fine':
        return Colors.red;
      case 'parking_expired':
        return Colors.orange;
      case 'parking_expiry':
      default:
        return const Color(0xFF4A90E2);
    }
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['isRead'] = true;
    });
  }

  void _showNotificationDetails(Map<String, dynamic> notification, int index) {
    if (!notification['isRead']) {
      _markAsRead(index);
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  _getNotificationIcon(notification['type']),
                  color: _getNotificationIconColor(notification['type']),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Notification Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification['subtitle'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${notification['date']} at ${notification['time']}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w600,
            fontFamily:
                'San Francisco', // iOS-like font to match history screen
          ),
        ),
        centerTitle: true,
        leading: Container(), // Remove back button
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read, color: Colors.black54),
            onPressed: () {
              setState(() {
                for (var notification in notifications) {
                  notification['isRead'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Colors.white,
            ],
            stops: [0.0, 0.1], // Match history screen gradient stops
          ),
        ),
        child:
            notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationItem(notification, index);
                  },
                ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    bool isUnread = !notification['isRead'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
            ), // Match history screen shadow opacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border:
            isUnread
                ? Border.all(
                  color: const Color(0xFF4A90E2).withOpacity(0.3),
                  width: 1,
                )
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showNotificationDetails(notification, index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon
                Container(
                  padding: const EdgeInsets.all(
                    8,
                  ), // Match history screen padding
                  decoration: BoxDecoration(
                    color: _getNotificationIconColor(
                      notification['type'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Match history screen border radius
                  ),
                  child: Icon(
                    _getNotificationIcon(notification['type']),
                    color: _getNotificationIconColor(notification['type']),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isUnread
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4A90E2),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4), // Match history screen spacing
                      Text(
                        notification['subtitle'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Date and Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      notification['date'],
                      style: TextStyle(
                        fontSize: 13, // Match history screen font size
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['time'],
                      style: TextStyle(
                        fontSize: 13, // Match history screen font size
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
