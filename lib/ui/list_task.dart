import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/message.dart';
import '../data/message_dao.dart';
import '../data/user_dao.dart';
import 'package:intl/intl.dart';
import 'nav.dart';

class ListTask extends StatefulWidget {
  const ListTask({Key? key}) : super(key: key);

  @override
  ListTaskState createState() => ListTaskState();
}

class ListTaskState extends State<ListTask> {
  final TextEditingController _messageController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  final categories = <String>['Personal', 'Home', 'School', 'Others'];
  String? selectedCategory;
  TimeOfDay _timeOfDay = TimeOfDay.now();
  String? email;

  @override
  Widget build(BuildContext context) {
    final messageDao = Provider.of<MessageDao>(context, listen: false);
    final userDao = Provider.of<UserDao>(context, listen: false);
    email = userDao.email();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: const Color.fromARGB(255, 133, 180, 117),
                    ),
                    // Change the background color
                    padding: const EdgeInsets.all(16.0), // Add padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          controller: _messageController,
                          onSubmitted: (input) {
                            _sendMessage(messageDao);
                          },
                          decoration:
                              const InputDecoration(hintText: 'new task'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: buildDateField(context),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: buildTimeField(context),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Text(
                      'Category',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  InkWell(
                    onTap: () {
                      if (_canSendMessage()) {
                        _sendMessage(messageDao);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Nav()),
                        );
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2.0,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 133, 180, 117),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            _canSendMessage()
                                ? CupertinoIcons.arrow_right_circle_fill
                                : CupertinoIcons.arrow_right_circle,
                            color: Color.fromARGB(255, 133, 180, 117),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage(MessageDao messageDao) {
    if (_canSendMessage()) {
      final message = Message(
        text: _messageController.text,
        date: _dueDate,
        time: _timeOfDay,
        category: selectedCategory,
        email: email,
      );
      messageDao.saveMessage(message);
      _messageController.clear();
      setState(() {});
    }
  }

  bool _canSendMessage() => _messageController.text.isNotEmpty;

  Widget buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextButton(
              child: const Text(
                'Select',
                style: TextStyle(color: Color.fromARGB(255, 133, 180, 117)),
              ),
              onPressed: () async {
                final currentDate = DateTime.now();
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: currentDate,
                  firstDate: currentDate,
                  lastDate: DateTime(currentDate.year + 5),
                );
                setState(() {
                  if (selectedDate != null) {
                    _dueDate = selectedDate;
                  }
                });
              },
            ),
          ],
        ),
        Text(DateFormat('yyyy-MM-dd').format(_dueDate)),
      ],
    );
  }

  Widget buildTimeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Time',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextButton(
              child: const Text(
                'Select',
                style: TextStyle(color: Color.fromARGB(255, 133, 180, 117)),
              ),
              onPressed: () async {
                // 1
                final timeOfDay = await showTimePicker(
                  // 2
                  initialTime: TimeOfDay.now(),
                  context: context,
                );
                // 3
                setState(() {
                  if (timeOfDay != null) {
                    _timeOfDay = timeOfDay;
                  }
                });
              },
            ),
          ],
        ),
        Text(_timeOfDay.format(context)),
      ],
    );
  }
}
