import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<Message> _list = [];
  
  //for handling message text chages
  final _textController = TextEditingController();
  
  // for storing value of showing or hiding emoji
  bool _showEmoji = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
          if(_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
              
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: Color.fromARGB(255, 234, 248, 255),
                
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
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
                        if (data != null && data.isNotEmpty) {
                          log("Data: ${jsonEncode(data[0].data())}");
                          _list = data.map((e) => Message.fromJson(e.data())).toList();
                        } else {
                          _list = [];
                        }
                        
                        if(_list.isNotEmpty) {
                          return ListView.builder(
                            itemCount:_list.length,
                            padding: EdgeInsets.only(top: mq.height * 0.02),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(message: _list[index],);
                          });
                        } else {
                          return const Center(child: Text("Say hi!👋", style: TextStyle(fontSize: 20),));
                        }
                      }
                    }, 
                  ),
                ),
                _chatInput(),
            
                
                _showEmoji
                  ? SizedBox(
                      height: mq.height * .35,
                      child: EmojiPicker(
                        textEditingController: _textController,
                        onEmojiSelected: (category, emoji) {
                          _textController
                            ..text += emoji.emoji
                            ..selection = TextSelection.fromPosition(
                              TextPosition(offset: _textController.text.length),
                            );
                        },
                        onBackspacePressed: () {
                          final text = _textController.text;
                          if (text.isNotEmpty) {
                            _textController.text = text.substring(0, text.length - 1);
                            _textController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _textController.text.length),
                            );
                          }
                        },
                        config: Config(
                          height: 300,
                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(
                            emojiSizeMax:
                                28 * (Platform.isIOS ? 1.20 : 1.0),
                          ),
                          viewOrderConfig: const ViewOrderConfig(
                            top: EmojiPickerItem.categoryBar,
                            middle: EmojiPickerItem.emojiView,
                            bottom: EmojiPickerItem.searchBar,
                          ),
                          skinToneConfig: const SkinToneConfig(),
                          categoryViewConfig: const CategoryViewConfig(),
                          bottomActionBarConfig: const BottomActionBarConfig(),
                          searchViewConfig: const SearchViewConfig(),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
                
                
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _appBar() {
  return InkWell(
    onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)));
    },
    child: StreamBuilder(
      stream: APIs.getUserInfo(widget.user), 
      builder: (context, snapshot) {
        final data = snapshot.data?.docs;
        final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

        return Row(
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
              imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
              errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person),),
            ),
          ),
    
        SizedBox(width: 10),
    
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(list.isNotEmpty ? list[0].name : widget.user.name, style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),),
            SizedBox(height: 2),
            Text(
              list.isNotEmpty 
              ? list[0].isOnline
                ? "Online"
                : MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
              : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive), 
              style: TextStyle(fontSize: 13, color: Colors.black54),
            )
          ]),
      ],
    );
    })
  );
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
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() =>
                      _showEmoji = !_showEmoji);
                  }, 
                  icon:Icon(Icons.emoji_emotions, color: Colors.blueAccent, size: 26,)
                ),
            
                Expanded(
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if(_showEmoji) {
                        setState(() {
                        _showEmoji = !_showEmoji;
                      });
                      }
                    },
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
          onPressed: () {
            if(_textController.text.isNotEmpty) {
              APIs.sendMessage(widget.user, _textController.text);
              _textController.text = "";
            }
          },
          minWidth: 0,
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
          shape: CircleBorder(),
          color: Colors.green,
          child: Icon(Icons.send, color: Colors.white, size: 28),)
      ],
    ),
  );
}
}