import 'package:cloud_firestore/cloud_firestore.dart';

class ConversionModel {
  final String userId;
  final String conversionData;
  final DateTime conversionDate;
  final String imageurl;

  ConversionModel({
    required this.userId,
    required this.conversionData,
    required this.conversionDate,
    required this.imageurl,
  });

  //json data to ConversionModel
  factory ConversionModel.fromJson(Map<String, dynamic> json) {
    return ConversionModel(
      userId: json["userId"],
      conversionData: json["conversionData"],
      conversionDate: (json["conversionDate"] as Timestamp).toDate(),
      imageurl: json["imageUrl"],
    );
  }

  //ConversionModel to json data 
  Map<String, dynamic> toJson(){
    return{
      "userId":userId,
      "conversionData": conversionData,
      "conversionDate":Timestamp.fromDate(conversionDate),
      "imageUrl":imageurl
    };
  }
  
}
