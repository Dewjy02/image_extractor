import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_text_reader/provider/premium_provider.dart';
import 'package:image_text_reader/services/stripe/stripe.dart';
import 'package:provider/provider.dart';

class ShowPremium extends StatefulWidget {
  const ShowPremium({super.key});

  @override
  State<ShowPremium> createState() => _ShowPremiumState();
}

class _ShowPremiumState extends State<ShowPremium> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String name = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Regular expression for email validation
  final RegExp _emailRegex = RegExp(
    r'^[^@]+@[^@]+\.[^@]+$', // Basic email regex
    caseSensitive: false,
  );

  // Form submission handler
  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Initiate payment process
      await init(email: email, name: name);
      // Notify provider to update the premium status
      Provider.of<PremiumProvider>(context, listen: false).checkPremiumStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To view your conversion history, please activate the premium feature.',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'user id:${FirebaseAuth.instance.currentUser?.uid}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
              ),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Enter your email',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
              ),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!_emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text(
                'Activate Premium for \$2.99',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}