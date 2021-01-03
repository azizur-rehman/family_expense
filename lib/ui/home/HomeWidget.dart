

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/ui/auth/JoinFamilyWidget.dart';
import 'file:///D:/Flutter/projects/FamilyExpense/family_expense/lib/ui/items/AddItemDialogWidget.dart';
import 'package:family_expense/ui/family/FamilyWidget.dart';
import 'package:family_expense/ui/family/payments_widget.dart';
import 'package:family_expense/ui/family/sharing_percentage.dart';
import 'package:family_expense/ui/home/AddPaymentWidget.dart';
import 'package:family_expense/ui/items/ViewItemsWidget.dart';
import 'package:family_expense/ui/messaging/messaging.dart';
import 'package:family_expense/ui/notifications/notification_widget.dart';
import 'package:family_expense/ui/profile/MyProfileWidget.dart';
import 'package:family_expense/utils/MonthPicker.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


import 'package:family_expense/utils/extensions/Extensions.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();

}

class _HomeWidgetState extends State<HomeWidget> {


  GlobalKey<ScaffoldState> _scaffold = GlobalKey();
  var layoutIndex = 0;
  var familyId = "";
  var isUserVerified = false;
  static final String uid = FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser.uid : null;


  List<Widget> _homeWidgets = [
    _dashboard, FamilyWidget(), MessagingWidget(), MyProfileWidget()
  ];

  List<String> _titles = ['Dashboard', 'My Family', 'Messages', 'My Profile'];

  @override
  void initState() {
    super.initState();
    try {
      FirebaseAuth.instance.currentUser.reload().then((value) => print('Home - ${currentUser}'));
      // print('User name')
    }
    catch(e){ }
  }

  @override
  Widget build(BuildContext context) {
    //init family id
    getPref().then((pref) => familyId = pref.getString(uid));

    return Scaffold(
      key: _scaffold,
      // extendBody: true,
      // drawer: _drawer(),
      appBar: AppBar(title: Text(_titles[layoutIndex], style: GoogleFonts.raleway().copyWith(color: Theme.of(context).accentColor)), centerTitle: true,
        backgroundColor: Colors.transparent, elevation: 0.0,
        actions: [
          IconButton(icon: Icon(Icons.notifications),
          color:  getBlackWhiteColorWithTheme(context),
            onPressed: ()=>moveToPage(context, NotificationWidget()),
          )],),

      bottomNavigationBar: _bottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // appBar: _appBar(),
      floatingActionButton: Container(
        height: 65.0,
        width: 65.0,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            // splashColor: Colors.white,
            onPressed: () {
              if(isUserVerified)
                moveToPage(context, AddItemDialogWidget(familyId: familyId,));
              else
                showSnackBar(context, 'You can only add items as soon as you get verified');
            } ,
            child: Icon(Icons.add, color:Colors.white),
          ),
        ),
      ),

