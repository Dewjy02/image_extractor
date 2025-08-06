import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

class StoreImageInCloudinaryStorage {
  final cloudinary = CloudinaryPublic(
    'dejazvqir',       
    'unsigned_preset',    
    cache: false,
  );

  Future<String> uploadImage({
    required File conversionImage,
    required String userId,
  }) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          conversionImage.path,
          folder: "conversion/$userId",
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl; 
    } catch (e) {
      print("Cloudinary Upload Failed: $e");
      return "";
    }
  }
}


