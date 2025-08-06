//init method

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:image_text_reader/services/stripe/stripe_api_service.dart';
import 'package:image_text_reader/services/stripe/stripe_storage.dart';

Future<void> init({required String name, required String email}) async {
  print("called");
  //create a new customer
  Map<String, dynamic>? customer = await createCustomer(
    email: email,
    name: name,
  );
  if (customer == null || customer['id'] == null) {
    throw Exception("Failed to create customer");
  }

  //create a payment intent
  Map<String, dynamic>? paymentIntent = await createPaymentIntent(
    customerId: customer['id'],
  );

  if (paymentIntent == null || paymentIntent["client_secret"] == null) {
    throw Exception("Failed to create payment intent");
  }

  //create a credit card
  await createCreditCard(
    customerId: customer["id"],
    clientSecret: paymentIntent["client_secret"],
  );

  // Retrieve customer payment methods
  Map<String, dynamic>? customerPaymentMethodes =
      await getCustomerPaymentMethodes(customerId: customer["id"]);

  if (customerPaymentMethodes == null ||
      customerPaymentMethodes['data'].isEmpty) {
    throw Exception("Failed to get customer payment methods");
  }

  // Create a subscription
  Map<String, dynamic>? subscription = await createSubscription(
    customerId: customer['id'],
    paymentId: customerPaymentMethodes['data'][0]['id'],
  );

  if (subscription == null || subscription['id'] == null) {
    throw Exception('Failed to create subscription.');
  }

  //store subscription data on firestore
  StripeStorage().storeSubscriptionDetails(
    customerId: customer['id'],
    email: email,
    userName: name,
    subscriptionId: subscription['id'],
    paymentStatus: 'active',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 30)),
    planId: "price_1RrNpZ4ob7eniLNe7Qs9K20h",
    amountPaid: 2.99,
    currency: "USD",
    paymentMethod: "Credit Card",
  );
}

//create customer
Future<Map<String, dynamic>?> createCustomer({
  required String email,
  required String name,
}) async {
  final customerCreatingResponse = await stripeApiService(
    requestMethode: ApiServiceMethodType.post,
    endpoint: "customers",
    requestBody: {
      "name": name,
      "email": email,
      "description": 'Text Extractor Pro Plan',
    },
  );
  return customerCreatingResponse;
}

//create payment intent
Future<Map<String, dynamic>?> createPaymentIntent({
  required String customerId,
}) async {
  final paymentIntentCreationResponse = await stripeApiService(
    requestMethode: ApiServiceMethodType.post,
    endpoint: "setup_intents",
    requestBody: {
      'customer': customerId,
      'automatic_payment_methods[enabled]': 'true',
    },
  );
  return paymentIntentCreationResponse;
}

// Create a credit card
Future<void> createCreditCard({
  required String customerId,
  required String clientSecret,
}) async {
  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      primaryButtonLabel: 'Subscribe \$2.99 monthly',
      style: ThemeMode.light,
      merchantDisplayName: 'Text Extractor Pro Plan',
      customerId: customerId,
      setupIntentClientSecret: clientSecret,
    ),
  );
  await Stripe.instance.presentPaymentSheet();
}

// get customer payment methods
Future<Map<String, dynamic>?> getCustomerPaymentMethodes({
  required String customerId,
}) async {
  final customerPaymentMethodsResponse = await stripeApiService(
    requestMethode: ApiServiceMethodType.get,
    endpoint: 'customers/$customerId/payment_methods',
  );

  return customerPaymentMethodsResponse;
}

//create subscription
Future<Map<String, dynamic>?> createSubscription({
  required String customerId,
  required String paymentId,
}) async {
  final subscriptionCreationResponse = await stripeApiService(
    requestMethode: ApiServiceMethodType.post,
    endpoint: "subscriptions",
    requestBody: {
      'customer': customerId,
      'default_payment_method': paymentId,
      'items[0][price]': 'price_1RrNpZ4ob7eniLNe7Qs9K20h',
    },
  );

  return subscriptionCreationResponse;
}
