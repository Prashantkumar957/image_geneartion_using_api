import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ImageGenerationController extends GetxController {
  Future<Uint8List?> generateImage(
    String? prompt,
    String? negativePrompt,
    String? aspectRatio,
    int? styleId,
    context,
  ) async {
    try {
      var uri = Uri.parse("https://api.vyro.ai/v1/imagine/api/generations");
      var midjourney_API_KEY = "vk-QQ1bPKkk3oH4JcscsK4Dit8AzevSq8Z3KXXXl10qSXdhc";
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $midjourney_API_KEY'
        ..fields['prompt'] = prompt ?? ''
        ..fields['negative_prompt'] = negativePrompt ?? ''
        ..fields['aspect_ratio'] = aspectRatio ?? ''
        ..fields['style_id'] = styleId.toString();
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        debugPrint("Image successfully generated");
        return Uint8List.fromList(responseData);
      } else if (response.statusCode == 503) {
        debugPrint("Server busy or connection lost from server");
      } else if (response.statusCode == 402) {
        debugPrint("Payment required to proceed");
      } else {
        debugPrint("Something went wrong");
      }
    } catch (e) {
      debugPrint("Error : generateImage() > $e");
    }
  }
}
