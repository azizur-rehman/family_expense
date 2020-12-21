import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/ui/auth/JoinFamilyWidget.dart';
import 'package:family_expense/ui/family/FamilyWidget.dart';
import 'package:family_expense/ui/profile/MyProfileWidget.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {

  GlobalKey<ScaffoldState> _scaffold = GlobalKey();
  var layoutIndex = 0;
  var familyId = "";


  List<Widget> _homeWidgets = [
    _dashboard, FamilyWidget(), MyProfileWidget()
  ];

  @override
  Widget build(BuildContext context) {
    //init family id
    getPref().then((pref) => familyId = pref.getString(uid));

    return Scaffold(
      key: _scaffold,
      // drawer: _drawer(),
      bottomNavigationBar: _bottomNavigationBar(),
      // appBar: _appBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomAddItemDialog();
        },
        child: Icon(Icons.add),
      ),

      body: SafeArea(
        child:  Container(
          margin: EdgeInsets.all(16),
          child: _homeWidgets[layoutIndex]

        ),
      ),
    );
  }


  static Widget _dashboard =  SingleChildScrollView(
    child: FutureBuilder<SharedPreferences>(
      future: getPref(),
      builder: (context,pref){
        if(!pref.hasData)
            return circularProgressBar;

          var familyId = pref.data.get(uid);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Hello ${currentUser.displayName}!',  style: GoogleFonts.raleway().copyWith(fontWeight: FontWeight.w300, fontSize: 20)),
            Text('How are you?', style: GoogleFonts.raleway().copyWith(fontWeight: FontWeight.bold, fontSize: 20),),

            SizedBox(height: 30,),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: SfCartesianChart(
                  enableAxisAnimation: true,
                  title: ChartTitle(text : 'Monthly Expenditure'),
                  primaryYAxis: NumericAxis(isVisible : false, anchorRangeToVisiblePoints: false),
                  primaryXAxis: CategoryAxis(),
                  // zoomPanBehavior: ZoomPanBehavior(
                  //   enablePinching: true
                  // ),

                  series: <ChartSeries>[
                    // Renders spline chart
                    SplineAreaSeries<SalesData, String>(
                      // color: Colors.blue,
                        gradient: LinearGradient(
                          // begin: Alignment.topLeft,
                          // end: Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
                          colors: [
                            Colors.blue[500],
                            Colors.blue[400],
                            Colors.blue[300]
                          ], // red to yellow// repeats the gradient over the canvas
                        ),
                        opacity: 0.8,
                        borderWidth: 3,
                        borderColor: Colors.blue,
                        dataSource: [
                          // Bind data source
                          SalesData('Jan', 45),
                          SalesData('Feb', 38),
                          SalesData('Mar', 34),
                          SalesData('Apr', 32),
                          SalesData('May', 40),
                          SalesData('June', 50),
                          SalesData('July', 40),
                          SalesData('Aug', 50),
                          SalesData('Sept', 55),
                          SalesData('Oct', 60),
                          SalesData('Nov', 30),
                          SalesData('Dec', 40)
                        ],
                        yValueMapper: (SalesData sales, _) => sales.expense ,
                        xValueMapper: (SalesData sales, num index) => sales.month
                    )
                  ]
              ),
            ),


            SizedBox(height: 20,),

            Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child:Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(height: 5,),
                      Text('Items added recently',  style: GoogleFonts.raleway().copyWith(fontWeight: FontWeight.w300, fontSize: 20)),
                      SizedBox(height: 15,),

                      StreamBuilder<QuerySnapshot>(stream: itemRef.orderBy('addedOn', descending: true).where('familyId', isEqualTo: familyId).limit(5)
                          .snapshots(),
                        builder: (context, snapshot){


                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return circularProgressBar;
                          }

                          if(snapshot.hasError || !snapshot.hasData)
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text('No Items were added', style: Theme.of(context).textTheme.caption,),
                            );

                          print('HomeWidget: items - ${snapshot.data.docs}, familyId - $familyId');
                          print(snapshot);
                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {

                              Item item = Item.fromJson(snapshot.data.docs[index].data());

                              return ListTile(
                                leading: CircleAvatar(child: Text((index+1).toString(),style: GoogleFonts.roboto().copyWith(color: Colors.white),), backgroundColor: Colors.green,),
                                title: Text(item.itemName),
                                subtitle: loadName(item.addedBy),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('₹ '),
                                    Text(item.itemPrice.toString(), style: GoogleFonts.raleway().copyWith(fontWeight: FontWeight.w300, fontSize: 24),),
                                  ],
                                ),
                              );
                            },
                            itemCount: snapshot.data.size,

                          );
                        },),


                      Divider(height: 1,color: Colors.grey,),

                      ListTile(
                        title: Text('See More'),
                        trailing: Icon(Icons.arrow_right_alt_outlined, size: 40, color: Colors.blue,),
                      )

                    ],
                  ),
                )
            ),

            SizedBox(height: 40,)

          ],
        );
      },
    ),
  );



  BottomNavigationBar _bottomNavigationBar(){
    return BottomNavigationBar(
      currentIndex: layoutIndex,
      onTap: _onTapped,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Home'),

        BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Family'),

        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Me')

      ],
    );
  }

  void _onTapped(int index){
    setState(() {
      layoutIndex = index;
    });
  }


  void showBottomAddItemDialog(){
    var isInserting = false;
    TextEditingController _nameController = TextEditingController();
    TextEditingController _priceController = TextEditingController();


    showModalBottomSheet<void>(context: _scaffold.currentContext, builder: (BuildContext context) {

      var purchaseDate = DateTime.now().millisecondsSinceEpoch;

      return FutureBuilder<QuerySnapshot>(
        future: familyMemberRef.where("uid", isEqualTo: uid).where("familyId", isEqualTo: familyId).where('verified', isEqualTo: true).get(),
        builder: (context, snapshot){

          if(snapshot.connectionState == ConnectionState.waiting)
            return circularProgressBar;

          if(!snapshot.hasData || snapshot.hasError)
            return textMessage('You are not allowed to add items. Contact the moderator');

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical : 20.0),
                child: Text('Add your item!', style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w400),),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  autofocus: true,
                  controller: _nameController,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle().copyWith(fontSize: 26, fontWeight: FontWeight.w500 ),
                  decoration: InputDecoration(
                      labelText: "What would you like to add?",
                      labelStyle: TextStyle(fontWeight: FontWeight.w300,  fontSize: 22, ),
                      hintText: "Name of the Item",
                      border: InputBorder.none,
                      hintStyle: TextStyle().copyWith(fontSize: 26, fontWeight: FontWeight.w300, color: Colors.grey[400])
                  ),
                ),
              ),

              SizedBox(height: 30,),

              Row(
                children: [

                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _priceController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        style: TextStyle().copyWith(fontSize: 26, fontWeight: FontWeight.w500 ),
                        decoration: InputDecoration(
                            labelText: "Enter its Price",
                            labelStyle: TextStyle(fontWeight: FontWeight.w300,  fontSize: 22, ),
                            hintText: "Price",
                            border: InputBorder.none,
                            hintStyle: TextStyle().copyWith(fontSize: 26, fontWeight: FontWeight.w300, color: Colors.grey[400])
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 20),

                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                      height: 50,
                      // width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Color(0xFFE5E5E5),
                        ),
                      ),
                      child:  Row(
                        children: [
                          Text('Today', style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w300),),
                          Icon(Icons.arrow_drop_down_sharp)
                          // SvgPicture.asset("assets/icons/dropdown.svg")
                          // SvgPicture.asset("assets/icons/dropdown.svg", height: 40,),

                        ],
                      ),
                    ),
                    onTap: (){
                      //show date picker
                    },
                  )
                ],
              ),


              SizedBox(height: 50,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    color: Colors.grey[200],
                    padding: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                    child: Text('Cancel', style: TextStyle().copyWith(fontSize: 22, color: Colors.black, fontWeight: FontWeight.w400),),

                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  ),

                  SizedBox(width: 20,),

                  MaterialButton(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    color: Colors.grey[200],
                    padding: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                    child: Text('Add Item', style: TextStyle().copyWith(fontSize: 22, color: Colors.black, fontWeight: FontWeight.w400),),

                    onPressed: (){
                      if(isInserting)
                        return;

                      if(familyId.isEmpty){
                        Navigator.popUntil(context, ModalRoute.withName('/'),);

                        Navigator.push(context, MaterialPageRoute(builder: (builder)=>JoinOrCreateFamilyWidget()));
                        Fluttertoast.showToast(msg: "You have not joined any family yet.");
                      }

                      if(_nameController.text.isEmpty || _priceController.text.isEmpty){
                        showSnackBar(context, "All fields required");
                        return;
                      }

                      //insert item
                      String itemId = "Item_${DateTime.now().millisecondsSinceEpoch}";
                      var time = DateTime.now().millisecondsSinceEpoch;

                      Item item = Item(itemId: itemId, familyId: familyId, addedOn: time, updatedOn: time,
                          itemPrice: int.parse(_priceController.text) , addedBy: uid, purchaseDate: purchaseDate,itemName: _nameController.text);

                      itemRef.doc(itemId).set(item.toJson())
                          .then((value)  {
                        showSnackBar(context, "Item Added");
                        Navigator.of(context).pop();

                      });

                    },
                  ),
                ],
              ),
            ],
          );
        }
      );

    });
  }
}

class SalesData {

  SalesData(this.month, this.expense);
  final String month;
  final double expense;
}
