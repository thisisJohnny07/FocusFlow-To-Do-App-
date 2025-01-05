import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'list_task.dart';
import 'login.dart';
import 'overdue_task.dart';
import 'task_list.dart';
import '../../data/user_dao.dart';

class Nav extends StatefulWidget {
  const Nav({Key? key}) : super(key: key);

  @override
  NavState createState() => NavState();
}

class NavState extends State<Nav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TaskList(),
    const ListTask(),
    const Overdue(),
  ];

  @override
  Widget build(BuildContext context) {
    final userDao = Provider.of<UserDao>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                userDao.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_busy),
            label: 'Overdue',
          ),
        ],
        selectedItemColor: const Color.fromARGB(255, 133, 180, 117),
      ),
    );
  }
}
