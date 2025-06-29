import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';

class PermissionSettingsPage extends StatefulWidget {
  const PermissionSettingsPage({super.key});

  @override
  State<PermissionSettingsPage> createState() => _PermissionSettingsPageState();
}

class _PermissionSettingsPageState extends State<PermissionSettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<PermissionProvider>(context, listen: false).checkAllPermissions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Settings'),
      ),
      body: Consumer<PermissionProvider>(
        builder: (context, permissionProvider, child) {
          if (permissionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Manage App Permissions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    try {
                      await permissionProvider.requestAllPermissions();
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Permissions updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Request All Permissions'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () async {
                    await permissionProvider.openAppSettings();
                  },
                  child: const Text('Open App Settings'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 