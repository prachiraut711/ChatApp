import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),

        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
              stream: APIs.getAllMessages(),
              builder: (context, snapshot) {
                switch(snapshot.connectionState) {
                  //if data loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());
                      
                   //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                  
                  final data = snapshot.data?.docs;
                  log("Data: ${jsonEncode(data![0].data())}");
                  // _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
              
                  final _list = ["hi", "hello"];
                
                  if(_list.isNotEmpty) {
                    return ListView.builder(
                      itemCount:_list.length,
                      padding: EdgeInsets.only(top: mq.height * 0.02),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Text("Message: ${_list[index]}");
                    });
                  } else {
                    return const Center(child: Text("Say hi!👋", style: TextStyle(fontSize: 20),));
                  }
                }
              }, 
                        ),
            ),
            _chatInput(),
          ],
        ),
      ),
    );
  }

Widget _appBar() {
  return InkWell(
    onTap: (){},
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context), 
          icon:Icon(Icons.arrow_back, color: Colors.black87,
        )),
    
        ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .3),
            child: CachedNetworkImage(
              width: mq.height * .05,
              height: mq.height * .05,
              imageUrl: widget.user.image,
              errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person),),
            ),
          ),
    
        SizedBox(width: 10),
    
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.user.name, style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),),
            SizedBox(height: 2),
            Text("Last seen not available", style: TextStyle(fontSize: 13, color: Colors.black54),)
          ]),
      ],
    ),
  );
}
}

Widget _chatInput(){
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: mq.width * .05, vertical: mq.height * .01),
    child: Row(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                //emoji button
                IconButton(
                  onPressed: () {}, 
                  icon:Icon(Icons.emoji_emotions, color: Colors.blueAccent, size: 26,)
                ),
            
                Expanded(child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Type Something...",
                    hintStyle: TextStyle(color: Colors.blueAccent),
                    border: InputBorder.none
                  ),
                )),
            
                IconButton(
                  onPressed: () {}, 
                  icon:Icon(Icons.image, color: Colors.blueAccent, size: 25,)
                ),
            
                IconButton(
                  onPressed: () {}, 
                  icon:Icon(Icons.camera_alt_rounded, color: Colors.blueAccent, size: 26,)
                ),

                SizedBox(width: mq.width * .02,)
            
              ],
            ),
          ),
        ),
    
        //send message button
        MaterialButton(
          onPressed: () {},
          minWidth: 0,
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
          shape: CircleBorder(),
          color: Colors.green,
          child: Icon(Icons.send, color: Colors.white, size: 28),)
      ],
    ),
  );
}