      body: SafeArea(
        child:  Container(
          margin: EdgeInsets.only(bottom: 16, left: 8, right: 8),
          child: _mainWidget()

        ),
      ),
    );
  }

  _mainWidget(){
    print('---Rendering main widget---');
    if(layoutIndex > 1 )
      return _homeWidgets[layoutIndex];

    return FutureBuilder(
      future: getPrefValue(uid),
      builder: (context, familyId){
        if(familyId.hasData)
          //check if family Id exists in a family
          return FutureBuilder<QuerySnapshot>(
              future: familyMemberRef.where('uid', isEqualTo: uid).where(key_familyId, isEqualTo:familyId.data).get(),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting)
                  return circularProgressBar;

                if(!snapshot.hasData && snapshot.data.docs.isEmpty){
                  return getPlaceholderWidget('You haven\'t joined any family yet\nTap to Join', svgAsset: 'people.svg');
                }


                if(snapshot.data.docs.first.get('verified') == false){
                  isUserVerified = false;
                  print('User - ${FirebaseAuth.instance.currentUser}');
                  return getPlaceholderWidget('Please wait while someone verifies you...');

                }

                isUserVerified = true;
                // print(snapshot.data.docs);
                  return delayedWidget(1, _homeWidgets[layoutIndex]);
              },

          );


        if(!familyId.hasData || familyId.data.toString().isEmpty){
          return getPlaceholderWidget('You haven\'t joined any family yet\nTap to Join', onTap: () => moveToPage(context, JoinOrCreateFamilyWidget()), svgAsset: 'people.svg');
        }
          return circularProgressBar;
      },
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
            Text('Hi, ${FirebaseAuth.instance.currentUser.displayName} 👋',  style: GoogleFonts.raleway().copyWith(fontWeight: FontWeight.w300, fontSize: 20)),
            Text('Welcome back!', style: GoogleFonts.raleway().copyWith(fontWeight: FontWeight.bold, fontSize: 20),),

            SizedBox(height: 30,),

           _DashboardChartWidget(familyId: familyId,),

            SizedBox(height: 20,),

            _pieChartCard(familyId),

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

                      StreamBuilder<QuerySnapshot>(stream: itemRef.orderBy('purchaseDate', descending: true).where('familyId', isEqualTo: familyId).limit(5)
                          .snapshots(),
                        builder: (context, snapshot){


                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return circularProgressBar;
                          }

                          if(snapshot.hasError || !snapshot.hasData || snapshot.data.size == 0)
                            return getPlaceholderWidget('No Items here', height: 80,  svgAsset: 'shopping-item.svg');
                            // return Padding(
                            //   padding: const EdgeInsets.all(20.0),
                            //   child: Text('No Items were added', style: Theme.of(context).textTheme.caption,),
                            // );

                          return Column(
                            children: [
                              ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {

                                  Item item = Item.fromJson(snapshot.data.docs[index].data());

                                  return bindPurchaseListItem(context, item, index, true);
                                },
                                itemCount: snapshot.data.size,

                              ),
                              Divider(height: 1,color: Colors.grey,),

                              ListTile(
                                title: Text('See More'),
                                trailing: Icon(Icons.arrow_right_alt_outlined, size: 36, ),
                                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewItemsWidget(familyId: familyId))),
                              )
                            ],
                          );
                        },),

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

  Widget _bottomBar(){
    num sizeSelected = 32.0;
    num sizeUnSelected = 28.0;

    return BottomAppBar(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: CircularNotchedRectangle(),
      notchMargin: 10,
      // color: Colors.white,
      child: Container(
        height: 60.0,
        child: Row(

          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: <Widget>[
            IconButton(
              iconSize: layoutIndex == 0? sizeSelected : sizeUnSelected,
              padding: EdgeInsets.only(left: 28.0),
              icon: Icon(Icons.dashboard_outlined),
              color: layoutIndex == 0? Theme.of(context).accentColor : null,
              onPressed: () => _onTapped(0),
            ),

            IconButton(
              iconSize: layoutIndex == 1? sizeSelected : sizeUnSelected,
              padding: EdgeInsets.only(right: 28.0),
              color: layoutIndex == 1? Theme.of(context).accentColor : null,
              icon: Icon(Icons.people_alt_outlined),
              onPressed: () => _onTapped(1),
            ),
            IconButton(
              iconSize: layoutIndex == 2? sizeSelected : sizeUnSelected,
              padding: EdgeInsets.only(left: 28.0),
              color: layoutIndex == 2? Theme.of(context).accentColor : null,
              icon: Icon(Icons.message_outlined),
              onPressed: () => _onTapped(2),
            ),
            IconButton(
              iconSize: layoutIndex == 3? sizeSelected : sizeUnSelected,
              color: layoutIndex == 3? Theme.of(context).accentColor : null,
              padding: EdgeInsets.only(right: 28.0),
              icon: Icon(Icons.person_outline_rounded),
              onPressed:() => _onTapped(3),
            )
          ],
        ),
        // color: Colors.pinkAccent,
      ),
    );
  }

  static Widget _pieChartCard(String familyId){

    return  Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            SizedBox(height: 20,),
            ralewayText('Balance'),
            StreamBuilder<DocumentSnapshot>(
              stream: familyExpenseRef.doc(familyId).snapshots(),
              builder:(context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting)
                  return circularProgressBar;

                if(!snapshot.hasData || snapshot.hasError || !snapshot.data.exists)
                  return getPlaceholderWidget('No Data here', height: 80, svgAsset: 'pie-chart.svg');

                num totalExpense = snapshot.data.exists ? snapshot.data.get(key_amount) : 0.0;
                num totalBalance = snapshot.data.exists ? snapshot.data.get(key_remaining) : 0;


                //now load members
                return FutureBuilder<QuerySnapshot>(
                  future: familyMemberRef.where(key_familyId, isEqualTo: familyId).where('verified', isEqualTo: true).get(),
                  builder: (context, memberSnapshot){

                    if(memberSnapshot.connectionState == ConnectionState.waiting)
                      return circularProgressBar;


                    if(!memberSnapshot.hasData || memberSnapshot.hasError)
                      return ralewayText('No Data here');


                    List<FamilyMember> memberList = memberSnapshot.data.docs.map((e) {
                          return FamilyMember.fromJson(e.data());
                    }).toList();

                    //uids

                    return StreamBuilder<QuerySnapshot>(
                      stream: familyPaymentsRef.where(key_familyId, isEqualTo: familyId)
                          // .where('uid', whereIn: memberList.map((e) => e.uid).toList())
                          .snapshots(),
                      builder: (context, paymentSnapshot){


                        if(paymentSnapshot.connectionState == ConnectionState.waiting)
                          return circularProgressBar;

                        // if(!snapshot.hasData || snapshot.hasError || !snapshot.data.exists)
                        //   return getPlaceholderWidget('No Data here', height: 80);

                        List<PaymentModel> payments = [];
                        Map maxCollection = Map<String,num>();
                        try{
                          payments = paymentSnapshot.data.docs.map((e) => PaymentModel.fromJson(e.data())).toList();
                        }catch(e){ }

                        num allPaymentsCollected = 0.0;
                        num myBalance = 0.0;

                        List<PieChartData> pieChartData = memberList.map((member) {
                          num userPayment = 0.0;

                          try{ userPayment = payments.where((e) => e.uid == member.uid).toList().sumBy((e) => e.amount);} catch(e){ }
                          print('${member.name} -> $userPayment');
                          num bal = ((totalExpense * (member.sharePercent/100)).roundToDouble()) - userPayment ;
                          allPaymentsCollected += userPayment;

                          maxCollection[member.uid] = bal;

                          return PieChartData('${member.name.capitalize()}', bal, randomColor());
                        }).toList() ;


                        return Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                child: SfCircularChart(
                                    margin: EdgeInsets.all(0),
                                    tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : ${getCurrency()} point.y'),
                                    // title: ChartTitle(text: 'Balance', textStyle: GoogleFonts.raleway()),
                                    enableMultiSelection: true,
                                    legend: Legend(isVisible: true, position: LegendPosition.auto, orientation: LegendItemOrientation.auto),

                                    series: <CircularSeries>[
                                      // Renders doughnut chart
                                      DoughnutSeries<PieChartData, String>(
                                          enableTooltip: true,
                                          dataSource: pieChartData,
                                          // pointColorMapper:(PieChartData data,  _) => data.color,
                                          xValueMapper: (PieChartData data, _) => data.x,
                                          yValueMapper: (PieChartData data, _) => data.y,
                                          explode: true,
                                          explodeAll: true
                                        // cornerStyle: CornerStyle.startCurve,
                                        // innerRadius: '50%',
                                        // radius: '50%'
                                      )
                                    ]
                                ),
                                height: 200,
                                // width: 240,
                                margin: EdgeInsets.only(bottom: 15, right: 4),
                              ),

                              ListTile(
                                leading: ralewayText('Total Spent', fontSize: 13),
                                trailing:  Text('${getCurrency()} ${totalExpense.roundToDouble()}', style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w300),),
                              ),

                              ListTile(
                                leading: ralewayText('Unpaid', fontSize: 13),
                                trailing:  Text('${getCurrency()} ${totalExpense - allPaymentsCollected}', style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w300),),
                              ),

                              memberList.any((e) => e.uid == uid && e.sharePercent > 0.0) ?
                              ListTile(
                                leading: ralewayText('My Balance',),
                                trailing:  Text('${getCurrency()} ${maxCollection[uid]}', style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),),
                              ) : SizedBox(),

                              Divider(),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    OutlineButton.icon(
                                      label: ralewayText('Add Payments', fontSize: 14),
                                      onPressed: ()=>  memberList.any((e) => e.moderator && e.uid == uid) ? moveToPage(context, AddPaymentWidget(familyId: familyId, members: memberList, maxCollection: maxCollection,)) : showSnackBar(context, 'You are not authorized to add payments'),
                                      icon: Icon(Icons.addchart_rounded, ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25),),
                                    ),
                                    OutlineButton.icon(
                                      label: ralewayText('View Payments', fontSize: 14),
                                      onPressed: ()=>  memberList.any((e) => e.moderator && e.uid == uid) ? moveToPage(context, PaymentsWidget()) : showSnackBar(context, 'You are not authorized to view payments'),
                                      icon: Icon(Icons.payments_outlined, ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25),),
                                    ),
                                  ],
                                ),
                              ),


                            ]
                        );
                      },
                    );
                  },
                );

              },
            ),
          ],
        )
    );
  }

   void _onTapped(int index){
     setState(() {
       layoutIndex = index;
     });
   }


 }

 class _DashboardChartWidget extends StatefulWidget {

  final String familyId;
  _DashboardChartWidget({Key key, this.familyId}):super(key: key);

   @override
   __DashboardChartWidgetState createState() => __DashboardChartWidgetState();
 }

 class __DashboardChartWidgetState extends State<_DashboardChartWidget> {
   @override
   Widget build(BuildContext context) {
     return  Column(
       children: [

         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             textMessage('Showing Graph'),
             DropdownButton<ChartType>(
               underline: SizedBox(),

               value: _chartCurrentType,
               items: ChartType.values.map((e) => DropdownMenuItem(child: textMessage((e != ChartType.MONTHLY) ?_getChartTitle(e) : 'Monthly'), value: e,)).toList(),
               onChanged: (ChartType type){

                 if(type == ChartType.MONTHLY)
                   showMonthPicker(
                       context: context,
                       firstDate: DateTime(DateTime.now().year - 5),
                       lastDate: DateTime(DateTime.now().year ),
                       initialDate: DateTime.now())
                       .then((date) => date!= null && date.millisecondsSinceEpoch <= DateTime.now().millisecondsSinceEpoch ? setState(() {

                     _selectedDate = date;
                     _chartCurrentType = type;
                   }) : null);
                 else
                   setState(() {_chartCurrentType = type; });
               },
             )
           ],
         ),



         Container(
             // constraints: BoxConstraints.expand(width:1000, height:300),
           // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
           child: Stack(
               alignment: Alignment.topCenter,
               overflow: Overflow.visible,
               children: [
             Positioned(
                 // top: 10.0,
                 // left: -5.0,
                 // right: -5.0,
                 child: _dashboardChart())
           ]
           )
         ),
       ],
     );

   }


   var _selectedDate = DateTime.now();
   var _currentYear = DateTime.now().year;
   var _startYearMillis = DateFormat("dd-MM-yyyy").parse("01-01-${DateTime.now().year}").millisecondsSinceEpoch;
   var _currentMillis = DateTime.now().millisecondsSinceEpoch;
   var _currentMonth =  DateTime.now().month;

   int getStartMillisOfYear(int year) =>  DateFormat("dd-MM-yyyy").parse("01-01-$year").millisecondsSinceEpoch;
   int getEndMillisOfYear(int year) =>  DateFormat("dd-MM-yyyy").parse("31-12-$year").millisecondsSinceEpoch + Duration.millisecondsPerDay;

   var thisMonthStartMillis = DateFormat("dd-MM-yyyy").parse("01-${DateTime.now().month}-${DateTime.now().year}").millisecondsSinceEpoch;
   ChartType _chartCurrentType = ChartType.THIS_MONTH;

  Widget _dashboardChart() {

     var interval = _getYearlyInterval(_startYearMillis, _currentMillis, _currentMonth, _currentYear);


     if(_chartCurrentType == ChartType.THIS_MONTH){
       interval = _getMonthlyInterval(DateTime.now().month, DateTime.now().year);
     }
     else if(_chartCurrentType == ChartType.MONTHLY){
       interval = _getMonthlyInterval(_selectedDate.month, _selectedDate.year);

     }
     else if(_chartCurrentType == ChartType.LAST_MONTH){
      // start = milli
       if(_currentMonth - 1 == 0)
        interval = _getMonthlyInterval(12, _currentYear - 1);
       else
         interval = _getMonthlyInterval(_currentMonth - 1, _currentYear);

     }
     else if(_chartCurrentType == ChartType.LAST_YEAR){
       interval = _getYearlyInterval(getStartMillisOfYear(_currentYear - 1), getEndMillisOfYear(_currentYear - 1), 12, _currentYear - 1);
     }

     print('${interval.keys.first} - ${interval.values.last}');
     print('$_chartCurrentType , family id - ${widget.familyId}');
     
     return FutureBuilder<QuerySnapshot>(
       future: itemRef.orderBy('purchaseDate')
           .where('purchaseDate', isGreaterThanOrEqualTo: interval.keys.first )
           .where('purchaseDate', isLessThanOrEqualTo: interval.values.last)
            .where(key_familyId, isEqualTo:widget.familyId)
           .get(),
       builder: (context, snapshot){

         if(snapshot.connectionState == ConnectionState.waiting)
           return Center(child: circularProgressBar );

         if(snapshot.hasError) {
            print(snapshot.error);
           return textMessage(snapshot.error.toString());
         }
         var items = snapshot.data.docs.map((e) => Item.fromJson(e.data()));

         print('Item Prices = ${items.map((e) => e.itemPrice).toList()}');

         //calculate month wise average in interval
         // var averagePerMonth = [];
         var totalPerMonth = [];
         List<SalesData> salesList = [];
         var format = _chartCurrentType == ChartType.YEARLY ||  _chartCurrentType == ChartType.LAST_YEAR ? 'MMM' : 'dd MMM';

         // if(true){
           //year wise graph
           interval.forEach((startMillis, endMillis) {

             num sum;
             try {
               sum = items.map((e) =>
               e.purchaseDate >= startMillis && e.purchaseDate <= endMillis ? e
                   .itemPrice : 0.0).reduce((item1, item2) {
                 return item1.toDouble() + item2.toDouble();
               });
             }catch(e){ sum = 0.0; }

             totalPerMonth.add(sum);
             // var average = (sum/count).round();
             // averagePerMonth.add(average);
             salesList.add(SalesData(
                 formatDateWithFormatter(startMillis, format),
                 sum.roundToDouble()));
           });
         // }
         // else {
         //   items.forEach((element) {salesList.add(SalesData(formatDateWithFormatter(element.purchaseDate, format),element.itemPrice.roundToDouble()));});
         // }
         // print('Average List => $averagePerMonth');
         print('Total List => $totalPerMonth');
         print('Total Sales => ${salesList.length}');
         print('Sales => ${salesList.map((e) => e.month)}');

         return plotGraph(salesList);

       },
      ) ;


   }

   Widget plotGraph(List<SalesData> salesList){

    var title = _getChartTitle(_chartCurrentType);
    // var tempList = salesList;
    // tempList.sort((a,b)=>a.expense.compareTo(b.expense));
    // var max = tempList.last.expense;
    // var min = tempList.first.expense;
    //
    // print('max - $max - $min');

     return SfCartesianChart(
         enableAxisAnimation: true,
         plotAreaBorderWidth: 0,
         zoomPanBehavior: ZoomPanBehavior(
           enablePanning: true,
         ),
         margin: EdgeInsets.only(top: 20, bottom: 10, left: 0),
         title: ChartTitle(text: title, textStyle: GoogleFonts.raleway()),
         tooltipBehavior: TooltipBehavior(
           enable: true,
         ),
         primaryYAxis: NumericAxis(isVisible: false, labelFormat: '${getCurrency()} {value}' ,
             // visibleMaximum: max,
             // visibleMinimum: min,
             rangePadding: ChartRangePadding.normal),
         primaryXAxis: CategoryAxis(
           majorGridLines: MajorGridLines(width: 0,), minorTicksPerInterval:0,tickPosition: TickPosition.outside,
             majorTickLines: MajorTickLines(width:0, ), interval: 1

         ),

         series: <ChartSeries>[
           // Renders spline chart
           SplineAreaSeries<SalesData, String>(
             // color: Colors.blue,
               enableTooltip: true,
               opacity: isDarkMode(context) ? 0.4 : 0.8,
               name: 'Expenses',
               gradient: LinearGradient(
                 // begin: Alignment.topLeft,
                 // end: Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
                 colors: [
                   Color.fromRGBO(0, 198, 255, 1),
                   Color.fromRGBO(0, 114, 255, 1),
                   // Color.fromRGBO(0, 114, 255, 1),
                 ], // red to yellow// repeats the gradient over the canvas
               ),
               borderWidth: 2,
               borderColor: Colors.blue,
               dataSource:  salesList,
               yValueMapper: (SalesData sales, _) => sales.expense,
               xValueMapper: (SalesData sales, num index) => sales.month
           )
         ]
     );
   }

   Map<int,int> _getYearlyInterval(int start, int end, int selectedMonth, int selectedYear){

     List<int> millisStartOfMonth = [];

     for(int i=1; i<=selectedMonth;i++){
       var date = "01-$i-$selectedYear";
       // print('Date => $date');
       var millisOfMonth = DateFormat("dd-M-yyyy").parse(date).millisecondsSinceEpoch;
       millisStartOfMonth.add(millisOfMonth);
     }

     Map<int,int> intervals = Map();
     for(int i=0; i<selectedMonth-1;i++){
       intervals[millisStartOfMonth[i]] = millisStartOfMonth[i+1];
     }
     //intervals has upto last month
     //add interval from last month to current millis, if both are same months
     intervals[millisStartOfMonth.last] = end;
     return intervals;
   }


   Map<int,int> _getMonthlyInterval(  int selectedMonth, int selectedYear){
     List<int> millisStartOfMonth = [];

     for(int i=1; i<=31;i++){
       var date = "$i-$selectedMonth-$selectedYear";
       // print('Date => $date');
       try {
         var millisOfMonth = DateFormat("d-M-yyyy")
             .parse(date)
             .millisecondsSinceEpoch;
         millisStartOfMonth.add(millisOfMonth);
       }
       catch(e){ }
       // print('Date => $date');
     }

     Map<int,int> intervals = Map();
     for(int i=0; i<millisStartOfMonth.length-1;i++){
       intervals[millisStartOfMonth[i]] = millisStartOfMonth[i+1];
     }
     //intervals has upto last month
     //finally add today's millis
     intervals[intervals.values.last] = millisStartOfMonth.last + Duration.millisecondsPerDay ;
     return intervals;
   }

   String _getChartTitle(ChartType type){
     if(type == ChartType.YEARLY) return 'This year';
     else if(type == ChartType.MONTHLY) return formatDateWithFormatter(_selectedDate.millisecondsSinceEpoch, "MMMM yyyy");
     else if(type == ChartType.LAST_MONTH) return 'Last Month';
     else if(type == ChartType.LAST_YEAR) return 'Last Year';
     else return 'This month';
   }

 }



var _sampleList = [
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
];



class SalesData {

  SalesData(this.month, this.expense);
  final String month;
  final double expense;
}

class PieChartData {
  PieChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color color;
}

enum ChartType{
  YEARLY, LAST_YEAR,  THIS_MONTH, LAST_MONTH, MONTHLY,

}