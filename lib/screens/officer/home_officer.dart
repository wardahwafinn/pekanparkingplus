import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OfficerHomePage extends StatefulWidget {
  final VoidCallback? onNavigateToFineIssuance;
  final VoidCallback? onNavigateToReportedCases;

  const OfficerHomePage({
    super.key,
    this.onNavigateToFineIssuance,
    this.onNavigateToReportedCases,
  });

  @override
  State<OfficerHomePage> createState() => _OfficerHomePageState();
}

class _OfficerHomePageState extends State<OfficerHomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _searchResult;

  // Mock vehicle data - in real app this would come from API
  final Map<String, Map<String, dynamic>> _vehicleDatabase = {
    'VFK4567': {
      'owner': 'Ahmad Bin Ali',
      'roadTax': true,
      'roadTaxExpiry': '15 Dec 2025',
      'insurance': true,
      'insuranceExpiry': '22 Nov 2025',
      'outstandingFines': 1,
      'fineAmount': 'RM 30.00',
      'status': 'Active',
    },
    'CEM1233': {
      'owner': 'Siti Fatimah',
      'roadTax': true,
      'roadTaxExpiry': '08 Mar 2026',
      'insurance': true,
      'insuranceExpiry': '15 Jan 2026',
      'outstandingFines': 0,
      'fineAmount': 'RM 0.00',
      'status': 'Active',
    },
    'WQS6543': {
      'owner': 'Lim Wei Ming',
      'roadTax': false,
      'roadTaxExpiry': '12 Oct 2024',
      'insurance': true,
      'insuranceExpiry': '30 Dec 2025',
      'outstandingFines': 2,
      'fineAmount': 'RM 60.00',
      'status': 'Expired Road Tax',
    },
  };

  final List<Map<String, dynamic>> highDemandAreas = const [
    {
      "location": "Jalan Sultan Abdullah",
      "time": "3:15 PM",
      "description": "High-volume of vehicle park.",
    },
    {
      "location": "Jalan Seri Dagangan 1",
      "time": "1:15 PM",
      "description": "High-volume of vehicle park.",
    },
    {
      "location": "Lorong Peramu Permai 1 Komersial",
      "time": "11:45 AM",
      "description": "High-volume of vehicle park.",
    },
  ];

  void _searchVehicle() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    String plateNumber = _searchController.text.toUpperCase().trim();

    setState(() {
      _isSearching = false;
      _searchResult = _vehicleDatabase[plateNumber];
    });

    if (_searchResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle not found in database'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Plate',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon:
                      _isSearching
                          ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                          : IconButton(
                            onPressed: _searchVehicle,
                            icon: Icon(Icons.search, color: Colors.grey[600]),
                          ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _searchVehicle(),
              ),
            ),

            const SizedBox(height: 24),

            // Search Results
            if (_searchResult != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _searchController.text.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Owner:', _searchResult!['owner']),
                    const SizedBox(height: 8),
                    _buildDetailRow('Status:', _searchResult!['status']),
                    const SizedBox(height: 8),
                    _buildStatusRow(
                      'Road Tax:',
                      _searchResult!['roadTax'] ? 'Valid' : 'Expired',
                      _searchResult!['roadTax'],
                      _searchResult!['roadTaxExpiry'],
                    ),
                    const SizedBox(height: 8),
                    _buildStatusRow(
                      'Insurance:',
                      _searchResult!['insurance'] ? 'Valid' : 'Expired',
                      _searchResult!['insurance'],
                      _searchResult!['insuranceExpiry'],
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Outstanding Fines:',
                      '${_searchResult!['outstandingFines']} (${_searchResult!['fineAmount']})',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Services Section
            Row(
              children: [
                Expanded(
                  child: _buildServiceCard(
                    icon: Icons.gavel_outlined,
                    title: 'Fine\nIssuance',
                    onTap: () {
                      if (widget.onNavigateToFineIssuance != null) {
                        widget.onNavigateToFineIssuance!();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceCard(
                    icon: Icons.folder_outlined,
                    title: 'Reported\nCases',
                    onTap: () {
                      if (widget.onNavigateToReportedCases != null) {
                        widget.onNavigateToReportedCases!();
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              "High-Demands Areas:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            ...highDemandAreas.map(
              (area) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "At ${area['location']}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      area['description'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Today  |  ${area['time']}",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(
    String label,
    String status,
    bool isValid,
    String expiry,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isValid ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isValid ? Colors.green[200]! : Colors.red[200]!,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isValid ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Expires: $expiry',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
