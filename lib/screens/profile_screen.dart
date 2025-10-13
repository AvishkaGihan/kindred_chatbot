import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: user.photoURL != null
                        ? CachedNetworkImageProvider(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Icon(Icons.person, size: 60)
                        : null,
                  ),
                  SizedBox(height: 24),
                  Text(
                    user.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 32),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Email'),
                      subtitle: Text(user.email),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Member since'),
                      subtitle: Text(
                        '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).signOut();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
