import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import '../auth/register_screen.dart';
import '../auth/final_registration_screen.dart';
import '../../services/api_services.dart'; // Add this import for APIService

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'UniMate',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Don't have an account? Register here",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Step 1: Perform Login
        final response = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        // print('Login Response: $response');

        if (response['status'] == true) {
          // Initialize ApiService with the token
          final token = response['token'];
          final apiService = ApiService(token: token);

          // Step 2: Check Approval Status
          final approvalResponse = await apiService.checkApproval();

          // print('Approval Response: $approvalResponse');

          final bool isFilled = approvalResponse['filled'] ?? false;
          final bool isApproved = approvalResponse['status'] ?? false;

          // print('Is Filled: $isFilled, Is Approved: $isApproved');

          if (isFilled && isApproved) {
            // Account is fully approved → Go to HomeScreen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  userEmail: response['user']['email'],
                  token: token,
                ),
              ),
            );
          } else if (isFilled && !isApproved) {
            // Account pending approval → Show message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(approvalResponse['message']),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (!isFilled && isApproved) {
            // Account pending approval → Show message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(approvalResponse['message']),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (!isFilled && !isApproved) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => FinalRegistrationScreen(token: token),
              ),
            );
          }
        } else {
          // Handle login failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Login failed.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle exception during login
        print('Error during login: $e'); // Print the error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
