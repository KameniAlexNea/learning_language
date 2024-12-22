import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import '../db/auth_google.dart';
import '../utilities/topic_management.dart';
import 'home.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Check if email is verified
        if (!userCredential.user!.emailVerified) {
          if (mounted) {
            await _showEmailVerificationDialog(userCredential.user!);
          }
        } else {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => WritingAssistantApp()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Login failed';
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled.';
            break;
          default:
            errorMessage = 'Login failed';
            if (kDebugMode) {
              print(e.code);
            }
        }

        if (mounted) {
          showError(context, errorMessage);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showEmailVerificationDialog(User user) async {
    if (!mounted) {
      return; // Prevent showing the dialog if the widget is unmounted
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Email Verification'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your email is not verified.'),
                Text('Please check your email for a verification link.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Resend Verification'),
              onPressed: () async {
                await user.sendEmailVerification();
                if (mounted) {
                  Navigator.of(this.context).pop();
                  showSuccess(this.context, 'Verification email sent');
                }
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if (mounted) Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      GoogleAuthService.signIn();
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WritingAssistantApp()),
        );
      }
    } catch (e) {
      if (mounted) {
        showError(context, 'Google Sign-In failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a237e), // Dark blue
              Color(0xFF000000), // Black
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Welcome back, discursian',
                        style: GoogleFonts.roboto(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Discover, discuss, and improve your language skills with Discursia',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.white60),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon:
                                Icon(Icons.email, color: Colors.white70),
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!EmailValidator.validate(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText:
                              _obscurePassword, // Add this variable to your state
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.white60),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 24),
                      _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF1a237e),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('Login'),
                            ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white38)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white38)),
                        ],
                      ),
                      SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: Icon(Icons.g_mobiledata),
                        label: Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white38),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              if (mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => SignUpPage()),
                                );
                              }
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
