import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

import 'package:chat/global/enviroment.dart';
import 'package:chat/models/login_response.dart';
import 'package:chat/models/user.dart';

class AuthService with ChangeNotifier {

  User user;

  bool _isLoading = false;

  final _storage = new FlutterSecureStorage();

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  static Future<String> getToken() async {
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future login(String email, String password) async {

    isLoading = true;

    final data = {
      'email': email,
      'password': password
    };

    final resp = await http.post('${Enviroment.apiUrl}/login', body: jsonEncode(data), headers: {
      'Content-Type': 'application/json'
    });

    isLoading = false;

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      user = loginResponse.user;
      await _saveToken(loginResponse.token);
      return true;
    }else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future register(String name, String email, String password) async {
    isLoading = true;

    final data = {
      'name': name,
      'email': email,
      'password': password
    };

    final resp = await http.post('${Enviroment.apiUrl}/login/new', body: jsonEncode(data), headers: {
      'Content-Type': 'application/json'
    });

    isLoading = false;

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      user = loginResponse.user;
      await _saveToken(loginResponse.token);
      return true;
    }else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future<bool> verifyToken() async {
    final token = await _storage.read(key: 'token');
    final resp = await http.get('${Enviroment.apiUrl}/login/refresh', headers: {
      'Content-Type': 'application/json',
      'x-token': token
    });

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      user = loginResponse.user;
      await _saveToken(loginResponse.token);
      return true;
    }else {
      _removeToken();
      return false;
    }
  }

  Future _saveToken(String token) async {
   return await _storage.write(key: 'token', value: token);
  }

  Future _removeToken() async {
    return await _storage.delete(key: 'token');
  }

}