import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/services/auth/auth_service.dart'; // Assuming you have this service set up
import 'package:chat/Components/button.dart';
import 'package:chat/Components/textfield.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  LoginPage({Key? key, this.onTap}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? emailError;
  String? passwordError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      try {
        await authService.signInWithEmailandPassword(
          emailController.text,
          passwordController.text,
        );
        // Navigate to next screen upon successful login if needed
      } catch (e) {
        String errorMessage =
            "Error occurred, please try again."; // Default error message
        if (e is FirebaseAuthException) {
          errorMessage = e.message ?? "An error occurred.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage("assets/men1.png"),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                    MyTextField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                      validator: validateEmail,
                      errorText: emailError,
                      onChanged: (value) {
                        setState(() {
                          emailError = validateEmail(value);
                        });
                      },
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                    MyTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                      validator: validatePassword,
                      errorText: passwordError,
                      onChanged: (value) {
                        setState(() {
                          passwordError = validatePassword(value);
                        });
                      },
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025),
                    Button(
                      text: "Sign In",
                      onTap: signin,
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Not a member?"),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Register here",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
