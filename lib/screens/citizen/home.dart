// Updated home.dart with proper database integration
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class HomePageCitizen extends StatefulWidget {
  final VoidCallback? onNavigateToSamanPay;
  final VoidCallback? onNavigateToVehicle;
  final VoidCallback? onNavigateToReport;
  final VoidCallback? onNavigateToChatbot;
  final VoidCallback? onNavigateToReload;
  final VoidCallback? onLogout;

  const HomePageCitizen({
    super.key,
    this.onNavigateToSamanPay,
    this.onNavigateToVehicle,
    this.onNavigateToReport,
    this.onNavigateToChatbot,
    this.onNavigateToReload,
    this.onLogout,
  });

  @override
  State<HomePageCitizen> createState() => _HomePageCitizenState();
}

class _HomePageCitizenState extends State<HomePageCitizen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();
  
  double userBalance = 0.0;
  bool isLoadingBalance = true;
  bool isInitialized = false;

  final List<Map<String, dynamic>> highDemandAreas = const [
    {
      "location": "Jalan Sultan Abdullah",
      "time": "3:15 PM",
      "coords": {"lat": 3.4893966989828713, "lng": 103.39396393520056}
    },
    {
      "location": "Jalan Seri Dagangan 1",
      "time": "1:15 PM",
      "coords": {"lat": 3.5192573130486497, "lng": 103.39155023558209}
    },
    {
      "location": "Lorong Peramu Permai 1 Komersial",
      "time": "11:45 AM",
      "coords": {"lat": 3.5192573130486497, "lng": 103.39155023558209}
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    await _loadUserBalance();
    
    // Initialize user data if this is their first time
    if (!isInitialized) {
      final user = _auth.currentUser;
      if (user != null) {
        try {
          await _dbService.initializeUserData(user.uid);
          setState(() {
            isInitialized = true;
          });
        } catch (e) {
          print('Error initializing user data: $e');
        }
      }
    }
  }

  Future<void> _loadUserBalance() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final balance = await _dbService.getUserBalance(user.uid);
        setState(() {
          userBalance = balance;
          isLoadingBalance = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingBalance = false;
      });
      print('Error loading balance: $e');
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load balance. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Refresh balance when returning from reload screen or other operations
  Future<void> _refreshBalance() async {
    setState(() {
      isLoadingBalance = true;
    });
    await _loadUserBalance();
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        actions: [
          // Logout button in app bar
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.black87,
            ),
            onPressed: widget.onLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBalance,
        child: Container(
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
              // Top section: Balance and Profile icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "balance",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.credit_card,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dynamic balance display
                          isLoadingBalance
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                                  ),
                                )
                              : Text(
                                  "RM ${userBalance.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              // Navigate to reload and refresh balance when returning
                              if (widget.onNavigateToReload != null) {
                                widget.onNavigateToReload!();
                                // Refresh balance after a delay (when user returns)
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (mounted) {
                                    _refreshBalance();
                                  }
                                });
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 25,
                      child: Icon(
                        Icons.person,
                        color: Colors.black54,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                "Services:",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // Enhanced Services Grid (2x2)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildServiceItem(
                    Icons.directions_car_outlined,
                    "Vehicle",
                    () {
                      if (widget.onNavigateToVehicle != null) {
                        widget.onNavigateToVehicle!();
                      }
                    },
                  ),
                  _buildServiceItem(
                    Icons.account_balance_outlined,
                    "SamanPay",
                    () {
                      if (widget.onNavigateToSamanPay != null) {
                        widget.onNavigateToSamanPay!();
                      }
                    },
                  ),
                  _buildServiceItem(
                    Icons.report_outlined,
                    "Report",
                    () {
                      if (widget.onNavigateToReport != null) {
                        widget.onNavigateToReport!();
                      }
                    },
                  ),
                  _buildServiceItem(
                    Icons.chat_bubble_outline,
                    "Chat Support",
                    () {
                      if (widget.onNavigateToChatbot != null) {
                        widget.onNavigateToChatbot!();
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                "High-Demands Areas:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              ...highDemandAreas.map((area) => Container(
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
                child: Row(
                  children: [
                    Expanded(
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
                          const Text(
                            "High-volume of vehicle park.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Today  |  ${area['time']}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _launchMaps(
                        area['coords']['lat'],
                        area['coords']['lng'],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.black54,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.black87,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}