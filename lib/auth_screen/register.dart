import 'package:book_store/routes.dart';
import 'package:book_store/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> userData = {
    'name': '',
    'profileImage': '',
    'email': '',
    'role': 'user',
    'billingAddress': '',
    'shippingAddress': '',
  };

  String getAvatarUrl(String name) {
    String seed = name.isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    return 'https://api.dicebear.com/8.x/initials/svg?seed=$seed';
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  double _opacity = 0.0;
  double _scale = 0.6;
  bool _isObscure = true;

  void _register() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      userData['name'] = _nameController.text.trim();
      userData['email'] = _emailController.text.trim();
      userData['profileImage'] = getAvatarUrl(_nameController.text.trim());

      try {
        final user = await UserService.registerUser(
          _emailController.text.trim(),
          _passwordController.text,
          userData,
        );

        if (user != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );

          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();

          Navigator.pushNamed(context, AppRoutes.login);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration failed!')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  "assets/images/logo-dark.png",
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please fill your details to register.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color(0xFFDEDEDE),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color(0xFFDEDEDE),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: const Color(0xFFDEDEDE),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          filled: true,
                          fillColor: const Color(0xFFDEDEDE),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          } else if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF121212),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Color(0xFFDEDEDE)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Or register with',
                  style: TextStyle(fontSize: 16, color: Color(0xFF121212)),
                ),
                const SizedBox(height: 10),

                // Social Buttons
              SignInButton(
  Buttons.Google,
  onPressed: () async {
    FocusScope.of(context).unfocus();

    userData['name'] = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Google User';
    userData['email'] = ''; // will be auto-filled in service
    userData['profileImage'] =
        getAvatarUrl(userData['name']);
    userData['role'] = 'user';
    userData['billingAddress'] = '';
    userData['shippingAddress'] = '';

    final user = await UserService.signInWithGoogle(userData);
    print(user);

   if (user != null && mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Google registration successful!')),
  );
  Navigator.pushReplacementNamed(context, AppRoutes.viewBook);
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Google registration failed!')),
  );
  print("❌ Google sign-in returned null.");
}
  }
),
const SizedBox(height: 10),
SignInButton(
  Buttons.FacebookNew,
  onPressed: () async {
    FocusScope.of(context).unfocus();

    userData['name'] = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Facebook User';
    userData['email'] = ''; // will be auto-filled in service
    userData['profileImage'] =
        getAvatarUrl(userData['name']);
    userData['role'] = 'user';
    userData['billingAddress'] = '';
    userData['shippingAddress'] = '';

    final user = await UserService.signInWithFacebook(userData);

    if (user != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facebook registration successful!')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.viewBook);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facebook registration failed!')),
      );
    }
  },
),

                const SizedBox(height: 30),

                // Bottom navigation link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF121212),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
