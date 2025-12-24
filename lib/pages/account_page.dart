import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // <--- COMMENTED OUT TO SKIP STORAGE

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final user = FirebaseAuth.instance.currentUser;

  // Local state for toggles
  bool _notificationsEnabled = true;
  File? _localImageFile; // To show the picked image immediately
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
  }

  // --- ACTIONS ---

  // 1. Pick Image (Modified for LOCAL ONLY Demo)
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    // Pick the image
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      setState(() {
        _localImageFile = file;
        // _isUploading = true; // No loading needed for local only
      });

      // NOTE: Since we are skipping Storage for now, we just show the local file.
      // We do NOT upload to Firebase Storage or update Firestore here.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated (Local Demo Only)!"), backgroundColor: Colors.green),
        );
      }
    }
  }

  // 2. Change Password Dialog
  void _showChangePasswordDialog() {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: "Enter new password"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await user?.updatePassword(passwordController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password updated!")));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // 3. Edit Name Dialog
  void _showEditNameDialog(String currentName) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit User Name"),
        content: TextField(controller: nameController),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async{
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .update({"userName": nameController.text.trim()});
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // 4. Logout
  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDD0),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if document exists and has data
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final userModel = UserModel.fromMap(data);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(userModel),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(Icons.emoji_events, "${userModel.lessonsCompleted * 5}", "Achievements"),
                      _buildStatItem(Icons.menu_book, "${userModel.lessonsCompleted}", "Lessons"),
                      _buildStatItem(Icons.local_fire_department, "${userModel.streakCount}", "Days Streak"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text("Account Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildSettingsTile(
                    title: "Edit Profile",
                    onTap: () => _showEditNameDialog(userModel.userName),
                  ),
                  _buildSettingsTile(title: "Change Language", onTap: () {}),
                  SwitchListTile(
                    title: const Text("Notification", style: TextStyle(fontWeight: FontWeight.bold)),
                    value: _notificationsEnabled,
                    activeColor: const Color(0xFFFF7F50),
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  _buildSettingsTile(
                    title: "Change Password",
                    onTap: _showChangePasswordDialog,
                  ),
                  const SizedBox(height: 30),
                  const Text("About", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildDropdownTile("FAQ", "Q: How do I learn?\nA: Just follow the roadmap!"),
                  _buildDropdownTile("Privacy Policy", "We value your privacy."),
                  _buildDropdownTile("Terms and Agreements", "By using U-Lingo, you agree to have fun."),
                  _buildSettingsTile(title: "Help", onTap: () {}),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: _logout,
                      child: const Text("Sign Out", style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          }
          return const Center(child: Text("Loading User Data..."));
        },
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildProfileCard(UserModel userModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // 4. UPDATED AVATAR (Simplified for Local Demo)
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  // Logic: Show Local File if picked, else show Network URL, else show Camera Icon
                  backgroundImage: _localImageFile != null
                      ? FileImage(_localImageFile!) as ImageProvider
                      : (userModel.profileImageUrl != null
                      ? NetworkImage(userModel.profileImageUrl!)
                      : null),
                  child: (_localImageFile == null && userModel.profileImageUrl == null)
                      ? const Icon(Icons.camera_alt, color: Colors.grey)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userModel.userName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  userModel.userEmail,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Text("Proficiency Level", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const Row(
                  children: [
                    Text("🇨🇳 Beginner", style: TextStyle(fontSize: 12)),
                    SizedBox(width: 10),
                    Text("🇬🇧 Intermediate", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF7F50), size: 32),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSettingsTile({required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile(String title, String content) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(content, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }
}