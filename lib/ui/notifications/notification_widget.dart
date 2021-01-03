import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:flutter/material.dart';

class NotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ralewayText('Notifications'),),
      body: Container(
        child: FutureBuilder(
          future: getPrefValue(uid),
          builder: (context, familySnapshot){

            if(familySnapshot.connectionState == ConnectionState.waiting)
              return circularProgressBar;

            Query myNotifications =  notificationRef.where('uid', isEqualTo: uid);

            print('Looking for -> ${myNotifications.parameters}');
            Query familyNotifications;
            if(familySnapshot.data != null ) {
              familyNotifications =
                  notificationRef.where('uid', isNotEqualTo: uid).where(
                      'familyId', isEqualTo: familySnapshot.data);
              print('Looking for -> ${familyNotifications.parameters}');
            }

            print(familySnapshot.error);
                //first get individual notifications
            return FutureBuilder<QuerySnapshot>(
              future: myNotifications.get(),
              builder: (context, myNotificationSnap){

                if(familySnapshot.connectionState == ConnectionState.waiting)
                  return circularProgressBar;



                List<NotificationData> myNotificationList = myNotificationSnap.hasData ? myNotificationSnap.data.docs.map((e) => NotificationData.fromJson(e.data())).toList() : [];

                if(familySnapshot.data == null)
                  return _bindList(myNotificationList);

                return StreamBuilder<QuerySnapshot>(
                  stream: familyNotifications.snapshots(),
                  builder: (context, familyNotificationSnap){

                    print(familyNotificationSnap.error);

                    if(familyNotificationSnap.connectionState == ConnectionState.waiting)
                      return circularProgressBar;

                    if(!familyNotificationSnap.hasData)
                      return _bindList(myNotificationList);

                    //merge both lists
                    List<NotificationData> familyNotificationList = familyNotificationSnap.data.docs.map((e) => NotificationData.fromJson(e.data())).toList();
                    List<NotificationData> allNotifications = new List.from(myNotificationList)..addAll(familyNotificationList);

                    return _bindList(allNotifications);


                  },
                );
              },
            );

          },
        ),
      ),
    );
  }

  Widget _bindList(List<NotificationData> list){

    if(list.isEmpty)
      return getPlaceholderWidget('No Notifications here',  svgAsset: "bell.svg");

    //set notification as read
    list.forEach((e) {
      try { notificationRef.doc(e.id).update({'read' : true}); }
      catch(e){ }
    });

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index){
        NotificationData notification = list[index];

        return Card(
          // color: notification.read == true ?  null : Colors.red[300]  ,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: circleAvatar('${index+1}'),
            title:  ralewayText(list[index].title, fontSize: 15),
            // subtitle: ralewayText(list[index].body == null ? '' : list[index].body == null, fontSize: 13),
            trailing: Text(formattedDate(list[index].createdAt), style: Theme.of(context).textTheme.caption.copyWith(fontSize: 12, ),),
          ),
        );
      },
    );
  }

}
