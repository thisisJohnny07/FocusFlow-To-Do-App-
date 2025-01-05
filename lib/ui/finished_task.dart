// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import '../data/message.dart';
import '../data/message_dao.dart';
import 'package:provider/provider.dart';
import 'empty_task.dart';
import 'message_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinishedTask extends StatefulWidget {
  const FinishedTask({Key? key}) : super(key: key);

  @override
  FinishedTaskState createState() => FinishedTaskState();
}

class FinishedTaskState extends State<FinishedTask> {
  final ScrollController _scrollController = ScrollController();
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    final messageDao = Provider.of<MessageDao>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: messageDao.getMessageStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return _getMessageList(messageDao);
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
          return const Center(child: LinearProgressIndicator());
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
    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20.0),
      children:
          snapshot?.map((data) => _buildListItem(context, data)).toList() ?? [],
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final message = Message.fromSnapshot(snapshot);

    return MessageWidget(message.text, message.date, message.time,
        message.category, Colors.grey[200]!);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
