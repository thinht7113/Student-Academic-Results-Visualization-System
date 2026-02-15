import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/student_data.dart';

class StudentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  StudentData? _studentData;
  bool _isLoading = false;
  String? _error;

  StudentData? get studentData => _studentData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Quick accessors
  double get currentGPA => _studentData?.currentGPA10 ?? 0;
  int get creditsPassed => _studentData?.creditsPassed ?? 0;
  int get creditsDebt => _studentData?.creditsDebt ?? 0;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchStudentData();
      if (data != null) {
        _studentData = data;
      } else {
        _error = 'Không thể tải dữ liệu sinh viên';
      }
    } catch (e) {
      _error = e.toString();
      print('[StudentProvider] Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _studentData = null;
    _error = null;
    notifyListeners();
  }
}
