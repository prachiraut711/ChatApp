import 'package:chat_app/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for storing self information
  static late ChatUser me;

  //for checking if user exits or not?
  static Future<bool> userExists()async {
    return (await firestore.collection("users").doc(auth.currentUser!.uid).get()).exists;
  }

   //for getting user info
  static Future<void> getSelfInfo()async {
    await firestore.collection("users").doc(user.uid).get().then((user) async{

      if(user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static User get user => auth.currentUser!;

  //for creating a new user
  static Future<void> createUser()async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      id: user.uid, 
      lastActive: time, 
      image: user.photoURL.toString(), 
      email: user.email.toString(), 
      name: user.displayName.toString(), 
      pushToken: "",
      createdAt: time, 
      isOnline: false, 
      about: "Hey, I'm using We Chat!"
      );
      
    return await firestore.collection("users").doc(user.uid).set(chatUser.toJson());
  }
  
  //for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore.collection("users").where("id", isNotEqualTo: user.uid).snapshots();
  }
  
  //for updating user information
  static Future<void> updateUserInfo()async {
    await firestore.collection("users").doc(user.uid).update({"name" : me.name, "about" : me.about});
  }

  /// ******** Chat Screen Related APIs *******

  //For getting all messages of a specific converstion from firestore database
   static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages() {
    return firestore.collection("messages").snapshots();
  }

}



