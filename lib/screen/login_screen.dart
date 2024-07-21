import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rewardrangerapp/helper_function/api_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rewardrangerapp/screen/forgot_password.dart';
import 'dashboard_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController(text: "flutterdev.pratik@gmail.com");
  final TextEditingController _passwordController = TextEditingController(text: "Welcome@123");
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final ApiService _apiService = GetIt.instance<ApiService>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        Map<String, dynamic> credentials = {
          'email': _emailController.text,
          'password': _passwordController.text,
        };
        final response = await _apiService.login(credentials);
        final token = response['token'];

        // Introduce a delay of 5 seconds
        await Future.delayed(const Duration(milliseconds: 1500));

        // Store the token securely
        await _storage.write(key: 'token', value: token);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        // Navigate to the dashboard screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make the AppBar transparent
        elevation: 0, // Remove AppBar elevation
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPassword()),
                          );
                        },
                        child: const Text('Forgot your password?'),
                      ),
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? Center(
                      child: LoadingAnimationWidget.discreteCircle(
                          color: const Color.fromARGB(199, 23, 228, 255),
                          size: 50,
                          secondRingColor: const Color.fromARGB(255, 135, 206, 235),
                          thirdRingColor: const Color.fromARGB(255, 240, 128, 128)),
                    )
                  : SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 10, 90, 211)),
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                    ),
              const SizedBox(height: 20.0), // Add some space below the button
            ],
          ),
        ),
      ),
    );
  }
}
