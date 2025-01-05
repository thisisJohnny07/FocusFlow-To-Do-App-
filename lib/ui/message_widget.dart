// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatefulWidget {
  final String message;
  final DateTime date;
  final TimeOfDay? time;
  final String? category;
  final Color color;

  const MessageWidget(
    this.message,
    this.date,
    this.time,
    this.category,
    this.color, {
    Key? key,
  }) : super(key: key);

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  late bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    if (isChecked) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            height: 82,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[350]!,
                  blurRadius: 2.0,
                  offset: const Offset(0, 1.0),
                )
              ],
              borderRadius: BorderRadius.circular(10.0),
              color: widget.color,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.category ?? '',
                          style: const TextStyle(
                            fontSize: 15.5,
                          ),
                        ),
                        Text(
                          'Due: ${_formatDate(widget.date)} ${_formatTime(widget.time)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false; // Update isChecked value
                      print(isChecked);
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay? timeOfDay) {
    if (timeOfDay != null) {
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      return DateFormat.jm().format(dateTime);
    } else {
      return '';
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('E, MMM d, yyyy').format(date);
    } catch (e) {
      return '';
    }
  }
}
