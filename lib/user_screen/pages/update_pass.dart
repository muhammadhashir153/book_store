import 'package:book_store/services/user_service.dart';
import 'package:flutter/material.dart';

class UpdatePass extends StatefulWidget {
  final String? userId;
  const UpdatePass({super.key, required this.userId});

  @override
  State<UpdatePass> createState() => _UpdatePassState();
}

class _UpdatePassState extends State<UpdatePass> {
  // final TextEditingController _oldPass = TextEditingController();
  // final TextEditingController _newPass = TextEditingController();
  // final TextEditingController _confirmPass = TextEditingController();
  Map<String, dynamic>? existingData;
  Map<String, dynamic>? updatedData;

  Future<void> _getUserCurrentData() async {
    final data = await UserService.getUserData(widget.userId!);
    setState(() {
      existingData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserCurrentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Center(child: Text("Hello")),
    );
  }
}
