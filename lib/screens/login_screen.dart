import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final bool showSignupFirst;

  const LoginScreen({
    super.key,
    this.showSignupFirst = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSignup = false;

  String _password = '';

  @override
  void initState() {
    super.initState();

    _isSignup = widget.showSignupFirst;

    _passwordController.addListener(() {
      _password = _passwordController.text;

      if (_isSignup) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter valid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Minimum 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must contain uppercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must contain number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
        .hasMatch(value)) {
      return 'Must contain special character';
    }

    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

      if (_isSignup) {
        final success = await authProvider.signUp(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (success && mounted) {
          setState(() {
            _isSignup = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account created successfully! Please login.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
    } else {
      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pop(context, true);
      }
    }

    if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 14,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: theme.dividerColor,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// TOP SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 40,
                  left: 25,
                  right: 25,
                ),
                child: Column(
                  children: [

                    /// LOGO
                    Image.asset(
                      theme.brightness == Brightness.dark
                          ? 'assets/sg_white.png'
                          : 'assets/sg_black.png',
                      height: 70,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      _isSignup
                          ? 'Create Account'
                          : 'Welcome Back,',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _isSignup
                          ? 'Create your account'
                          : 'Sign in to continue',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),

              /// FORM CONTAINER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 25,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(42),
                    topRight: Radius.circular(42),
                  ),
                ),

                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        _isSignup ? 'Sign Up' : 'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// NAME
                      if (_isSignup) ...[
                        TextFormField(
                          controller: _nameController,
                          validator: _validateName,
                          decoration: _inputDecoration(
                            label: 'Full Name',
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],

                      /// EMAIL
                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          label: 'Username/Email',
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// PASSWORD
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        decoration: _inputDecoration(
                          label: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      /// PASSWORD REQUIREMENTS
                      if (_isSignup) ...[
                        const SizedBox(height: 8),

                        _PasswordRequirements(
                          password: _password,
                        ),

                        const SizedBox(height: 16),
                      ],

                      /// CONFIRM PASSWORD
                      if (_isSignup)
                        TextFormField(
                          controller:
                              _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          validator:
                              _validateConfirmPassword,
                          decoration: _inputDecoration(
                            label: 'Confirm Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm =
                                      !_obscureConfirm;
                                });
                              },
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      /// FORGOT PASSWORD
                      if (!_isSignup)
                        Align(
                          alignment:
                              Alignment.centerRight,
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      /// BUTTON
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  auth.isLoading
                                      ? null
                                      : _handleSubmit,
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    theme
                                        .colorScheme
                                        .primary,
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(10),
                                ),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isSignup
                                          ? 'Sign Up'
                                          : 'Login',
                                      style:
                                          GoogleFonts
                                              .poppins(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight
                                                .w500,
                                        color:
                                            Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      /// TOGGLE
                      Center(
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [

                            Text(
                              _isSignup
                                  ? 'Already have an account? '
                                  : 'Don\'t have an account? ',
                              style:
                                  GoogleFonts.poppins(
                                fontSize: 13,
                                color: theme
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSignup = !_isSignup;
                                });
                              },
                              child: Text(
                                _isSignup
                                    ? 'Login'
                                    : 'Register',
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: theme
                                      .colorScheme
                                      .primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirements extends StatelessWidget {
  final String password;

  const _PasswordRequirements({
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        _Requirement(
          text: 'Minimum 8 characters',
          met: password.length >= 8,
        ),

        _Requirement(
          text: 'One uppercase letter',
          met: RegExp(r'[A-Z]')
              .hasMatch(password),
        ),

        _Requirement(
          text: 'One number',
          met: RegExp(r'[0-9]')
              .hasMatch(password),
        ),

        _Requirement(
          text: 'One special character',
          met: RegExp(
            r'[!@#$%^&*(),.?":{}|<>]',
          ).hasMatch(password),
        ),
      ],
    );
  }
}

class _Requirement extends StatelessWidget {
  final String text;
  final bool met;

  const _Requirement({
    required this.text,
    required this.met,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 6,
      ),
      child: Row(
        children: [

          Icon(
            met
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 16,
            color: met
                ? Colors.green
                : Colors.grey,
          ),

          const SizedBox(width: 8),

          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: met
                  ? Colors.green
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}