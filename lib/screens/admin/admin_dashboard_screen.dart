import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ulingo/screens/admin/level_management_screen.dart';
import 'package:ulingo/screens/admin/reports_screen.dart';
import 'package:ulingo/screens/admin/students_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const LevelManagementScreen(),
    const StudentsManagementScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 600,
            backgroundColor: Colors.orange[50],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  Icon(Icons.admin_panel_settings, size: 40, color: Colors.orange),
                  SizedBox(height: 8),
                  Text(
                    'Admin',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    tooltip: 'Sign Out',
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard, color: Colors.orange),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school),
                selectedIcon: Icon(Icons.school, color: Colors.orange),
                label: Text('Levels'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people, color: Colors.orange),
                label: Text('Students'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                selectedIcon: Icon(Icons.analytics, color: Colors.orange),
                label: Text('Reports'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// Dashboard Home Screen
class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, usersSnapshot) {
          if (!usersSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = usersSnapshot.data!.docs;
          final totalStudents = users.length;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('levels').snapshots(),
            builder: (context, levelsSnapshot) {
              final totalLevels = levelsSnapshot.hasData
                  ? levelsSnapshot.data!.docs.length
                  : 0;

              // Calculate average completion rate
              int totalCompleted = 0;
              for (var user in users) {
                final data = user.data() as Map<String, dynamic>;
                final completedLevels = List<int>.from(data['completedLevels'] ?? []);
                totalCompleted += completedLevels.length;
              }
              final avgCompletionRate = totalStudents > 0 && totalLevels > 0
                  ? (totalCompleted / (totalStudents * totalLevels) * 100)
                  .toStringAsFixed(1)
                  : '0.0';

              // Get top students
              final sortedUsers = users.toList()
                ..sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aCompleted =
                      List<int>.from(aData['completedLevels'] ?? []).length;
                  final bCompleted =
                      List<int>.from(bData['completedLevels'] ?? []).length;
                  return bCompleted.compareTo(aCompleted);
                });
              final topStudents = sortedUsers.take(5).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total Students',
                            value: totalStudents.toString(),
                            icon: Icons.people,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Total Levels',
                            value: totalLevels.toString(),
                            icon: Icons.school,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Completion Rate',
                            value: '$avgCompletionRate%',
                            icon: Icons.trending_up,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Top Students Section
                    const Text(
                      'Top Students',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(3),
                                2: FlexColumnWidth(2),
                                3: FlexColumnWidth(2),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                  ),
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                        'Rank',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                        'Student Name',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                        'Levels Completed',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                        'Streak',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                ...topStudents.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final userData =
                                  entry.value.data() as Map<String, dynamic>;
                                  final completedLevels = List<int>.from(
                                      userData['completedLevels'] ?? []);
                                  final streak = userData['streak'] ?? 0;

                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            if (index == 0)
                                              const Icon(Icons.emoji_events,
                                                  color: Colors.amber, size: 20)
                                            else if (index == 1)
                                              Icon(Icons.emoji_events,
                                                  color: Colors.grey[400],
                                                  size: 20)
                                            else if (index == 2)
                                                Icon(Icons.emoji_events,
                                                    color: Colors.brown[300],
                                                    size: 20)
                                              else
                                                const SizedBox(width: 20),
                                            const SizedBox(width: 8),
                                            Text('#${index + 1}'),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child:
                                        Text(userData['name'] ?? 'Unknown'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                            '${completedLevels.length} / $totalLevels'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.local_fire_department,
                                                color: Colors.orange,
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text('$streak days'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 40, color: color),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.trending_up, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}