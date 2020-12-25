
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'file:///D:/Flutter/projects/FamilyExpense/family_expense/lib/ui/items/AddItemDialogWidget.dart';
import 'package:family_expense/ui/family/FamilyWidget.dart';
import 'package:family_expense/ui/items/ViewItemsWidget.dart';
import 'package:family_expense/ui/profile/MyProfileWidget.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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

           _DashboardChartWidget(),


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

                          if(snapshot.hasError || !snapshot.hasData)
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text('No Items were added', style: Theme.of(context).textTheme.caption,),
                            );

                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {

                              Item item = Item.fromJson(snapshot.data.docs[index].data());

                              return bindPurchaseListItem(context, item, index, true);
                            },
                            itemCount: snapshot.data.size,

                          );
                        },),


                      Divider(height: 1,color: Colors.grey,),

                      ListTile(
                        title: Text('See More'),
                        trailing: Icon(Icons.arrow_right_alt_outlined, size: 40, color: Colors.blue,),
                        onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewItemsWidget(familyId: familyId))),
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

     Navigator.push(_scaffold.currentContext, MaterialPageRoute(builder: (context) => AddItemDialogWidget(familyId: familyId,)));

   }
 }

 class _DashboardChartWidget extends StatefulWidget {
   @override
   __DashboardChartWidgetState createState() => __DashboardChartWidgetState();
 }

 class __DashboardChartWidgetState extends State<_DashboardChartWidget> {
   @override
   Widget build(BuildContext context) {
     return  Card(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
       child: Stack( children: [_dashboardChart(startYearMillis, currentMillis, currentMonth, currentYear)])
     );

   }


   var currentYear = DateTime.now().year;
   var startYearMillis = DateFormat("dd-MM-yyyy").parse("01-01-${DateTime.now().year}").millisecondsSinceEpoch;
   var currentMillis = DateTime.now().millisecondsSinceEpoch;
   var currentMonth =  DateTime.now().month;

  Widget _dashboardChart(int start, int end, int selectedMonth, int selectedYear) {

     List<int> millisStartOfMonth = [];

     for(int i=1; i<=selectedMonth;i++){
       var date = "01-$i-$selectedYear";
       print('Date => $date');
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

     print(intervals);

     return FutureBuilder<QuerySnapshot>(
       future: itemRef.orderBy('purchaseDate').where('purchaseDate', isGreaterThanOrEqualTo: start ).where('purchaseDate', isLessThanOrEqualTo: end).get(),
       builder: (context, snapshot){

         if(snapshot.connectionState == ConnectionState.waiting)
           return Center(child: circularProgressBar );

         if(snapshot.hasError) {
            print(snapshot.error);
           return textMessage(snapshot.error.toString());
         }
         var items = snapshot.data.docs.map((e) => Item.fromJson(e.data()));

         //calculate month wise average in intervals
         var averagePerMonth = [];
         var totalPerMonth = [];
         List<SalesData> salesList = [];
         intervals.forEach((startMillis, endMillis) {
           var count = 0;
           var sum = items.map((e) => e.purchaseDate>=startMillis && e.purchaseDate <= endMillis ? e.itemPrice : 0).reduce((item1, item2) {
             count++;
             return item1 + item2;
           });

           totalPerMonth.add(sum);
           var average = (sum/count).round();
           averagePerMonth.add(average);
           salesList.add(SalesData(formatDateWithFormatter(startMillis, 'MMM'), sum.roundToDouble()));
         });
         print('Average List => $averagePerMonth');
         print('Total List => $totalPerMonth');


         return SfCartesianChart(
             enableAxisAnimation: true,
             plotAreaBorderWidth: 0,
             title: ChartTitle(text: 'This Year'),
             tooltipBehavior: TooltipBehavior(
                 enable: true
             ),
             primaryYAxis: NumericAxis(isVisible: false, labelFormat: '${getCurrency()} {value}' , name: 'Expenses'),
             primaryXAxis: CategoryAxis(axisLine: AxisLine(width: 0),
                 majorGridLines: MajorGridLines(
                 width: 0,),
                 minorTicksPerInterval:0),

             series: <ChartSeries>[
               // Renders spline chart
               SplineAreaSeries<SalesData, String>(
                 // color: Colors.blue,
                 enableTooltip: true,
                   gradient: LinearGradient(
                     // begin: Alignment.topLeft,
                     // end: Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
                     colors: [
                       hexToColor("#00c6ff"),
                       hexToColor("#0072ff"),
                     ], // red to yellow// repeats the gradient over the canvas
                   ),
                   opacity: 0.8,
                   borderWidth: 0,
                   borderColor: Colors.red,
                   dataSource: _sampleList,
                   yValueMapper: (SalesData sales, _) => sales.expense,
                   xValueMapper: (SalesData sales, num index) => sales.month
               )
             ]
         );
       },
      ) ;


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
