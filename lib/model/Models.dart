import 'package:cloud_firestore/cloud_firestore.dart';

class Family{
  String name;
  String id;
  String createdBy;
  int createdAt;
  int updatedAt;
  String code;

  Family({this.name, this.id, this.createdBy, this.createdAt, this.updatedAt, this.code});

  Family.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['createdBy'] = this.createdBy;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['code'] = this.code;
    return data;
  }

}

class FamilyMember {
  String uid, familyId;
  bool moderator;
  bool verified;
  int addedOn;

  FamilyMember({this.uid, this.moderator, this.verified, this.addedOn, this.familyId});

  FamilyMember.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    moderator = json['moderator'];
    verified = json['verified'];
    addedOn = json['addedOn'];
    familyId = json['familyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['moderator'] = this.moderator;
    data['verified'] = this.verified;
    data['addedOn'] = this.addedOn;
    data['familyId'] = this.familyId;
    return data;
  }
}


class Item {
  String itemId;
  String familyId;
  int addedOn;
  int updatedOn;
  String itemName;
  int itemPrice;
  String addedBy;
  int purchaseDate;

  Item(
      {this.itemId,
        this.familyId,
        this.addedOn,
        this.updatedOn,
        this.itemName,
        this.itemPrice,
        this.addedBy,
        this.purchaseDate});

  Item.fromJson(Map<String, dynamic> json) {
    itemId = json['itemId'];
    familyId = json['familyId'];
    addedOn = json['addedOn'];
    updatedOn = json['updatedOn'];
    itemName = json['itemName'];
    itemPrice = json['itemPrice'];
    addedBy = json['addedBy'];
    purchaseDate = json['purchaseDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemId'] = this.itemId;
    data['familyId'] = this.familyId;
    data['addedOn'] = this.addedOn;
    data['updatedOn'] = this.updatedOn;
    data['itemName'] = this.itemName;
    data['itemPrice'] = this.itemPrice;
    data['addedBy'] = this.addedBy;
    data['purchaseDate'] = this.purchaseDate;
    return data;
  }
}


class UserData {
  String uid;
  int createdAt;
  int updatedOn;
  String name;

  UserData({this.uid, this.createdAt, this.updatedOn, this.name});

  UserData.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    createdAt = json['createdAt'];
    updatedOn = json['updatedOn'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['createdAt'] = this.createdAt;
    data['updatedOn'] = this.updatedOn;
    data['name'] = this.name;
    return data;
  }
}


class NotificationData {
  String from;
  int createdAt;
  String familyId;
  String title, body;

  NotificationData({this.from, this.createdAt, this.familyId, this.title, this.body});

  NotificationData.fromJson(Map<String, dynamic> json) {
    from = json['uid'];
    createdAt = json['createdAt'];
    familyId = json['familyId'];
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.from;
    data['createdAt'] = this.createdAt;
    data['familyId'] = this.familyId;
    data['title'] = this.title;
    data['body'] = this.body;
    return data;
  }
}

