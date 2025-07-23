import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _userId;
  String? _email;
  String? _name;

  int? get userId => _userId;
  String? get email => _email;
  String? get name => _name;

  void setUser({required int id, required String email, required String name}) {
    _userId = id;
    _email = email;
    _name = name;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _email = null;
    _name = null;
    notifyListeners();
  }
}
