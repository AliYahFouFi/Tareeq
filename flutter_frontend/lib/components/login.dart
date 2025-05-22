import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/snackbar_helper.dart';
import 'package:flutter_frontend/pages/HomePage.dart';
import 'package:flutter_frontend/pages/QRCodeScreen.dart';
import 'package:flutter_frontend/pages/TwoFactorVerificationScreen.dart';
import 'package:flutter_frontend/providers/AuthProvider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoginMode = true;
  final List<String> roles = ['user', 'driver'];

  void _handleAuth(AuthProvider authProvider) async {
    bool success = await authProvider.login(
      emailController.text,
      passwordController.text,
      context,
    );

    if (success) {
      if (!authProvider.is2FAEnabled) {
        // New user needs to set up 2FA
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => QRCodeScreen(
                  qrCodeData: authProvider.qrCodeData,
                  token: authProvider.userToken,
                  secret: authProvider.secret,
                ),
          ),
        );
      } else {
        // Existing user with 2FA enabled - show verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    TwoFactorVerificationScreen(token: authProvider.userToken),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 20),
                          Image.asset('assets/logo.png', height: 100),
                          SizedBox(height: 30),
                          Text(
                            isLoginMode
                                ? 'Welcome to Tareeq'
                                : 'Create Account',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            isLoginMode
                                ? 'Sign in to continue your journey'
                                : 'Join Tareeq to start your journey',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 40),
                          if (!isLoginMode)
                            _buildTextField(
                              controller: nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                            ),
                          _buildTextField(
                            controller: emailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                          ),
                          _buildTextField(
                            controller: passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),
                          if (!isLoginMode)
                            _buildTextField(
                              controller: confirmPasswordController,
                              label: 'Confirm Password',
                              icon: Icons.lock_outline,
                              obscureText: true,
                            ),
                          // if (!isLoginMode)
                          // Container(
                          //   margin: EdgeInsets.only(bottom: 20),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white.withOpacity(0.1),
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child: Padding(
                          //     padding: EdgeInsets.symmetric(horizontal: 12),
                          //     child: DropdownButtonFormField<String>(
                          //       value: authProvider.selectedRole,
                          //       dropdownColor: Color(0xFF0D47A1),
                          //       style: TextStyle(color: Colors.white),
                          //       decoration: InputDecoration(
                          //         border: InputBorder.none,
                          //         labelText: "Select Role",
                          //         labelStyle: TextStyle(
                          //           color: Colors.white70,
                          //         ),
                          //         icon: Icon(
                          //           Icons.people_outline,
                          //           color: Colors.white70,
                          //         ),
                          //       ),
                          //       items:
                          //           roles.map((String role) {
                          //             return DropdownMenuItem<String>(
                          //               value: role,
                          //               child: Text(
                          //                 role.toUpperCase(),
                          //                 style: TextStyle(
                          //                   color: Colors.white,
                          //                 ),
                          //               ),
                          //             );
                          //           }).toList(),
                          //       onChanged: (newValue) {
                          //         authProvider.setSelectedRole(newValue!);
                          //       },
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Color(0xFF0D47A1),
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              if (isLoginMode) {
                                _handleAuth(authProvider);
                              } else {
                                if (passwordController.text !=
                                    confirmPasswordController.text) {
                                  CustomSnackBar.showError(
                                    context: context,
                                    message: 'Passwords do not match',
                                  );

                                  return;
                                }
                                authProvider.register(
                                  nameController.text,
                                  emailController.text,
                                  passwordController.text,
                                  context,
                                );
                              }
                            },
                            child: Text(
                              isLoginMode ? "SIGN IN" : "CREATE ACCOUNT",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                isLoginMode = !isLoginMode;
                                confirmPasswordController.clear();
                              });
                            },
                            child: Text(
                              isLoginMode
                                  ? "Don't have an account? SIGN UP"
                                  : "Already have an account? SIGN IN",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          // Add flexible space to push content up
                          Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}
