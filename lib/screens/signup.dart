import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_field_validator/password_field_validator.dart';
import 'package:email_validator/email_validator.dart';
import '../db/discussion.dart';
import '../utilities/topic_management.dart';
import 'login.dart';
import '../db/auth_google.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        if (mounted) {
          showError(context, 'Passwords do not match');
        }
        return;
      }

      setState(() => _isLoading = true);

      bool isUsernameAvailable = await UserDBManager.checkUsernameAvailability(
          _usernameController.text.trim());
      if (!isUsernameAvailable) {
        setState(() => _isLoading = false);
        if (mounted) {
          showError(context, 'Username is already taken');
        }
        return;
      }

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCredential.user!
            .updateProfile(displayName: _usernameController.text.trim());

        await userCredential.user?.sendEmailVerification();

        if (mounted) {
          await _showEmailVerificationDialog(userCredential.user!);
        }

        await UserDBManager.createUser(userCredential.user!.uid,
            _usernameController.text.trim(), _emailController.text.trim());

        // Navigate to the main application after successful sign-up
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          showError(context, _getErrorMessage(e.code));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      UserCredential? userCredential = await GoogleAuthService.signIn();
      if (userCredential == null) {
        setState(() {
          _isLoading = true;
        });
      }

      final user = userCredential!.user;
      if (user != null) {
        final userDoc = await UserDBManager.getUser(user.uid);

        if (!userDoc.exists) {
          await UserDBManager.createUser(
              user.uid, user.displayName ?? '', user.email ?? '');
        }

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        showError(context, 'Google sign-up failed: ${e.code}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      default:
        if (kDebugMode) {
          print(code);
        }
        return 'Sign up failed';
    }
  }

  Future<void> _showEmailVerificationDialog(User user) async {
    if (!mounted) return; // Ensure the widget is still active
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Email Verification'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('A verification email has been sent to ${user.email}.'),
                Text('Please verify your email before logging in.'),
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
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                }
              },
            ),
          ],
        );
      },
    );
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
                      Text(
                        'Create Account',
                        style: GoogleFonts.roboto(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Join Discursia and start your language learning journey',
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
                          controller: _usernameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: TextStyle(color: Colors.white60),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.person, color: Colors.white70),
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
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
                          controller: _emailController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.white60),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.email, color: Colors.white70),
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
                          obscureText: _obscurePassword,
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
                              return 'Please enter a password';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Theme(
                          data: ThemeData(
                            textTheme: Typography.whiteRedmond,
                          ),
                          child: PasswordFieldValidator(
                            minLength: 8,
                            uppercaseCharCount: 1,
                            lowercaseCharCount: 2,
                            numericCharCount: 2,
                            specialCharCount: 1,
                            defaultColor: Colors.white54,
                            successColor: Colors.green,
                            failureColor: Colors.red.shade300,
                            controller: _passwordController,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(color: Colors.white60),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 24),
                      if (_isLoading)
                        Center(child: CircularProgressIndicator(color: Colors.white))
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF1a237e),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('Create Account'),
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
                              onPressed: _signUpWithGoogle,
                              icon: Icon(Icons.g_mobiledata),
                              label: Text('Sign up with Google'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white38),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              if (mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => LoginPage()),
                                );
                              }
                            },
                            child: Text(
                              'Log in',
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
