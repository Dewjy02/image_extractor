import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_text_reader/model/conversion_model.dart';
import 'package:image_text_reader/services/store_image_in_cloudinary.dart';

class StoreTextInFirestore {
  //Firestore instance
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //methods to store the converstion data in the firestore
  Future<void> storeConversionData({
    required converstionData,
    required converstionDate,
    required imageFile,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        await _firebaseAuth.signInAnonymously();
      }
      final userId = _firebaseAuth.currentUser!.uid;

      //store the image in the storage and get the download url
      final String imageUrl = await StoreImageInCloudinaryStorage().uploadImage(
        conversionImage: imageFile,
        userId: userId,
      );

      //create a reference to the collection in firestore
      CollectionReference conversion = _firebaseFirestore.collection(
        "conversion",
      );

      //data
      final ConversionModel conversionModel = ConversionModel(
        userId: userId,
        conversionData: converstionData,
        conversionDate: converstionDate,
        imageurl: imageUrl,
      );
      // store the data in the firestore
      await conversion.add(conversionModel.toJson());
      print("Stored Data!");
    } catch (e) {
      print("Error from firestore:$e");
    }
  }

  //Method to get all conversion documents for the current user(stream)
  Stream<List<ConversionModel>> getUserConversions()  {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      print(userId);

      if (userId == null) {
        throw Exception("No user is currently signed in!");
      }

      return _firebaseFirestore
          .collection("conversion")
          .where("userId", isEqualTo: userId)
          .snapshots()
          .map((snapshots) {
            return snapshots.docs.map((doc) {
              return ConversionModel.fromJson(doc.data());
            }).toList();
          });
    } catch (e) {
      return Stream.empty();
    }
  }
}
