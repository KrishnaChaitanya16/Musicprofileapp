import 'package:flutter/material.dart';

class BottomNavigationBarProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int newIndex) {
    _currentIndex = newIndex;
    notifyListeners();
  }
}