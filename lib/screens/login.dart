import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import '../db/auth_google.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
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
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Verification email sent')),
                  );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login',
                  style: GoogleFonts.roboto(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Discover, discuss, and improve your language skills with Discursia – '
                  'where every conversation takes you closer to fluency!',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Add color for better customization
                    height: 1.5, // Add line height for better readability
                  ),
                  textAlign: TextAlign
                      .center, // Center-align the text for a cleaner look
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email validation
                    if (!EmailValidator.validate(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text('Login'),
                      ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  icon: Icon(Icons.g_mobiledata),
                  label: Text('Sign in with Google'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SignUpPage()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Create an Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
