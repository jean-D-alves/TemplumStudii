import 'package:flutter/material.dart';
import 'package:templum_studdi/pages/home.page.dart';
import 'package:templum_studdi/widgets/signin.widget.dart';
import 'package:templum_studdi/widgets/signup.widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: _isSignUp
              ? SignUpForm(
                  onSuccess: _goToHome,
                  onSwitchToSignIn: () {
                    setState(() {
                      _isSignUp = false;
                    });
                  },
                )
              : SignInForm(
                  onSuccess: _goToHome,
                  onSwitchToSignUp: () {
                    setState(() {
                      _isSignUp = true;
                    });
                  },
                ),
        ),
      ),
    );
  }
}
