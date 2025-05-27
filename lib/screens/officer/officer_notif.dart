import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OfficerNotificationsPage extends StatelessWidget {
  const OfficerNotificationsPage({super.key});

  final List<Map<String, dynamic>> notifications = const [
    {
      'title': 'Unpaid Parking Alert',
      'subtitle': 'WXD 3214 at Jalan Masjid, Zone A',
      'time': 'Today\n9:40 AM',
      'type': 'unpaid',
      'isToday': true,
    },
    {
      'title': 'Overstayed Parking Alert',
      'subtitle': 'JKL 9087 at Kompleks Niaga Pekan - Zone C',
      'time': 'Today\n9:25 AM',
      'type': 'overstayed',
      'isToday': true,
    },
    {
      'title': 'Unpaid Parking Alert',
      'subtitle': 'NBR 3313 at Medan Selera Parking - Zone B',
      'time': 'Today\n9:21 AM',
      'type': 'unpaid',
      'isToday': true,
    },
    {
      'title': 'Unpaid Parking Alert',
      'subtitle': 'WDL 8823 at Jalan Istana',
      'time': '21 April 2025\n4:00 PM',
      'type': 'unpaid',
      'isToday': false,
    },
    {
      'title': 'Handicapped Spot Violation',
      'subtitle': 'ABC 7693 at Kompleks Niaga Pekan - Zone A',
      'time': '21 April 2025\n2:55 PM',
      'type': 'violation',
      'isToday': false,
    },
    {
      'title': 'Double Parking Report',
      'subtitle': 'WSM 3311 at Pekan Bus Station',
      'time': '21 April 2025\n1:40 PM',
      'type': 'report',
      'isToday': false,
    },
  ];

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
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: Container(),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 8,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification['type']),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                title: Text(
                  notification['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    notification['subtitle'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                trailing: Text(
                  notification['time'],
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                onTap: () {
                  _showNotificationDetails(context, notification);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'unpaid':
        return Colors.orange;
      case 'overstayed':
        return Colors.red;
      case 'violation':
        return Colors.purple;
      case 'report':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showNotificationDetails(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(notification['subtitle']),
              const SizedBox(height: 12),
              Text(
                'Time:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(notification['time'].replaceAll('\n', ' at ')),
              const SizedBox(height: 12),
              Text(
                'Type:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    notification['type'],
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getNotificationColor(notification['type']),
                  ),
                ),
                child: Text(
                  notification['type'].toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getNotificationColor(notification['type']),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Here you would navigate to the appropriate action page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigating to action page...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
              ),
              child: const Text(
                'Take Action',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
