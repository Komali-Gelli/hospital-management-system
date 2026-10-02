import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_screen.dart';
import 'dashboard_screen.dart' as dashboard;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  // ============================================================
  // LOAD REMEMBERED EMAIL
  // ============================================================

  Future<void> _loadRememberedEmail() async {
    final prefs =
    await SharedPreferences.getInstance();

    final savedEmail =
    prefs.getString('saved_email');

    final rememberMe =
        prefs.getBool('remember_me') ?? false;

    if (!mounted) return;

    setState(() {
      if (rememberMe && savedEmail != null) {
        _emailController.text = savedEmail;
      }

      _rememberMe = rememberMe;
    });
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email =
      _emailController.text.trim();

      final password =
          _passwordController.text;

      // Firebase Authentication
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Remember Me
      final prefs =
      await SharedPreferences.getInstance();

      if (_rememberMe) {
        await prefs.setString(
          'saved_email',
          email,
        );

        await prefs.setBool(
          'remember_me',
          true,
        );
      } else {
        await prefs.remove('saved_email');

        await prefs.setBool(
          'remember_me',
          false,
        );
      }

      if (!mounted) return;

      // ========================================================
      // GO TO DASHBOARD
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const dashboard.DashboardScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message =
          'Login failed. Please try again.';

      if (e.code == 'user-not-found') {
        message =
        'No account found with this email.';
      } else if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message =
        'Incorrect email or password.';
      } else if (e.code == 'invalid-email') {
        message =
        'Please enter a valid email address.';
      } else if (e.code == 'user-disabled') {
        message =
        'This account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        message =
        'Too many login attempts. Please try again later.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> _forgotPassword() async {
    final email =
    _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email first.',
          ),
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid email address.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset link sent to your email.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message =
          'Unable to send reset email.';

      if (e.code == 'user-not-found') {
        message =
        'No account found with this email.';
      } else if (e.code == 'invalid-email') {
        message =
        'Please enter a valid email address.';
      } else if (e.code == 'too-many-requests') {
        message =
        'Too many requests. Please try again later.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const RegisterScreen(),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 30,
            ),

            child: Container(
              width: double.infinity,

              constraints: const BoxConstraints(
                maxWidth: 500,
              ),

              padding: const EdgeInsets.all(28),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    // ==================================================
                    // HOSPITAL LOGO
                    // ==================================================

                    Center(
                      child: Container(
                        width: 80,
                        height: 80,

                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFE8F2FF),
                          borderRadius:
                          BorderRadius.circular(18),
                        ),

                        child: const Icon(
                          Icons.local_hospital,
                          size: 48,
                          color:
                          Color(0xFF0969D8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // HOSPITAL NAME
                    // ==================================================

                    const Center(
                      child: Text(
                        'MediCare Hospital',

                        textAlign:
                        TextAlign.center,

                        style: TextStyle(
                          fontSize: 25,
                          fontWeight:
                          FontWeight.bold,
                          color:
                          Color(0xFF0969D8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Center(
                      child: Text(
                        'Hospital Management System',

                        textAlign:
                        TextAlign.center,

                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ==================================================
                    // LOGIN
                    // ==================================================

                    const Text(
                      'Login',

                      style: TextStyle(
                        fontSize: 26,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Sign in to continue to your account',

                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // EMAIL
                    // ==================================================

                    const Text(
                      'Email',

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller:
                      _emailController,

                      keyboardType:
                      TextInputType.emailAddress,

                      decoration:
                      InputDecoration(
                        hintText:
                        'Enter your email',

                        prefixIcon:
                        const Icon(
                          Icons.email_outlined,
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(7),
                        ),
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // PASSWORD
                    // ==================================================

                    const Text(
                      'Password',

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller:
                      _passwordController,

                      obscureText:
                      _obscurePassword,

                      decoration:
                      InputDecoration(
                        hintText:
                        'Enter your password',

                        prefixIcon:
                        const Icon(
                          Icons.lock_outline,
                        ),

                        suffixIcon:
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                              !_obscurePassword;
                            });
                          },

                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                .visibility_off_outlined
                                : Icons
                                .visibility_outlined,
                          ),
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(7),
                        ),
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter your password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // REMEMBER ME / FORGOT PASSWORD
                    // ==================================================

                    Row(
                      children: [

                        Checkbox(
                          value: _rememberMe,

                          onChanged: (value) {
                            setState(() {
                              _rememberMe =
                                  value ?? false;
                            });
                          },
                        ),

                        const Text(
                          'Remember me',

                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),

                        const Spacer(),

                        TextButton(
                          onPressed:
                          _forgotPassword,

                          child: const Text(
                            'Forgot Password?',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // LOGIN BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(
                        onPressed:
                        _isLoading
                            ? null
                            : _login,

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(
                            0xFF0969D8,
                          ),

                          foregroundColor:
                          Colors.white,

                          elevation: 0,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(7),
                          ),
                        ),

                        child: _isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,

                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color:
                            Colors.white,
                          ),
                        )
                            : const Text(
                          'LOGIN',

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // OR
                    // ==================================================

                    Row(
                      children: [

                        const Expanded(
                          child: Divider(),
                        ),

                        Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),

                          child: Text(
                            'or',

                            style: TextStyle(
                              color:
                              Colors.grey.shade600,
                            ),
                          ),
                        ),

                        const Expanded(
                          child: Divider(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // REGISTER BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 48,

                      child: OutlinedButton(
                        onPressed:
                        _openRegister,

                        style:
                        OutlinedButton.styleFrom(
                          foregroundColor:
                          const Color(
                            0xFF0969D8,
                          ),

                          side:
                          const BorderSide(
                            color:
                            Color(0xFF0969D8),
                          ),

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(7),
                          ),
                        ),

                        child: const Text(
                          'REGISTER',

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}