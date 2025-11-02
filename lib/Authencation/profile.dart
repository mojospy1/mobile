import 'package:apphoctienganh/Authencation/AuthProvider.dart';
import 'package:apphoctienganh/Authencation/settingscreen.dart';
import 'package:apphoctienganh/Flashcash/createflashcard.dart';
import 'package:apphoctienganh/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<AuthProvider>().getCurrentUserProfile();
    final imageUrl = userProfile?['photoURL'] ?? '';
    final email = userProfile?['email'] ?? 'Email chưa có';
    final displayName = userProfile?['displayName'] ?? email;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(83, 209, 197, 1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 140,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child:
                              imageUrl.isNotEmpty
                                  ? ClipOval(
                                    child: Image.network(
                                      imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.error,
                                          size: 50,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  )
                                  : ClipOval(
                                    child: Image.asset(
                                      'assets/logoapp.png',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // context.read<AuthProvider>().signOut(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingScreen(),
                                ),
                              );
                            },
                            tooltip: 'Đăng xuất',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40), // Cho Avatar trồi lên
              // User Info
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(email, style: const TextStyle(color: Colors.grey)),

              const SizedBox(height: 20),

              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("⭐", "0.0", "Rating"),
                    _buildStatItem("🛡", "0", "Level"),
                    _buildStatItem("👥", "0", "Following"),
                    _buildStatItem("👤", "0", "Followers"),
                  ],
                ),
              ),

              const SizedBox(height: 30), // Đệm cho cuối trang
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateFlashcard()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Flashcard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Người dùng",
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
