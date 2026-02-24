// error_screen.dart
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final bool showBackButton;
  final bool showRetryButton;
  final IconData? icon;
  final Color? iconColor;
  
  const ErrorScreen({
    Key? key,
    this.title,
    this.message,
    this.buttonText,
    this.onRetry,
    this.onGoBack,
    this.showBackButton = true,
    this.showRetryButton = true,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  factory ErrorScreen.generic({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorScreen(
      title: 'Something Went Wrong',
      message: message ?? 'An unexpected error occurred. Please try again.',
      buttonText: 'Try Again',
      onRetry: onRetry,
      icon: Icons.error_outline,
      iconColor: Colors.red,
    );
  }

  factory ErrorScreen.notFound({
    String? message,
    VoidCallback? onGoBack,
  }) {
    return ErrorScreen(
      title: 'Page Not Found',
      message: message ?? 'The page you are looking for doesn\'t exist.',
      buttonText: 'Go Back',
      onGoBack: onGoBack,
      showRetryButton: false,
      icon: Icons.search_off,
      iconColor: Colors.orange,
    );
  }

  factory ErrorScreen.serverError({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorScreen(
      title: 'Server Error',
      message: message ?? 'Our servers are experiencing issues. Please try again later.',
      buttonText: 'Retry',
      onRetry: onRetry,
      icon: Icons.cloud_off,
      iconColor: Colors.purple,
    );
  }

  factory ErrorScreen.networkError({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorScreen(
      title: 'Network Error',
      message: message ?? 'Unable to connect to the server. Please check your internet connection.',
      buttonText: 'Retry',
      onRetry: onRetry,
      icon: Icons.signal_wifi_off,
      iconColor: Colors.blue,
    );
  }

  factory ErrorScreen.permissionDenied({
    String? message,
    VoidCallback? onGoBack,
  }) {
    return ErrorScreen(
      title: 'Access Denied',
      message: message ?? 'You don\'t have permission to access this page.',
      buttonText: 'Go Back',
      onGoBack: onGoBack,
      showRetryButton: false,
      icon: Icons.block,
      iconColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showBackButton
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onGoBack ?? () => Navigator.pop(context),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.red).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.error_outline,
                  size: 60,
                  color: iconColor ?? Colors.red,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                title ?? 'Oops!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                message ?? 'Something went wrong. Please try again.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Retry Button
              if (showRetryButton && onRetry != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonText ?? 'Try Again',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              // Go Back Button (alternative to retry)
              if (!showRetryButton && onGoBack != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onGoBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonText ?? 'Go Back',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Additional Options
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Contact Support
                  TextButton(
                    onPressed: () {
                      // TODO: Implement contact support functionality
                      // This could open email, launch URL, or show dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contact support feature coming soon!'),
                        ),
                      );
                    },
                    child: const Text('Contact Support'),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Report Issue
                  TextButton(
                    onPressed: () {
                      // TODO: Implement report issue functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report issue feature coming soon!'),
                        ),
                      );
                    },
                    child: const Text('Report Issue'),
                  ),
                ],
              ),
              
              // Debug Info (optional - remove in production)
              if (const bool.fromEnvironment('DEBUG'))
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Info:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error Screen Instance',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}