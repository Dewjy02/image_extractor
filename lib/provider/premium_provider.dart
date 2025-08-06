import 'package:flutter/foundation.dart';
import 'package:image_text_reader/services/stripe/stripe_storage.dart';

class PremiumProvider with ChangeNotifier {

   bool _isPremium = false;
   bool get isPremium => _isPremium;

   Future<void> checkPremiumStatus() async{
    _isPremium = await StripeStorage().checkIfUserIsPremium();
    notifyListeners();
   }

   void activatePremium(){
    _isPremium = true;
    notifyListeners();
   }

}