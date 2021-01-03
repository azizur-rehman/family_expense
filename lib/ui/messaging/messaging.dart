import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/ui/auth/JoinFamilyWidget.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_2.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_3.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_7.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_8.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagingWidget extends StatelessWidget {

  // final ScrollController _listController = ScrollController();
  final String uid = FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser.uid : null;


  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: getPrefValue(uid),
      builder: (context, familyId){


        if(familyId.connectionState == ConnectionState.waiting)
          return SizedBox();


        if(!familyId.hasData || familyId.data.toString().isEmpty){
          return getPlaceholderWidget('You haven\'t joined any family yet\nTap to Join', onTap: () => moveToPage(context, JoinOrCreateFamilyWidget()), svgAsset: 'people.svg');
        }


        return FutureBuilder<QuerySnapshot>(
          future: familyMemberRef.where('uid', isEqualTo: uid).where(key_familyId, isEqualTo:familyId.data).get(),
          builder: (context, snapshot){

            if(snapshot.connectionState == ConnectionState.waiting)
              return circularProgressBar;

            if(!snapshot.hasData && snapshot.data.docs.isEmpty){
              return getPlaceholderWidget('You haven\'t joined any family yet\nTap to Join', svgAsset: 'people.svg');
            }


            if(snapshot.data.docs.first.get('verified') == false){
              return getPlaceholderWidget('Please wait while someone verifies you...');

            }

            return delayedWidget(1, _bindMessages(familyId.data));
          },
        );
      },
    );
  }

  Widget _bindMessages(String familyId){
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: messagingRef.where(key_familyId, isEqualTo: familyId).orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot){

              if(snapshot.connectionState == ConnectionState.waiting)
                return circularProgressBar;

              if(!snapshot.hasData || snapshot.hasError)
                return getPlaceholderWidget('No Messages here',  svgAsset: "chats.svg", height: 120);

              print(snapshot.data.docs);
              print('----Binding Messages---');
              List<MessageModel> messages = snapshot.data.docs.map((e) => MessageModel.fromJson(e.data())).toList();

              return ListView.builder(
                // controller: _listController,
                  reverse: true,
                  itemCount: messages.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    MessageModel message = messages[index];
                    bool isMine = message.sentBy == uid ;

                    return  Column(
                      children: [
                        ChatBubble(
                          clipper: ChatBubbleClipper1(type: isMine ? BubbleType.sendBubble : BubbleType.receiverBubble),
                          alignment: isMine ? Alignment.topRight : Alignment.topLeft,
                          margin: EdgeInsets.only(top: 2,),
                          backGroundColor: isMine ? Colors.blue : Colors.grey[200],
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            child: Column(
                              children: [
                                !isMine ? loadName(message.sentBy,  Theme.of(context).textTheme.caption.copyWith(color: Colors.redAccent,)) : SizedBox(),
                                SizedBox(height: 1,),
                                Text(message.message, style: GoogleFonts.raleway().copyWith(color: isMine ? Colors.white : Colors.black, fontSize: 16),),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(alignment: isMine ? Alignment.topRight : Alignment.topLeft,
                            child: Text(formatDateWithFormatter(message.timestamp, 'd MMM yy hh:mm a'), style: Theme.of(context).textTheme.caption.copyWith(fontSize: 9, ),),margin: EdgeInsets.only(left: 20, right: 20, bottom: 8 ),)

                      ],
                    );



                  });
            },
          ),
        ),

        Divider(height: 4), _messageInputLayout()
        //message input layout
      ],
    );
  }

}

class _messageInputLayout extends StatefulWidget {

  final ScrollController listController;
  _messageInputLayout({Key key, this.listController}):super(key: key);

  @override
  __messageInputLayoutState createState() => __messageInputLayoutState();
}

class __messageInputLayoutState extends State<_messageInputLayout> {
  final String uid = FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser.uid : null;

  String familyId ;
  @override
  void initState() {
    super.initState();
    getPrefValue(uid).then((value) => familyId = value);

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildInput(),
    );
  }

  final _messagingController = TextEditingController();

  Widget buildInput() {

    return Container(
      margin: EdgeInsets.only(bottom: 20, left: 5, right: 5),
      child: Row(
        children: <Widget>[
          // Button send image
          // Material(
          //   child: Container(
          //     margin: EdgeInsets.symmetric(horizontal: 1.0),
          //     child: IconButton(
          //       icon: Icon(Icons.image),
          //       onPressed: getImage,
          //       color: primaryColor,
          //     ),
          //   ),
          //   color: Colors.white,
          // ),
          // Material(
          //   child: Container(
          //     margin: EdgeInsets.symmetric(horizontal: 1.0),
          //     child: IconButton(
          //       icon: Icon(Icons.face),
          //       onPressed: getSticker,
          //       color: primaryColor,
          //     ),
          //   ),
          //   color: Colors.white,
          // ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(_messagingController.text, 0, familyId);
                },
                style: GoogleFonts.raleway().copyWith(fontSize: 18),
                controller: _messagingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                // focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => onSendMessage(_messagingController.text, 0, familyId),
            color: Theme.of(context).accentColor,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          // border: Border(top: BorderSide(color: Colors.grey[200], width: 0.5)),
          // color: Colors.white
      ),
    );
  }

  void onSendMessage(String text, int i, String familyId) {


    // widget.listController.animateTo(
    //   0.0,
    //   curve: Curves.easeOut,
    //   duration: const Duration(milliseconds: 300),
    // );

    if(text.isEmpty){
      return;
    }

    //send Message
    messagingRef.add(
      MessageModel(sentBy: uid, timestamp: DateTime.now().millisecondsSinceEpoch, message: text, type: 'message', familyId: familyId)
      .toJson()
    );

    setState(() {
      _messagingController.text = "";
    });


  }

}

