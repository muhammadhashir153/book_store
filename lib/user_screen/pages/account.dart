import 'package:book_store/routes.dart';
import 'package:book_store/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? userId;
  bool isLoading = true;
  bool isLogin = false;
  Map<String, dynamic> userData = {};

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uid');
  }

  Future<void> _getUserData() async {
    await _getUserId();
    if (userId == null) {
      setState(() {
        isLogin = false;
        isLoading = false;
      });
      return;
    }

    final data = await UserService.getUserData(userId!);
    if (data != null) {
      setState(() {
        userData = data;
        isLogin = true;
        isLoading = false;
      });
    } else {
      setState(() {
        isLogin = true;
        isLoading = false;
        userData = {};
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading && !isLogin
          ? const Center(child: CircularProgressIndicator())
          : userData.isEmpty
          ? Center(child: Text("User Data not found for ID: $userId"))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          userData['profileImage'],
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return Icon(Icons.person, size: 150);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                Color(0xFF121212),
                              ),
                            ),
                            icon: Icon(Icons.edit, color: Color(0xFFDEDEDE)),
                            label: Text(
                              "Edit Profile",
                              style: TextStyle(color: Color(0xFFDEDEDE)),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              UserService.logoutUser();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.landing,
                                (route) => false,
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                Color(0xFF121212),
                              ),
                            ),
                            icon: Icon(Icons.logout, color: Color(0xFFDEDEDE)),
                            label: Text(
                              "Logout",
                              style: TextStyle(color: Color(0xFFDEDEDE)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
