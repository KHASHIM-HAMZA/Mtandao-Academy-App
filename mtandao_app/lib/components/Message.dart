import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Message {
  final String sender;
  final String time;
  final String messagePreview;
  final Icon iconUrl;

  Message({
    required this.sender,
    required this.time,
    required this.messagePreview,
    required this.iconUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      time: json['time'],
      messagePreview: json['messagePreview'],
      iconUrl: json['iconUrl'],
    );
  }
}
