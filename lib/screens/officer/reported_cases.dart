import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportedCasesPage extends StatefulWidget {
  const ReportedCasesPage({super.key});

  @override
  State<ReportedCasesPage> createState() => _ReportedCasesPageState();
}

class _ReportedCasesPageState extends State<ReportedCasesPage> {
  final List<Map<String, dynamic>> reportedCases = [
    {
      'id': 'RPT001',
      'type': 'Double Parking',
      'plate': 'ABC 1234',
      'location': 'Jalan Sultan Abdullah',
      'reportedBy': 'Ahmad Bin Ali',
      'date': '25 May 2025',
      'time': '2:30 PM',
      'status': 'Pending',
      'priority': 'High',
      'description': 'Vehicle blocking traffic flow during peak hours',
      'hasEvidence': true,
    },
    {
      'id': 'RPT002',
      'type': 'Handicapped Spot Violation',
      'plate': 'DEF 5678',
      'location': 'Kompleks Niaga Pekan',
      'reportedBy': 'Siti Fatimah',
      'date': '25 May 2025',
      'time': '11:45 AM',
      'status': 'Under Investigation',
      'priority': 'High',
      'description': 'Non-disabled vehicle parked in handicapped spot',
      'hasEvidence': true,
    },
    {
      'id': 'RPT003',
      'type': 'Illegal Parking',
      'plate': 'GHI 9012',
      'location': 'Medan Selera Parking',
      'reportedBy': 'Lim Wei Ming',
      'date': '24 May 2025',
      'time': '6:15 PM',
      'status': 'Resolved',
      'priority': 'Medium',
      'description': 'Vehicle parked in fire lane',
      'hasEvidence': false,
    },
    {
      'id': 'RPT004',
      'type': 'Overstayed Parking',
      'plate': 'JKL 3456',
      'location': 'Jalan Istana',
      'reportedBy': 'Raj Kumar',
      'date': '24 May 2025',
      'time': '3:20 PM',
      'status': 'Pending',
      'priority': 'Low',
      'description': 'Vehicle exceeded 2-hour parking limit',
      'hasEvidence': true,
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Pending', 'Under Investigation', 'Resolved'];

  List<Map<String, dynamic>> get filteredCases {
    if (_selectedFilter == 'All') {
      return reportedCases;
    }
    return reportedCases.where((reportCase) => reportCase['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reported Cases',
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
        child: Column(
          children: [
            // Filter Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: _filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black54,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Cases List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredCases.length,
                itemBuilder: (context, index) {
                  final reportCase = filteredCases[index];
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
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 8,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(reportCase['priority']),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              reportCase['type'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(reportCase['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _getStatusColor(reportCase['status']),
                              ),
                            ),
                            child: Text(
                              reportCase['status'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(reportCase['status']),
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Vehicle: ${reportCase['plate']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Location: ${reportCase['location']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${reportCase['date']} at ${reportCase['time']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const Spacer(),
                              if (reportCase['hasEvidence'])
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.green[200]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.photo_camera,
                                        size: 12,
                                        color: Colors.green[700],
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Evidence',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => _showCaseDetails(context, reportCase),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'under investigation':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showCaseDetails(BuildContext context, Map<String, dynamic> reportCase) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Case ${reportCase['id']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Type:', reportCase['type']),
                const SizedBox(height: 8),
                _buildDetailRow('Vehicle:', reportCase['plate']),
                const SizedBox(height: 8),
                _buildDetailRow('Location:', reportCase['location']),
                const SizedBox(height: 8),
                _buildDetailRow('Reported By:', reportCase['reportedBy']),
                const SizedBox(height: 8),
                _buildDetailRow('Date & Time:', '${reportCase['date']} at ${reportCase['time']}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(reportCase['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getStatusColor(reportCase['status']),
                        ),
                      ),
                      child: Text(
                        reportCase['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(reportCase['status']),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Priority: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(reportCase['priority']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getPriorityColor(reportCase['priority']),
                        ),
                      ),
                      child: Text(
                        reportCase['priority'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getPriorityColor(reportCase['priority']),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(reportCase['description']),
                const SizedBox(height: 12),
                if (reportCase['hasEvidence']) ...[
                  const Text(
                    'Evidence:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 30, color: Colors.grey),
                          SizedBox(height: 4),
                          Text(
                            'Evidence Photo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (reportCase['status'] != 'Resolved') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateCaseStatus(reportCase);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  'Investigate',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _issueFineForCase(reportCase);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                ),
                child: const Text(
                  'Issue Fine',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _updateCaseStatus(Map<String, dynamic> reportCase) {
    setState(() {
      reportCase['status'] = 'Under Investigation';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Case ${reportCase['id']} status updated to Under Investigation'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _issueFineForCase(Map<String, dynamic> reportCase) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Issue Fine'),
          content: Text(
            'Issue a fine for vehicle ${reportCase['plate']} based on this report?\n\n'
            'Violation: ${reportCase['type']}\n'
            'Location: ${reportCase['location']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  reportCase['status'] = 'Resolved';
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fine issued for case ${reportCase['id']}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
              ),
              child: const Text(
                'Issue Fine',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}