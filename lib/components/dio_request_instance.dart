// dio_request_instance.dart

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Create a reusable, global Dio instance
final Dio dioInstance = Dio(
  BaseOptions(
    // Optional: Set a global base URL if your requests all go to the same domain.
    // baseUrl: 'https://your-api-base-url.com/', 
    connectTimeout: const Duration(seconds: 10), // Example timeout
    receiveTimeout: const Duration(seconds: 10), // Example timeout
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
);

// Add an Interceptor to automatically handle token injection
// This replaces the manual 'header' construction in your old function.
void setupDioInterceptor() {
  dioInstance.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Fetch the token from Hive before every request
        final token = Hive.box('token').get('api_token', defaultValue: '');
        
        // Add Authorization header if the token exists
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // You can add logging here too, if needed
        print("Request to: ${options.uri}");
        
        return handler.next(options);
      },
      // You can also add onError or onResponse handling here globally
    ),
  );
}

// NOTE: You must call setupDioInterceptor() once (e.g., in main() or during 
// application startup) to activate the token logic.