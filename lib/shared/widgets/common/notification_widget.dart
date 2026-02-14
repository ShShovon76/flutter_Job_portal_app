import 'package:flutter/material.dart';

class NotificationWidget extends StatelessWidget {
  final String message;
  final String type;
  final VoidCallback onDismiss;

  const NotificationWidget({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  Color _getColor() {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getIcon(), color: _getColor(), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _getColor(),
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 16),
            color: _getColor(),
          ),
        ],
      ),
    );
  }
}