import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  num paymentDone = 0.0;
  num sharePercent = 0.0;
  String name = 'No Name';


  FamilyMember({this.uid, this.moderator, this.verified, this.addedOn, this.familyId, this.paymentDone = 0.0, this.sharePercent = 0.0, this.name = 'no name'});

  FamilyMember.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    moderator = json['moderator'];
    verified = json['verified'];
    addedOn = json['addedOn'];
    familyId = json['familyId'];
    paymentDone = json['paymentDone'];
    sharePercent = json['sharePercent'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['moderator'] = this.moderator;
    data['verified'] = this.verified;
    data['addedOn'] = DateTime.now().millisecondsSinceEpoch;
    data['familyId'] = this.familyId;
    data['paymentDone'] = this.paymentDone;
    data['sharePercent'] = this.sharePercent;
    data['name'] = this.name;
    return data;
  }
}


class Item {
  String itemId;
  String familyId;
  int addedOn;
  int updatedOn;
  String itemName;
  num itemPrice;
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
  String name, phone;

  UserData({this.uid, this.createdAt, this.updatedOn, this.name, this.phone});

  UserData.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    createdAt = json['createdAt'];
    updatedOn = json['updatedOn'];
    name = json['name'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['createdAt'] = this.createdAt;
    data['updatedOn'] = this.updatedOn;
    data['name'] = this.name;
    data['phone'] = this.phone;
    return data;
  }
}


class NotificationData {
  String from;
  int createdAt;
  String familyId;
  String title, body, to, id;
  bool read = false;

  NotificationData({this.from, this.createdAt, this.familyId, this.title, this.body = '', this.to, this.id, this.read = false});

  NotificationData.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    createdAt = json['createdAt'];
    familyId = json['familyId'];
    title = json['title'];
    body = json['body'];
    to = json['to'];
    id = json['id'];
    read = json['read'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['createdAt'] = this.createdAt;
    data['familyId'] = this.familyId;
    data['title'] = this.title;
    data['body'] = this.body;
    data['to'] = this.to;
    data['id'] = this.id;
    data['read'] = this.read;
    return data;
  }
}


class PaymentModel {
  String uid, familyId;
  int updatedOn;
  num amount;

  PaymentModel({this.uid, this.amount, this.updatedOn,  this.familyId});

  PaymentModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    amount = json['amount'];
    updatedOn = json['updatedOn'];
    familyId = json['familyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['amount'] = this.amount;
    data['updatedOn'] = this.updatedOn;
    data['familyId'] = this.familyId;
    return data;
  }
}


class MessageModel {
  String sentBy, familyId;
  int timestamp;
  String message, type;

  MessageModel({this.sentBy, this.timestamp , this.message, this.type, this.familyId});

  MessageModel.fromJson(Map<String, dynamic> json) {
    sentBy = json['sentBy'];
    timestamp = json['timestamp'];
    message = json['message'];
    type = json['type'];
    familyId = json['familyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sentBy'] = this.sentBy;
    data['timestamp'] = this.timestamp;
    data['type'] = this.type;
    data['message'] = this.message;
    data['familyId'] = this.familyId;
    return data;
  }
}


