import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth.dart' as auth;
import 'package:googleapis_auth/auth_io.dart' as auth_io;
import '../model/chat_model.dart';

class ChatController extends GetxController {
  var messages = <ChatMessage>[].obs;
  final TextEditingController textController = TextEditingController();
  final firestore.FirebaseFirestore firestoreInstance =
      firestore.FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  void loadMessages() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      final snapshot = await firestoreInstance
          .collection('chat_messages')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp')
          .get();
      final messageList = snapshot.docs
          .map(
              (doc) => ChatMessage.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      messages.assignAll(messageList);
    } catch (e) {
      if (e is firestore.FirebaseException && e.code == 'failed-precondition') {
        print('Index creation required: ${e.message}');
      } else {
        print('Error loading messages: $e');
      }
    }
  }

  Future<void> addMessage(ChatMessage message) async {
    await firestoreInstance
        .collection('chat_messages')
        .doc(message.id)
        .set(message.toJson());
    messages.add(message);
  }

  Future<void> deleteMessage(String id) async {
    await firestoreInstance.collection('chat_messages').doc(id).delete();
    messages.removeWhere((msg) => msg.id == id);
  }

  Future<void> handleSubmitted(String text) async {
    textController.clear();
    final id = Uuid().v4();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final timestamp = DateTime.now();
    final message = ChatMessage(
      id: id,
      text: text,
      name: "You",
      type: true,
      userId: userId,
      timestamp: timestamp,
    );

    await addMessage(message);
    try {
      final fulfillmentText = await getDialogflowResponse(text);
      if (fulfillmentText.isNotEmpty) {
        final botMessage = ChatMessage(
          id: Uuid().v4(),
          text: fulfillmentText,
          name: "Bot",
          type: false,
          userId: userId,
          timestamp: DateTime.now(),
        );
        await addMessage(botMessage);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String> getDialogflowResponse(String text) async {
    final String credentialsJson =
        await rootBundle.loadString('assets/credentials.json');
    final credentials = json.decode(credentialsJson);

    final accountCredentials =
        auth.ServiceAccountCredentials.fromJson(credentials);
    const scopes = ['https://www.googleapis.com/auth/cloud-platform'];

    final client =
        await auth_io.clientViaServiceAccount(accountCredentials, scopes);
    final projectId = 'chatbot-kyan';
    var uuid = Uuid();
    String sessionId = uuid.v4();
    final apiEndpoint =
        'https://dialogflow.googleapis.com/v2/projects/$projectId/agent/sessions/$sessionId:detectIntent';

    final response = await client.post(
      Uri.parse(apiEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'queryInput': {
          'text': {
            'text': text,
            'languageCode': 'en-US',
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['queryResult']['fulfillmentText'] ?? '';
    } else {
      print(
          'Failed to get response from Dialogflow. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to get response from Dialogflow');
    }
  }
}
