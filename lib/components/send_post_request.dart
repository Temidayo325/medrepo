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
        case "DELETE":
          String deleteUrl = url;
          Map<String, dynamic>? deleteData;
        
          if (data.containsKey('id')) {
            // Append ID to URL for RESTful DELETE
            deleteUrl = "$url/${data['id']}";
            // Remove 'id' from data map and send remaining data if any
            deleteData = Map<String, dynamic>.from(data)..remove('id');
            deleteData = deleteData.isNotEmpty ? deleteData : null;
          } else {
            deleteData = data.isNotEmpty ? data : null;
          }
          response = await dio.delete(
            deleteUrl,
            options: options,
            data: deleteData,
          );
      default:
        throw Exception("Unsupported HTTP method: $method");
    }
    return response.data; 

  } on DioException catch (e) {
    // If the server responded with a status code (like 401, 422, 500)
    if (e.response != null) {
      // Instead of throwing an exception, return the actual response data
      final Map<String, dynamic> errorData = Map<String, dynamic>.from(e.response!.data);
      
      // Inject the status code so your UI can check if (response['status_code'] == 401)
      errorData['status_code'] = e.response!.statusCode;
      return errorData;
    }
    
    // If there is NO response (like a Timeout or No Internet), THEN throw
    throw Exception("Connection failed: Check your internet.");
  }
}