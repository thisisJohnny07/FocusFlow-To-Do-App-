import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String text;
  final DateTime date;
  final TimeOfDay time;
  final String? category;
  final String? email;

  Message({
    required this.text,
    required this.date,
    required this.time,
    this.category,
    this.email,
  });

  factory Message.fromJson(Map<dynamic, dynamic> json) {
    final timeString = json['time'] as String?;
    final time = timeString != null
        ? _parseTimeOfDay(timeString)
        : const TimeOfDay(hour: 0, minute: 0);

    return Message(
      text: json['text'] as String,
      date: DateTime.parse(json['date'] as String),
      time: time,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'date': date.toString(),
        'time': _formatTimeOfDay(time),
        'category': category,
        'email': email,
      };

  factory Message.fromSnapshot(DocumentSnapshot snapshot) {
    final message = Message.fromJson(snapshot.data() as Map<String, dynamic>);
    return message;
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
