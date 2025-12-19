import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final user = FirebaseAuth.instance.currentUser;
  late DatabaseReference _userRef;

  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userRef = FirebaseDatabase.instance.ref("users/${user?.uid}");
  }

  // 🛠️ METHOD: updateProfile() from Class Diagram
  Future<void> _updateProfile() async {
    try {
      await _userRef.update({
        "userName": _nameController.text.trim(),
      });
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  // 🚪 METHOD: logout() from Class Diagram
  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        backgroundColor: const Color(0xFFFF7F50),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _userRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            final userModel = UserModel.fromMap(data);

            // Set controller text only if not currently typing
            if (!_isEditing) _nameController.text = userModel.userName;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFFF7F50),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  // User Info Section
                  _isEditing
                      ? TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "User Name"),
                  )
                      : Text(
                    userModel.userName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  Text(userModel.userEmail, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  // Edit / Save Button
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_isEditing) {
                        _updateProfile();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                    icon: Icon(_isEditing ? Icons.save : Icons.edit),
                    label: Text(_isEditing ? "Save Changes" : "Edit Profile"),
                  ),

                  const Divider(height: 60),

                  // Stats (Read-only as per diagram logic)
                  _buildInfoTile("Learning", userModel.selectedLanguages.join(", "), Icons.language),
                  _buildInfoTile("Streak", "${userModel.streakCount} Days", Icons.local_fire_department),

                  const SizedBox(height: 40),

                  // 🛑 Logout Button (Only here!)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Sign Out"),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("Loading..."));
        },
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF7F50)),
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}