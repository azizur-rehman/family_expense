import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class SharingPercentWidget extends StatefulWidget {

  final List<FamilyMember> members;
  SharingPercentWidget({Key? key, required this.members}):super(key: key);

  @override
  _SharingPercentWidgetState createState() => _SharingPercentWidgetState();
}

class _SharingPercentWidgetState extends State<SharingPercentWidget> {

  Map sharingPercent = Map<String, num>();

  @override
  void initState() {
    super.initState();
    //add dummy members
    // for(int i = 0; i < 3; i++){
    // widget.members.add(FamilyMember(uid: "uid $i"));
    //
    // }

    widget.members.forEach((element) {
      sharingPercent[element.uid] = element.sharePercent;
    });
  }

  @override
  Widget build(BuildContext context) {

    num totalPercent = 0.0;
    sharingPercent.forEach((key, value) {
      totalPercent += value;
    });
    num averagePercent = (totalPercent/sharingPercent.length).roundToDouble();

    return Scaffold(
      appBar: AppBar(title: ralewayText('Adjust Sharing Percentage'),),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(

            children: [

              SizedBox(height: 20,),
              ralewayText('Total Percentage : $totalPercent %'),
              SizedBox(height: 5,),
              totalPercent != 100.0 ? Text('Must be 100%', style: TextStyle(color: Colors.red),) : SizedBox(),

              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index){
                  FamilyMember member = widget.members[index];
                  double? sharing = double.tryParse(sharingPercent[member.uid].toString());
                  return Column(
                    children: [
                      SizedBox(height: 40,),
                      FlutterSlider(
                        values: [sharing == null ? 0.0 : sharing],
                        max: 100,
                        min: 0,
                        onDragging: (handlerIndex, value, upperValue) {
                          // _lowerValue = lowerValue;
                          // _upperValue = upperValue;


                          // print('$lowerValue - $upperValue');
                          setState(() {
                            double percent = double.parse(value.toString());
                            sharingPercent[member.uid] = percent;
                            //set average for other members
                            var remainingValue = 100.0 - percent;
                            // List otherMemberUids = sharingPercent?.keys?.where((e) => e != member.uid.toString()).toList()??[];
                            double averageRemainingValue = remainingValue / (sharingPercent.keys.length - 1);
                            print('Average - $averageRemainingValue , remaining percent - $remainingValue, member - ${sharingPercent.length - 1}');
                            // otherMemberUids.forEach((id) {
                            //   // sharingPercent[id] = num.parse(averageRemainingValue.toString());
                            // });

                          });
                        },
                      ),
                      ralewayText('${member.name} :   ${sharingPercent[member.uid]}%'),
                    ],
                  );
                },
                itemCount: widget.members.length,
              ),

              SizedBox(height: 50,),

              MaterialButton(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                color: Colors.grey[200],
                padding: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                child: Text('Update', style: TextStyle().copyWith(fontSize: 22, color: Colors.black, fontWeight: FontWeight.w400),),

                onPressed: (){

                  if(totalPercent != 100.0 ) {
                    showSnackBar(context, 'Must be 100%');
                    return;
                  }
                  //update
                  // showProgressSnack(context, 'Updating');
                  widget.members.forEach((element) async{
                    await familyMemberRef.doc(element.uid).update({'sharePercent':sharingPercent[element.uid]});
                  });
                  Navigator.pop(context);
                  // hideSnackBar(context);
                  showSnackBar(context, 'Updated');

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
