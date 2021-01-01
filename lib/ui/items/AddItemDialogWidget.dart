
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/ui/auth/JoinFamilyWidget.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddItemDialogWidget extends StatelessWidget {

  final String familyId;
  final Item item;
  AddItemDialogWidget({Key key, this.familyId, this.item}):super(key:key);

  @override
  Widget build(BuildContext context) {

    // String familyId = familyId;
    var query = familyMemberRef.where("uid", isEqualTo: uid).where("familyId", isEqualTo: familyId).where('verified', isEqualTo: true);
    if(familyId == null || familyId.isEmpty){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'You are not in a family yet');
      return SizedBox();
    }


    return Scaffold(
      appBar: AppBar(title: ralewayText('Add item'),),
      body: Column(
        children: [

          FutureBuilder<QuerySnapshot>(
              future: query.get(),
              builder: (context, snapshot){

                if(snapshot.connectionState == ConnectionState.waiting)
                  return Center( child: circularProgressBar);

                if(!snapshot.hasData || snapshot.hasError)
                  return textMessage('You are not allowed to add items. Contact the moderator');

                return _BodyWidget(familyId: familyId, item: item,);
            }
          )


        ],
      ),
    );
  }
}


class _BodyWidget extends StatefulWidget {


  final String familyId ;
  final Item item;
  _BodyWidget({Key key, this.familyId, this.item}):super(key:key);

  @override
  __BodyWidgetState createState() => __BodyWidgetState();
}

class __BodyWidgetState extends State<_BodyWidget> {

  var isInserting = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  var purchaseDateInMillis = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {

    if(widget.item != null){
      purchaseDateInMillis = widget.item.purchaseDate;
      _nameController.text = widget.item.itemName;
      _priceController.text = widget.item.itemPrice.toString();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Column(
        children: [
          SizedBox(height: 20,),

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
                  height: 40,
                  // width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  child:  GestureDetector(
                    child: Row(
                      children: [
                        Text(formattedDate(purchaseDateInMillis), style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w300),),
                        Icon(Icons.arrow_drop_down_sharp)
                        // SvgPicture.asset("assets/icons/dropdown.svg")
                        // SvgPicture.asset("assets/icons/dropdown.svg", height: 40,),

                      ],
                    ),
                    onTap: ()async{
                      DateTime picker = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());

                      setState(() {
                        //show date picker
                        purchaseDateInMillis = picker.millisecondsSinceEpoch;
                        print(formattedDate(purchaseDateInMillis));

                      });
                    },
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

              FutureBuilder(
                future: getPrefValue(uid),
                builder: (context, familyId) => MaterialButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  color: Colors.grey[200],
                  padding: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                  child: Text('Add Item', style: TextStyle().copyWith(fontSize: 22, color: Colors.black, fontWeight: FontWeight.w400),),

                  onPressed: ()async{
                    if(isInserting)
                      return;

                    if(familyId == null){
                      Navigator.popUntil(context, ModalRoute.withName('/'),);

                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>JoinOrCreateFamilyWidget()));
                      Fluttertoast.showToast(msg: "You have not joined any family yet.");
                      return;
                    }

                    if(_nameController.text.isEmpty || _priceController.text.isEmpty){
                      showSnackBar(context, "All fields required");
                      return;
                    }

                    //insert item
                    String itemId = widget.item == null ? "Item_${DateTime.now().millisecondsSinceEpoch}" : widget.item.itemId;
                    var time = widget.item == null ? DateTime.now().millisecondsSinceEpoch : widget.item.addedOn;

                    Item item = Item(itemId: itemId, familyId: familyId.data, addedOn: time, updatedOn: time,
                        itemPrice: double.parse(_priceController.text) , addedBy: uid, purchaseDate: purchaseDateInMillis,itemName: _nameController.text);

                    showProgressSnack(context, 'Adding Item');
                    itemRef.doc(itemId).set(item.toJson())
                        .then((value) async {
                            hideSnackBar(context);
                            showSnackBar(context, "Item Added");
                            //update family expense amount
                            Navigator.of(context).pop();

                            var expenseData = await familyExpenseRef.doc(familyId.data).get();
                            if(expenseData.exists){
                              familyExpenseRef.doc(familyId.data).update({ key_amount: ((expenseData.get(key_amount)) + item.itemPrice) , 'updatedAt': item.addedOn,
                                'remaining': ((expenseData.get('remaining')) + item.itemPrice)  });
                            }
                            else{
                              familyExpenseRef.doc(familyId.data).set({ key_amount:  item.itemPrice , 'updatedAt': item.addedOn, 'remaining': item.itemPrice });
                            }
                    });

                  },
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}
