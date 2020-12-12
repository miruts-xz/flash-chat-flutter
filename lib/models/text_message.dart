import 'package:cloud_firestore/cloud_firestore.dart';

class TextMessage {
  final String text;
  final String senderId;
  final Timestamp timestamp;

  TextMessage({this.text, this.senderId, this.timestamp});

  Map<String, dynamic> toJson() => {
        'text': this.text,
        'sender': this.senderId,
        'timestamp': this.timestamp,
      };

  factory TextMessage.fromDoc(DocumentSnapshot doc) => TextMessage(
        text: doc.data()['text'],
        senderId: doc.data()['sender'],
        timestamp: doc.data()['timestamp'],
      );
}
