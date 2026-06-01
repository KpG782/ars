import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  final List<Map<String, dynamic>> _savedPlaces = [
    {
      'name': 'Home',
      'address': '123 Main Street, Quezon City, Metro Manila',
      'icon': LucideIcons.house,
      'color': AppTheme.blue,
    },
    {
      'name': 'Work',
      'address': 'Makati Business District, Makati City',
      'icon': LucideIcons.briefcase,
      'color': AppTheme.orange,
    },
    {
      'name': 'Gym',
      'address': 'BGC, Taguig City, Metro Manila',
      'icon': LucideIcons.dumbbell,
      'color': AppTheme.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Saved Places',
          style: AppTheme.figtreeBold.copyWith(
            color: AppTheme.onSurfaceColor,
            fontSize: AppTheme.fontSize18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
      ),
      body: _savedPlaces.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _savedPlaces.length,
              itemBuilder: (context, index) {
                return _buildPlaceCard(_savedPlaces[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlaceDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Place'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.map_pin_off, size: 100, color: AppTheme.grey400),
          SizedBox(height: 20),
          Text(
            'No Saved Places',
            style: TextStyle(
              fontSize: AppTheme.fontSize20,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add your frequently visited places\nfor faster bookings',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.fontSize14,
              color: AppTheme.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (place['color'] as Color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            place['icon'] as IconData,
            color: place['color'] as Color,
            size: 28,
          ),
        ),
        title: Text(
          place['name'] as String,
          style: const TextStyle(
            fontSize: AppTheme.fontSize16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            place['address'] as String,
            style: const TextStyle(
              fontSize: AppTheme.fontSize14,
              color: AppTheme.grey600,
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(LucideIcons.ellipsis_vertical),
          onSelected: (value) {
            if (value == 'edit') {
              _showEditPlaceDialog(place);
            } else if (value == 'delete') {
              _showDeleteConfirmation(place);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(LucideIcons.pencil, size: 20),
                  SizedBox(width: 12),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(LucideIcons.trash_2, size: 20, color: AppTheme.red),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: AppTheme.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPlaceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Place'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Place Name',
                hintText: 'e.g., Home, Office',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Address',
                hintText: 'Enter full address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Place saved successfully!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditPlaceDialog(Map<String, dynamic> place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Place'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Place Name',
                hintText: place['name'] as String,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Address',
                hintText: place['address'] as String,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Place updated successfully!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Place'),
        content: Text('Are you sure you want to delete "${place['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _savedPlaces.remove(place);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Place deleted successfully!'),
                  backgroundColor: AppTheme.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
