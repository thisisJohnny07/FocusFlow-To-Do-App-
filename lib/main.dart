// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'ui/lanning.dart';
import 'ui/nav.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '../data/message_dao.dart';
import '../data/user_dao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserDao>(
          lazy: false,
          create: (_) => UserDao(),
        ),
        Provider<MessageDao>(
          lazy: false,
          create: (_) => MessageDao(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FocusFlow',
        theme: ThemeData(primaryColor: const Color.fromARGB(255, 22, 73, 31)),
        // 1
        home: Consumer<UserDao>(
          // 2
          builder: (
            context,
            userDao,
            child,
          ) {
            // 3
            if (userDao.isLoggedIn()) {
              return const Nav();
            } else {
              return const Lanning();
            }
          },
        ),
      ),
    );
  }
}
