import 'package:flutter/material.dart';
import 'package:image_text_reader/provider/premium_provider.dart';
import 'package:image_text_reader/widgets/show_premium.dart';
import 'package:image_text_reader/widgets/user_history.dart';
import 'package:provider/provider.dart';

class UserHistory extends StatelessWidget {
  const UserHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremiumProvider = Provider.of<PremiumProvider>(context);

    // check if the premium status is not loaded yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isPremiumProvider.checkPremiumStatus();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History Converstion",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      body: isPremiumProvider.isPremium
          ? const UserHistoryWidget()
          : ShowPremium(),
    );
  }
}
