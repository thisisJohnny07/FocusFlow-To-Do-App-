// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import '../data/message.dart';
import '../data/message_dao.dart';
import 'package:provider/provider.dart';
import 'empty_task.dart';
import 'message_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  TaskListState createState() => TaskListState();
}

class TaskListState extends State<TaskList> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final messageDao = Provider.of<MessageDao>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: messageDao.getMessageStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final messages = snapshot.data!.docs
                  .map((doc) => Message.fromSnapshot(doc))
                  .toList();
              final overdueTasks =
                  messages.where((message) => _isTaskOverdue(message)).toList();

              if (overdueTasks.length == messages.length) {
                return const EmptyTask();
              } else {
                return _getMessageList(messageDao);
              }
            } else {
              return const EmptyTask();
            }
          },
        ),
      ),
    );
  }

  Widget _getMessageList(MessageDao messageDao) {
    return StreamBuilder<QuerySnapshot>(
      stream: messageDao.getMessageStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildList(context, snapshot.data!.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot) {
    // 1. Sort the snapshot data based on date and time
    snapshot?.sort((a, b) {
      final messageA = Message.fromSnapshot(a);
      final messageB = Message.fromSnapshot(b);
      final dateTimeA = DateTime(
        messageA.date.year,
        messageA.date.month,
        messageA.date.day,
        messageA.time.hour,
        messageA.time.minute,
      );
      final dateTimeB = DateTime(
        messageB.date.year,
        messageB.date.month,
        messageB.date.day,
        messageB.time.hour,
        messageB.time.minute,
      );
      return dateTimeA.compareTo(dateTimeB);
    });

    // 2. Build the list of task widgets
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));
    final nextMonth = DateTime(today.year, today.month + 1);

    final taskWidgets = snapshot
        ?.map((data) => _buildListItem(context, Message.fromSnapshot(data),
            today, tomorrow, nextWeek, nextMonth))
        .whereType<Widget>()
        .toList();

    // 3. Add labels for tasks assigned today and tomorrow
    final labeledTaskWidgets =
        _addTaskLabels(taskWidgets!, today, tomorrow, nextWeek, nextMonth);

    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20.0),
      children: labeledTaskWidgets,
    );
  }

  Widget? _buildListItem(
    BuildContext context,
    Message message,
    DateTime today,
    DateTime tomorrow,
    DateTime nextWeek,
    DateTime nextMonth,
  ) {
    if (_isTaskOverdue(message)) {
      return null; // Skip rendering the widget if the task is overdue or the checkbox is checked
    }

    final messageWidget = MessageWidget(
      message.text,
      message.date,
      message.time,
      message.category,
      Colors.green[50]!,
    );

    if (messageWidget.runtimeType == SizedBox.shrink().runtimeType) {
      print('object');
      return null; // Skip rendering the widget if the messageWidget is equivalent to SizedBox.shrink()
    }

    return messageWidget;
  }

  List<Widget> _addTaskLabels(List<Widget> taskWidgets, DateTime today,
      DateTime tomorrow, DateTime nextWeek, DateTime nextMonth) {
    final labeledTaskWidgets = <Widget>[];

    final todayTasks = taskWidgets.where((widget) {
      if (widget is MessageWidget) {
        final taskDate = widget.date;
        return _isTaskAssignedToday(taskDate, today);
      }
      return false;
    }).toList();

    final tomorrowTasks = taskWidgets.where((widget) {
      if (widget is MessageWidget) {
        final taskDate = widget.date;
        return _isTaskAssignedTomorrow(taskDate, tomorrow);
      }
      return false;
    }).toList();

    final thisWeekTasks = taskWidgets.where((widget) {
      if (widget is MessageWidget) {
        final taskDate = widget.date;
        return _isTaskAssignedThisWeek(taskDate, today, tomorrow);
      }
      return false;
    }).toList();

    final nextWeekTasks = taskWidgets.where((widget) {
      if (widget is MessageWidget) {
        final taskDate = widget.date;
        return _isTaskAssignedNextWeek(taskDate, nextWeek);
      }
      return false;
    }).toList();

    final thisMonthTasks = taskWidgets.where((widget) {
      if (widget is MessageWidget) {
        final taskDate = widget.date;
        return _isTaskAssignedThisMonth(taskDate, today, tomorrow);
      }
      return false;
    }).toList();

    final nextMonthTasks = taskWidgets.where((widget) {
      if (widget is MessageWidget) {
        final taskDate = widget.date;
        return _isTaskAssignedNextMonth(taskDate, nextMonth);
      }
      return false;
    }).toList();

    final laterTasks = taskWidgets.where((widget) {
      if (widget is MessageWidget) {
        final taskDate = widget.date;
        return _isTaskAssignedLater(taskDate, today, tomorrow);
      }
      return false;
    }).toList();

    if (todayTasks.isNotEmpty) {
      labeledTaskWidgets.add(_buildTaskLabel('Today'));
      labeledTaskWidgets.addAll(todayTasks);
    }

    if (tomorrowTasks.isNotEmpty) {
      labeledTaskWidgets.add(_buildTaskLabel('Tomorrow'));
      labeledTaskWidgets.addAll(tomorrowTasks);
    }

    if (thisWeekTasks.isNotEmpty) {
      labeledTaskWidgets.add(_buildTaskLabel('This Week'));
      labeledTaskWidgets.addAll(thisWeekTasks);
    }

    if (nextWeekTasks.isNotEmpty) {
      labeledTaskWidgets.add(_buildTaskLabel('Next Week'));
      labeledTaskWidgets.addAll(nextWeekTasks);
    }

    if (thisMonthTasks.isNotEmpty) {
      labeledTaskWidgets.add(_buildTaskLabel('This Month'));
      labeledTaskWidgets.addAll(thisMonthTasks);
    }

    if (nextMonthTasks.isNotEmpty) {
      labeledTaskWidgets.add(_buildTaskLabel('Next Month'));
      labeledTaskWidgets.addAll(nextMonthTasks);
    }

    if (laterTasks.isNotEmpty) {
      labeledTaskWidgets.add(_buildTaskLabel('Later'));
      labeledTaskWidgets.addAll(laterTasks);
    }

    return labeledTaskWidgets;
  }

  bool _isTaskAssignedToday(DateTime taskDate, DateTime today) {
    return taskDate.year == today.year &&
        taskDate.month == today.month &&
        taskDate.day == today.day;
  }

  bool _isTaskAssignedTomorrow(DateTime taskDate, DateTime tomorrow) {
    final tomorrowDate = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
    );

    return taskDate.year == tomorrowDate.year &&
        taskDate.month == tomorrowDate.month &&
        taskDate.day == tomorrowDate.day;
  }

  bool _isTaskAssignedThisWeek(
      DateTime taskDate, DateTime today, DateTime tomorrow) {
    final weekStart =
        DateTime(today.year, today.month, today.day - today.weekday + 1);
    final weekEnd = weekStart.add(const Duration(days: 6));

    return taskDate.isAfter(weekStart) &&
        taskDate.isBefore(weekEnd) &&
        !_isTaskAssignedToday(taskDate, today) &&
        !_isTaskAssignedTomorrow(taskDate, tomorrow);
  }

  bool _isTaskAssignedNextWeek(DateTime taskDate, DateTime nextWeek) {
    final nextWeekDate = DateTime(
      nextWeek.year,
      nextWeek.month,
      nextWeek.day,
    );
    return taskDate.year == nextWeekDate.year &&
        taskDate.month == nextWeekDate.month &&
        taskDate.day >= nextWeekDate.day &&
        taskDate.day < nextWeekDate.day + 7;
  }

  bool _isTaskAssignedThisMonth(
      DateTime taskDate, DateTime today, DateTime tomorrow) {
    final monthStart = DateTime(today.year, today.month);
    final monthEnd = DateTime(today.year, today.month + 1, 0);

    return taskDate.isAfter(monthStart) &&
        taskDate.isBefore(monthEnd) &&
        !_isTaskAssignedToday(taskDate, today) &&
        !_isTaskAssignedTomorrow(taskDate, tomorrow) &&
        !_isTaskAssignedThisWeek(taskDate, today, tomorrow) &&
        !_isTaskAssignedNextWeek(taskDate, today.add(const Duration(days: 7)));
  }

  bool _isTaskAssignedNextMonth(DateTime taskDate, DateTime nextMonth) {
    final nextMonthDate = DateTime(
      nextMonth.year,
      nextMonth.month,
      nextMonth.day,
    );
    final nextMonthEndDate = DateTime(
      nextMonthDate.year,
      nextMonthDate.month + 1,
      0,
    );
    return taskDate.year == nextMonthDate.year &&
        taskDate.month == nextMonthDate.month &&
        taskDate.day >= nextMonthDate.day &&
        taskDate.day <= nextMonthEndDate.day;
  }

  bool _isTaskAssignedLater(
      DateTime taskDate, DateTime today, DateTime tomorrow) {
    final nextMonth = DateTime(today.year, today.month + 1);
    final monthEnd = DateTime(nextMonth.year, nextMonth.month + 1, 0);

    return taskDate.isAfter(monthEnd) &&
        !_isTaskAssignedToday(taskDate, today) &&
        !_isTaskAssignedTomorrow(taskDate, tomorrow) &&
        !_isTaskAssignedThisWeek(taskDate, today, tomorrow) &&
        !_isTaskAssignedNextWeek(taskDate, today.add(const Duration(days: 7)));
  }

  Widget _buildTaskLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 133, 180, 117)),
      ),
    );
  }

  bool _isTaskOverdue(Message message) {
    final currentTime = DateTime.now();
    final messageTime = DateTime(
      message.date.year,
      message.date.month,
      message.date.day,
      message.time.hour,
      message.time.minute,
    );
    if (messageTime.isBefore(currentTime)) {
      return true;
    }
    return false;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
