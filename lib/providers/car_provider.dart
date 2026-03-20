import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarProvider extends ChangeNotifier {
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedYear;

  String? get selectedBrand => _selectedBrand;
  String? get selectedModel => _selectedModel;
  String? get selectedYear => _selectedYear;

  bool get hasCarSelected => _selectedBrand != null && _selectedModel != null;

  CarProvider() {
    _loadCar();
  }

  Future<void> setCar(String brand, String model, String year) async {
    _selectedBrand = brand;
    _selectedModel = model;
    _selectedYear = year;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('car_brand', brand);
    await prefs.setString('car_model', model);
    await prefs.setString('car_year', year);
  }

  Future<void> clearCar() async {
    _selectedBrand = null;
    _selectedModel = null;
    _selectedYear = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('car_brand');
    await prefs.remove('car_model');
    await prefs.remove('car_year');
  }

  Future<void> _loadCar() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedBrand = prefs.getString('car_brand');
    _selectedModel = prefs.getString('car_model');
    _selectedYear = prefs.getString('car_year');
    notifyListeners();
  }
}
