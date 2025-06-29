import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import 'home_page.dart';

class PermissionRequestPage extends StatefulWidget {
  const PermissionRequestPage({super.key});

  @override
  State<PermissionRequestPage> createState() => _PermissionRequestPageState();
}

class _PermissionRequestPageState extends State<PermissionRequestPage> {
  final PermissionService _permissionService = PermissionService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final allGranted = await _permissionService.areAllPermissionsGranted();
    setState(() {
      _isLoading = false;
    });
    
    if (allGranted && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Future<void> _requestAllPermissions() async {
    try {
      await _permissionService.requestAllPermissions();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions Required'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'AgriDiary needs permissions to work properly',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _requestAllPermissions,
                    child: const Text('Grant Permissions'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    child: const Text('Continue Without Permissions'),
                  ),
                ],
              ),
            ),
    );
  }
} 