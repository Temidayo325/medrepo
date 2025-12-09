import 'package:dio/dio.dart';
// import 'package:hive_flutter/hive_flutter.dart'; 
import 'dio_request_instance.dart'; // Import the singleton instance

Future<Map<String, dynamic>> sendDataToApi(
  String url,
  Map<String, dynamic> data, {
  String method = "POST",
}) async {
  // 1. Use the globally configured Dio instance
  final dio = dioInstance; 

  // --- Simplified Logic ---
  // Headers (Authorization, Content-Type) are managed by the Dio Interceptor/BaseOptions
  print("Request data: $data");
  print("Method: $method");

  Response response; // Dio's Response type

  try {
    // We only need to set the HTTP method here
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

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.data}");
    
    // Dio successfully completed the request (2xx status).
    // response.data is already the decoded JSON (Map<String, dynamic>).
    return response.data; 

  } on DioException catch (e) {
    // Catch Dio-specific errors (network, timeout, non-2xx status codes)
    print("Dio Error Status: ${e.response?.statusCode}");
    print("Dio Error Response: ${e.response?.data}");
    
    // Throw an exception that includes the server's error message
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