import 'package:flutter/material.dart';

class InventoryCard extends StatelessWidget {
  final String cropName;
  final int quantity;
  final String unit;
  final String status;
  final String? imagePath;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InventoryCard({
    super.key,
    required this.cropName,
    required this.quantity,
    required this.unit,
    required this.status,
    this.imagePath,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'good':
        return Colors.green;
      case 'warning':
      case 'needs attention':
        return Colors.orange;
      case 'critical':
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'good':
        return Icons.check_circle;
      case 'warning':
      case 'needs attention':
        return Icons.warning;
      case 'critical':
      case 'poor':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Crop Image or Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              imagePath!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.agriculture,
                            color: colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Crop Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cropName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$quantity $unit',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 16,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Action Buttons
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        tooltip: 'Edit',
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: colorScheme.error,
                        ),
                        tooltip: 'Delete',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Animated version for smooth transitions
class AnimatedInventoryCard extends StatefulWidget {
  final String cropName;
  final int quantity;
  final String unit;
  final String status;
  final String? imagePath;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AnimatedInventoryCard({
    super.key,
    required this.cropName,
    required this.quantity,
    required this.unit,
    required this.status,
    this.imagePath,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<AnimatedInventoryCard> createState() => _AnimatedInventoryCardState();
}

class _AnimatedInventoryCardState extends State<AnimatedInventoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: InventoryCard(
              cropName: widget.cropName,
              quantity: widget.quantity,
              unit: widget.unit,
              status: widget.status,
              imagePath: widget.imagePath,
              onTap: widget.onTap,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
            ),
          ),
        );
      },
    );
  }
} 