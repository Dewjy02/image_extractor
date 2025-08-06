import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_text_reader/constants/colors.dart';
import 'package:image_text_reader/model/conversion_model.dart';
import 'package:image_text_reader/services/store_text_in_firestore.dart';

class UserHistoryWidget extends StatelessWidget {
  const UserHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConversionModel>>(
      stream: StoreTextInFirestore().getUserConversions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error:${snapshot.error}"));
        }

        final List<ConversionModel>? userConversion = snapshot.data;

        if (userConversion == null || userConversion.isEmpty) {
          return const Center(child: Text("No conversions found"));
        }

        final sortedList = List<ConversionModel>.from(userConversion)
          ..sort((a, b) => b.conversionDate.compareTo(a.conversionDate));

        return ListView.builder(
          itemCount: sortedList.length,
          itemBuilder: (context, index) {
            final ConversionModel conversion = sortedList[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        conversion.imageurl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 100);
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            conversion.conversionData.length > 200
                                ? "${conversion.conversionData.substring(0, 200)}..."
                                : conversion.conversionData,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: conversion.conversionData),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Text copied to clipboard!"),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, color: mainColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Convered on: ${conversion.conversionDate.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
