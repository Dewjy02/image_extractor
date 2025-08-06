import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StripeStorage {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> storeSubscriptionDetails({
    required String customerId,
    required String email,
    required String userName,
    required String subscriptionId,
    required String paymentStatus,
    required DateTime startDate,
    required DateTime endDate,
    required String planId,
    required double amountPaid,
    required String currency,
    String? paymentMethod,
    String? subscriptionType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? autoRenewal,
    String? cancellationReason,
    String? promoCode,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await _firebaseFirestore
          .collection("PremiumUserDetails")
          .doc(customerId)
          .set({
            "userId": userId,
            'customerId': customerId,
            'email': email,
            'userName': userName,
            'subscriptionId': subscriptionId,
            'paymentStatus': paymentStatus,
            'startDate': startDate,
            'endDate': endDate,
            'planId': planId,
            'amountPaid': amountPaid,
            'currency': currency,
            'paymentMethod': paymentMethod ?? '',
            'subscriptionType': subscriptionType ?? 'premium',
            'createdAt': createdAt ?? DateTime.now(),
            'updatedAt': updatedAt ?? DateTime.now(),
            'autoRenewal': autoRenewal ?? true,
            'cancellationReason': cancellationReason ?? '',
            'promoCode': promoCode ?? '',
            'metadata': metadata ?? {},
          });

      print("Subscription Data stored successfully!");
    } catch (e) {
      print(e);
    }
  }

  // check weather the uid is premium
  Future<bool> checkIfUserIsPremium() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final querySnapshot = await _firebaseFirestore
          .collection('PremiumUserDetails')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }
}
