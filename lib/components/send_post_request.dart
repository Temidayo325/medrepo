import 'package:dio/dio.dart';
import 'dio_request_instance.dart'; // Import the singleton instance

Future<Map<String, dynamic>> sendDataToApi(
  String url,
  Map<String, dynamic> data, {
  String method = "POST",
}) async {
  // 1. Use the globally configured Dio instance
  final dio = dioInstance; 
  Response response; // Dio's Response type

  try {
   final options = Options(method: method); 

    switch (method) {
      case "POST":
        response = await dio.post(
          url,
          options: options,
          data: data, // Dio automatically JSON encodes the Map
        );
      case "PUT":
        response = await dio.put(
          url,
          options: options,
          data: data,
        );
      case "PATCH":
        response = await dio.patch(
          url,
          options: options,
          data: data,
        );
      case "GET":
        // GET requests use queryParameters for data
        response = await dio.get(
          url,
          options: options,
          queryParameters: data.isNotEmpty ? data : null, 
        );
      default:
        throw Exception("Unsupported HTTP method: $method");
    }
    return response.data; 

  } on DioException catch (e) {
     if (e.response != null) {
      throw Exception(
        'API call failed with status ${e.response!.statusCode}: ${e.response!.data}',
      );
    }
    
    // Re-throw other network/request errors
    rethrow;
  } catch (e) {
    // Catch general errors (like the "Unsupported HTTP method" exception)
    rethrow;
  }
}