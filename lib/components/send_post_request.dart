import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> sendDataToApi(
  String url,
  Map<String, dynamic> data,
) async {
  final token = Hive.box('token').get('api_token', defaultValue: '');
  print(data);
  final response = await http.post(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    },
    body: jsonEncode(data),
  );
  // You always get a Map<String, dynamic>
  print(response.body);
  return jsonDecode(response.body);
}
