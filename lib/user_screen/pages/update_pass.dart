import 'package:book_store/routes.dart';
import 'package:flutter/material.dart';
import 'package:book_store/services/user_service.dart';

class UpdatePass extends StatefulWidget {
  final String? userId;
  const UpdatePass({super.key, required this.userId});

  @override
  State<UpdatePass> createState() => _UpdatePassState();
}

class _UpdatePassState extends State<UpdatePass> {
  final TextEditingController _oldPass = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  String? newPassError;
  String? confirmPassError;

  bool _showOldPass = false;
  bool _showNewPass = false;
  bool _showConfirmPass = false;

  @override
  void initState() {
    super.initState();
    _newPass.addListener(_validatePasswords);
    _confirmPass.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    setState(() {
      newPassError = _newPass.text.length < 8
          ? "Password must be at least 8 characters"
          : null;

      confirmPassError = _confirmPass.text != _newPass.text
          ? "Passwords do not match"
          : null;
    });
  }

  void submitPasswordUpdate() async {
    if (newPassError == null && confirmPassError == null) {
      final result = await UserService.updateUserPassword(
        _oldPass.text.trim(),
        _newPass.text.trim(),
      );

      if (result['success'] && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
          arguments: 2,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fix the errors before submitting."),
        ),
      );
    }
  }

  @override
  void dispose() {
    _oldPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Change Your Password",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Old Password
            TextField(
              controller: _oldPass,
              obscureText: !_showOldPass,
              decoration: InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showOldPass ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showOldPass = !_showOldPass;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // New Password
            TextField(
              controller: _newPass,
              obscureText: !_showNewPass,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
                errorText: newPassError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showNewPass ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showNewPass = !_showNewPass;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password
            TextField(
              controller: _confirmPass,
              obscureText: !_showConfirmPass,
              decoration: InputDecoration(
                labelText: "Confirm New Password",
                border: OutlineInputBorder(),
                errorText: confirmPassError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPass ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showConfirmPass = !_showConfirmPass;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitPasswordUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF121212),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Update Password",
                  style: TextStyle(color: Color(0xFFDEDEDE)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
