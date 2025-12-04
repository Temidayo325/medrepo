import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> sendDataToApi(
  String url,
  Map<String, dynamic> data, {
  String method = "POST",   // <-- optional parameter with default
}) async {
  final token = Hive.box('token').get('api_token', defaultValue: '');
  final header = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
  print(data);

  http.Response response;

  if (method == "POST") {
    response = await http.post(
      Uri.parse(url),
      headers: header,
      body: jsonEncode(data),
    );
  } else if (method == "PUT" ) {
    response = await http.put(
      Uri.parse(url),
      headers: header,
      body: jsonEncode(data),
    );
  }else if(method == "PATCH") {
      response = await http.patch(
      Uri.parse(url),
      headers: header,
      body: jsonEncode(data),
    );
  }else {
    throw Exception("Unsupported HTTP method: $method");
  }
  print(response.body);
  return jsonDecode(response.body);
}

