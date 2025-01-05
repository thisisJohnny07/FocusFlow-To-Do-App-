import 'package:flutter/material.dart';
import 'login.dart';

class Lanning extends StatelessWidget {
  const Lanning({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
                child: Image.asset(
              'images/logo.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            )),
          ),
          GestureDetector(
            onTap: () {
              final route = PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const Login(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                            reverseCurve: Curves.easeInOut)),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 700),
              );
              Navigator.of(context).push(route);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Color.fromARGB(255, 133, 180, 117),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
