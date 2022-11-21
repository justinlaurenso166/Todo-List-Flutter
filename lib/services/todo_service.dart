import 'dart:convert';

import 'package:http/http.dart' as http;

//All api call
class TodoService {
  static Future<bool> deleteById(String id) async {
    final url = 'http://localhost:8080/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    return response.statusCode == 200;
  }

  static Future<bool> clearAllHistory() async {
    final url = 'http://localhost:8080/todos/clear/completed';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    return response.statusCode == 200;
  }

  static Future<List?> fetchTodos() async {
    final url = 'http://localhost:8080/todos/uncompleted';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['data'] as List;
      return result;
    } else {
      return null;
    }
  }

  static Future<List?> fetchTodosCompleted() async {
    final url = 'http://localhost:8080/todos/completed';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['data'] as List;
      return result;
    } else {
      return null;
    }
  }

  static Future<bool> updateTodo(String id, Map body) async {
    final url = 'http://localhost:8080/todos/$id'; //post api
        final uri = Uri.parse(url);
        final response = await http.patch(
          uri, 
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json'
        }
    );
    return response.statusCode == 200;
  }

  static Future<bool> addTodo(Map body) async {
    final url = 'http://localhost:8080/todos'; //post api
        final uri = Uri.parse(url);
        final response = await http.post(
          uri, 
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json'
        }
    );
    return response.statusCode == 200;
  }
}