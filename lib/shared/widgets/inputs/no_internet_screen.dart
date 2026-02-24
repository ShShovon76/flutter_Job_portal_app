// no_internet_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NoInternetScreen extends StatefulWidget {
  final VoidCallback? onRetry;
  final bool allowManualRetry;

  const NoInternetScreen({Key? key, this.onRetry, this.allowManualRetry = true})
    : super(key: key);

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isChecking = false;
  bool _autoRetryEnabled = true;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    if (_autoRetryEnabled) {
      _startAutoRetry();
    }
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _retryConnection();
      }
    });
  }

  void _startAutoRetry() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      final result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none && mounted) {
        timer.cancel();
        _retryConnection();
      }
    });
  }

  Future<void> _retryConnection() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      // Check connectivity
      final result = await _connectivity.checkConnectivity();

      if (result == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Still no internet connection'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Internet is back
        if (widget.onRetry != null) {
          widget.onRetry!();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking connection: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Illustration
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  'No Internet Connection',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'Please check your internet connection and try again.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Try these steps:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildStep(
                        '1. Check your Wi-Fi or mobile data',
                        Icons.wifi,
                      ),
                      _buildStep(
                        '2. Turn airplane mode on and off',
                        Icons.airplanemode_active,
                      ),
                      _buildStep(
                        '3. Restart your router or device',
                        Icons.power_settings_new,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Retry Button
                if (widget.allowManualRetry)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isChecking ? null : _retryConnection,
                      icon: _isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        _isChecking ? 'Checking...' : 'Try Again',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Settings Button
                TextButton(
                  onPressed: () async {
                    // Open device settings
                    // Note: This might not work on all platforms
                    // For iOS, you need URL schemes
                    // For Android, you can use: AppSettings.openWIFISettings()
                  },
                  child: const Text(
                    'Open Network Settings',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blue[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.blue[800])),
          ),
        ],
      ),
    );
  }
}
