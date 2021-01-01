import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/utils/Utils.dart';
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

  final ScrollController _listController = ScrollController();

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: getPrefValue(uid),
            builder: (context, familySnapshot){

              if(familySnapshot.connectionState == ConnectionState.waiting)
                return circularProgressBar;

              print(familySnapshot.error);

              if(familySnapshot.hasData){
                String familyId = familySnapshot.data.toString();
                return StreamBuilder<QuerySnapshot>(
                  stream: messagingRef.where(key_familyId, isEqualTo: familyId).orderBy('timestamp', descending: true).snapshots(),
                  builder: (context, snapshot){

                    if(snapshot.connectionState == ConnectionState.waiting)
                      return circularProgressBar;

                    if(!snapshot.hasData || snapshot.hasError)
                      return _bindList([]);

                    print(snapshot.data.docs);
                    List<MessageModel> messages = snapshot.data.docs.map((e) => MessageModel.fromJson(e.data())).toList();

                    return ListView.builder(
                      controller: _listController,
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
                              margin: EdgeInsets.only(top: 20),
                              backGroundColor: isMine ? Colors.blue : Colors.grey[200],
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                child: Text(message.message, style: GoogleFonts.raleway().copyWith(color: isMine ? Colors.white : Colors.black, fontSize: 18),),
                              ),
                            ),
                                SizedBox(height: 8),
                                Container(alignment: isMine ? Alignment.topRight : Alignment.topLeft, child: Text(formatDateWithFormatter(message.timestamp, 'd MMM yy hh:mm a'), style: Theme.of(context).textTheme.caption.copyWith(fontSize: 9, ),))

                          ],
                        );



                    });
                  },
                );

              }
              return _bindList([]);


            },
          ),
        ),

        Divider(height: 4),

        _messageInputLayout(listController: _listController,)
        //message input layout
      ],
    );
  }

  Widget _bindList(List<NotificationData> list){

    if(list.isEmpty)
      return getPlaceholderWidget('No Messages here',  svgAsset: "chat.svg", height: 240);

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index){
        return ListTile(
          leading: ralewayText(list[index].title),
          trailing: textMessage(formattedDate(list[index].createdAt)),
        );
      },
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

  String familyId ;
  @override
  void initState() {
    // TODO: implement initState
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
    widget.listController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
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

