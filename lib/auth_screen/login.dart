import 'package:book_store/routes.dart';
import 'package:book_store/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isRemeber = false;
  double _opacity = 0.0;
  double _scale = 0.6;
  final Map<String, dynamic> userData = {
    'name': '',
    'profileImage': '',
    'email': '',
    'role': 'user',
    'billingAddress': '',
    'shippingAddress': '',
  };
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _login() async {
    FocusScope.of(context).unfocus();
    try {
      final user = await UserService.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _isRemeber,
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        Navigator.pushReplacementNamed(context, AppRoutes.splashScreen);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed! Please try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String getAvatarUrl(String name) {
    String seed = name.isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    return 'https://api.dicebear.com/8.x/initials/png?seed=$seed';
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Get Started',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
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
                Image.asset(
                  "assets/images/logo-dark.png",
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please fill your details to login.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _isRemeber,
                            onChanged: (value) {
                              setState(() {
                                _isRemeber = value ?? false;
                              });
                            },
                          ),
                          const Text('Remember me'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF121212),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(color: Color(0xFFDEDEDE)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Or login with',
                  style: TextStyle(fontSize: 16, color: Color(0xFF121212)),
                ),
                const SizedBox(height: 10),
                SignInButton(
                  Buttons.Google,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    userData['name'] = _nameController.text.trim().isNotEmpty
                        ? _nameController.text.trim()
                        : 'Google User';
                    userData['email'] = ''; // will be filled in service
                    userData['profileImage'] = getAvatarUrl(userData['name']);
                    userData['role'] = 'user';
                    userData['billingAddress'] = '';
                    userData['shippingAddress'] = '';

                    final result = await UserService.signInWithGoogle(userData);

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['message'] ?? 'Something went wrong',
                        ),
                      ),
                    );

                    if (result['success'] == true) {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.splashScreen,
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                SignInButton(
                  Buttons.FacebookNew,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Facebook login is not available yet.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: TextStyle(fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Color(0xFF121212),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
