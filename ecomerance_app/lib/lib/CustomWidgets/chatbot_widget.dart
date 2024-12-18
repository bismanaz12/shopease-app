import 'package:ecomerance_app/AppColors/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../model/chat_model.dart';
class ChatMessageWidget extends StatelessWidget {
  final ChatMessage chatMessage;
  final ChatController controller = Get.find();
  final ValueNotifier<bool> _isLongPressed = ValueNotifier<bool>(false);
  ChatMessageWidget(this.chatMessage);
  void _deleteMessage() {
    controller.deleteMessage(chatMessage.id);
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLongPressed,
      builder: (context, isLongPressed, child) {
        return GestureDetector(
          onLongPress: () {
            _isLongPressed.value = true;
            Future.delayed(Duration(milliseconds: 100), () {
              _isLongPressed.value = false;
              _deleteMessage();
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: isLongPressed ? Colors.grey.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: chatMessage.type ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!chatMessage.type)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(child: Text('B')),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: chatMessage.type ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (chatMessage.type)
                        Text(chatMessage.name, style: Theme.of(context).textTheme.titleSmall),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(top: 5.0),
                        decoration: BoxDecoration(
                          color: chatMessage.type ? AppColors.primary : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          chatMessage.text,
                          style: TextStyle(color: chatMessage.type ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                if (chatMessage.type)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CircleAvatar(
                      child: Text(chatMessage.name[0], style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
