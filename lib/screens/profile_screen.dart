import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile Screen"),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async{
              Dialogs.showProgressBar(context);

              await APIs.updateActiveStatus(false);

              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //for hiding progress dialog
                  Navigator.pop(context);
                  //for moving to home screen 
                  Navigator.pop(context);

                  APIs.auth = FirebaseAuth.instance;

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              });
          }, 
          icon: const Icon(Icons.logout),
          label: Text("Logout"),
          ),
        ),
      
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * .03),
                  //User profile picture
                  Stack(
                    children: [
                      //profile picture
                      _image != null 
                      ?
                      //loacal image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .1),
                        child: Image.file(
                          File(_image!),
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                        ),
                      ) 
                      :
                      //image from server
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .1),
                        child: CachedNetworkImage(
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person),),
                        ),
                      ),
                      //Add edit button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: (){
                            _showBottomSheet();
                          }, 
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: Icon(Icons.edit, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: mq.width, height: mq.height * .03),
                    
                  Text(widget.user.email, style: TextStyle(color: Colors.black54, fontSize: 16)),
                    
                  SizedBox(width: mq.width, height: mq.height * .05),
                    
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? "",
                    validator: (val) => val != null && val.isNotEmpty ? null : "Requried Field",
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.blue,),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: "eg Ravi Kumar", 
                      label: Text("Name") 
                    ),
                  ),
                    
                  SizedBox(width: mq.width, height: mq.height * .03),
                    
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? "",
                    validator: (val) => val != null && val.isNotEmpty ? null : "Requried Field",
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.info_outline, color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: "eg Feeling Happy", 
                      label: Text("About") 
                    ),
                  ),
                  SizedBox(width: mq.width, height: mq.height * .05),
                    
                  // update profile screen
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(shape: StadiumBorder(), fixedSize: Size(mq.width * .4, mq.height * .056)),
                    onPressed: () {
                      if(_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(context, "profile updated sucessfully");
                        });
                        log("inside validator");
                      }
                    }, 
                    icon: Icon(Icons.edit, size: 28,), 
                    label: Text("UPDATE", style: TextStyle(fontSize: 16),),
                  )
                ],
              ),
            ),
          ),
        )
      ),
    );
  }

  //Bottom sheet for picking a profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text("Pick Profile Picture", textAlign: TextAlign.center,style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),

              SizedBox(height: mq.height * .02),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * .15)
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      //pick an image
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if(image != null) {
                        log("image path : ${image.path} -- MimeType: ${image.mimeType} ");
                        setState(() {
                          _image = image.path;
                        });
                        // for hiding bottom sheet
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    }, 
                    child: Image.asset("images/add_image.png")),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: CircleBorder(),
                        fixedSize: Size(mq.width * .3, mq.height * .15)
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                      //pick an image
                      final XFile? image = await picker.pickImage(source: ImageSource.camera);
                      if(image != null) {
                        log("image path : ${image.path}");
                        setState(() {
                          _image = image.path;
                        });
                        // for hiding bottom sheet
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                      }, 
                      child: Image.asset("images/image.png"))
                ],
              )
            ],
          ),
        );
    });
  }
}