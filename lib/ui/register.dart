import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/user_dao.dart';
import 'login.dart';
import 'nav.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);
  @override
  State createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // 1
  final _emailController = TextEditingController();
  // 2
  final _passwordController = TextEditingController();

  // 3
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    // 4
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1
    final userDao = Provider.of<UserDao>(context, listen: false);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          // 3
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                const Center(
                  child: Text(
                    'Create New\nAccount',
                    style: TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    const SizedBox(height: 80),
                    Expanded(
                      // 1
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: 'Email Address',
                        ),
                        autofocus: false,
                        // 2
                        keyboardType: TextInputType.emailAddress,
                        // 3
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        // 4
                        controller: _emailController,
                        // 5
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Email Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: 'Password'),
                        autofocus: false,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        controller: _passwordController,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Password Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Stay Focused, Flow Through Your Tasks:\n'
                    'Experience Productivity with FocusFlow!',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: ElevatedButton(
                        // 3
                        onPressed: () async {
                          final errorMessage = await userDao.signup(
                            _emailController.text,
                            _passwordController.text,
                          );
                          if (errorMessage != null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                duration: const Duration(milliseconds: 700),
                              ),
                            );
                          } else {
                            // Registration successful, navigate to login page
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Nav()),
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 133, 180, 117)),
                        ),
                        child: const Text('Sign Up'),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: ElevatedButton(
                        // 3
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
