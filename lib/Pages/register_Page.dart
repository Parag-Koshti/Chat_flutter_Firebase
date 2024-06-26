import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat/services/auth/auth_service.dart';
import 'package:chat/Components/button.dart';
import 'package:chat/Components/textfield.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({Key? key, this.onTap}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();

  String? emailError;
  String? usernameError;
  String? passwordError;
  String? confirmPasswordError;

  void signup() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          confirmPasswordError = "Passwords do not match!";
        });
        return;
      }
      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        await authService.signUpWithEmailandPassword(
          emailController.text,
          passwordController.text,
          usernameController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password not match ! '),
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
    // You can add more sophisticated email validation here if needed
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    // You can add more sophisticated username validation here if needed
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    // You can add more sophisticated password validation here if needed
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    // Check if password matches
    if (passwordController.text != confirmPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025),
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage("assets/men8.png"),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.035),
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
                      controller: usernameController,
                      hintText: "Username",
                      obscureText: false,
                      validator: validateUsername,
                      errorText: usernameError,
                      onChanged: (value) {
                        setState(() {
                          usernameError = validateUsername(value);
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
                        height: MediaQuery.of(context).size.height * 0.015),
                    MyTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      obscureText: true,
                      validator: validateConfirmPassword,
                      errorText: confirmPasswordError,
                      onChanged: (value) {
                        setState(() {
                          confirmPasswordError = validateConfirmPassword(value);
                        });
                      },
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025),
                    Button(
                      text: "Sign Up",
                      onTap: signup,
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Already a member?"),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.005),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Login now",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
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
