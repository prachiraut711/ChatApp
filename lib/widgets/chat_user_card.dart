import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  //last message info(if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0.5,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user,)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessages(widget.user),
          builder: (context, snapshot) {

            final data = snapshot.data?.docs;
            if(data != null && data.first.exists) {
              _message = Message.fromJson(data.first.data());
            }
                    
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .3),
                child: CachedNetworkImage(
                  width: mq.height * .055,
                  height: mq.height * .055,
                  imageUrl: widget.user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person),),
                ),
              ),
              title: Text(widget.user.name),
              
              subtitle: Text(_message != null ? _message!.msg : widget.user.about, maxLines: 1,),

              trailing: _message == null 
               ? null  //show nothing when no message is sent
               :
              _message!.read.isEmpty && _message!.fromid != APIs.user.uid
               ? 
               //show for unread message
               Container(
                  width: 15, 
                  height: 15, 
                  decoration: BoxDecoration(color: Colors.greenAccent.shade400, borderRadius: BorderRadius.circular(10)),
                  )
               : 
               //message sent time
               Text(MyDateUtil.getLastMessageTime(context: context, time: _message!.sent), style: TextStyle(color: Colors.black54),)
            );
        })
      ),
    );
  }
}