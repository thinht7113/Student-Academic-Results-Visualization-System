class StudentData {
  final String maSV;
  final String hoTen;
  final String? lop;
  final String? nganh;
  final String? khoa;
  final String? email;
  final List<AcademicResult> ketQuaHocTap;
  final List<CurriculumItem> chuongTrinhDaoTao;

  StudentData({
    required this.maSV,
    required this.hoTen,
    this.lop,
    this.nganh,
    this.khoa,
    this.email,
    required this.ketQuaHocTap,
    required this.chuongTrinhDaoTao,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      maSV: json['MaSV'] ?? '',
      hoTen: json['HoTen'] ?? '',
      lop: json['Lop'],
      nganh: json['Nganh'],
      khoa: json['Khoa'],
      email: json['Email'],
      ketQuaHocTap:
          (json['KetQuaHocTap'] as List?)
              ?.map((e) => AcademicResult.fromJson(e))
              .toList() ??
          [],
      chuongTrinhDaoTao:
          (json['ChuongTrinhDaoTao'] as List?)
              ?.map((e) => CurriculumItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  // ── GPA Calculations ──

  /// Weighted GPA (scale 10) across all subjects
  double get currentGPA10 {
    double totalPoints = 0;
    int totalCredits = 0;
    for (var r in ketQuaHocTap) {
      if ((r.tinhDiemTichLuy ?? true) && r.diemHe10 != null && r.soTinChi > 0) {
        totalPoints += r.diemHe10! * r.soTinChi;
        totalCredits += r.soTinChi;
      }
    }
    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }

  /// Weighted GPA (scale 4)
  double get currentGPA4 {
    double totalPoints = 0;
    int totalCredits = 0;
    for (var r in ketQuaHocTap) {
      if ((r.tinhDiemTichLuy ?? true) && r.diemHe4 != null && r.soTinChi > 0) {
        totalPoints += r.diemHe4! * r.soTinChi;
        totalCredits += r.soTinChi;
      }
    }
    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }

  // Keep backward compat
  double get currentGPA => currentGPA10;

  // ── Credits ──

  int get creditsPassed {
    int c = 0;
    final seen = <String>{};
    for (var r in ketQuaHocTap) {
      if (r.diemHe10 != null && r.diemHe10! >= 4.0 && r.maHP != null) {
        if (!seen.contains(r.maHP!)) {
          seen.add(r.maHP!);
          c += r.soTinChi;
        }
      }
    }
    return c;
  }

  int get creditsDebt {
    // Failed subjects (best grade < 4.0) or not yet taken from curriculum
    final passed = <String>{};
    for (var r in ketQuaHocTap) {
      if (r.diemHe10 != null && r.diemHe10! >= 4.0 && r.maHP != null) {
        passed.add(r.maHP!);
      }
    }
    int debt = 0;
    // From grades: subjects with best score < 4
    final failedCounted = <String>{};
    for (var r in ketQuaHocTap) {
      if (r.maHP != null &&
          !passed.contains(r.maHP!) &&
          !failedCounted.contains(r.maHP!)) {
        failedCounted.add(r.maHP!);
        debt += r.soTinChi;
      }
    }
    return debt;
  }

  int get totalCredits {
    int c = 0;
    final seen = <String>{};
    for (var r in ketQuaHocTap) {
      if (r.maHP != null && !seen.contains(r.maHP!)) {
        seen.add(r.maHP!);
        c += r.soTinChi;
      }
    }
    return c;
  }

  // ── Semester Analysis ──

  List<int> get semesters {
    final s = <int>{};
    for (var r in ketQuaHocTap) {
      final hk = _parseHK(r.hocKy);
      if (hk != null) s.add(hk);
    }
    return s.toList()..sort();
  }

  /// GPA (scale 10) by semester: returns list of {semester, gpa}
  List<SemesterGPA> get gpaBySemester {
    final map = <int, List<AcademicResult>>{};
    for (var r in ketQuaHocTap) {
      final hk = _parseHK(r.hocKy);
      if (hk == null) continue;
      map.putIfAbsent(hk, () => []).add(r);
    }
    final result = <SemesterGPA>[];
    for (var hk in (map.keys.toList()..sort())) {
      final items = map[hk]!;
      double sum = 0, credits = 0;
      for (var r in items) {
        if ((r.tinhDiemTichLuy ?? true) &&
            r.diemHe10 != null &&
            r.soTinChi > 0) {
          sum += r.diemHe10! * r.soTinChi;
          credits += r.soTinChi;
        }
      }
      if (credits > 0) {
        result.add(SemesterGPA(semester: hk, gpa10: sum / credits));
      }
    }
    return result;
  }

  /// Top N subjects sorted by DiemHe10
  List<AcademicResult> topSubjects(int n, {bool ascending = false}) {
    final valid = ketQuaHocTap.where((r) => r.diemHe10 != null).toList();
    valid.sort(
      (a, b) => ascending
          ? a.diemHe10!.compareTo(b.diemHe10!)
          : b.diemHe10!.compareTo(a.diemHe10!),
    );
    return valid.take(n).toList();
  }

  /// Pass rate (%)
  double get passRate {
    final valid = ketQuaHocTap.where((r) => r.diemHe10 != null).toList();
    if (valid.isEmpty) return 0;
    final passed = valid.where((r) => r.diemHe10! >= 4.0).length;
    return passed * 100.0 / valid.length;
  }

  /// Results grouped by semester
  Map<int, List<AcademicResult>> get resultsBySemester {
    final map = <int, List<AcademicResult>>{};
    for (var r in ketQuaHocTap) {
      final hk = _parseHK(r.hocKy);
      if (hk == null) continue;
      map.putIfAbsent(hk, () => []).add(r);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  /// Grade letter from score (scale 10)
  static String letterFrom10(double score) {
    if (score >= 9.0) return 'A+';
    if (score >= 8.5) return 'A';
    if (score >= 8.0) return 'B+';
    if (score >= 7.0) return 'B';
    if (score >= 6.5) return 'C+';
    if (score >= 5.5) return 'C';
    if (score >= 5.0) return 'D+';
    if (score >= 4.0) return 'D';
    return 'F';
  }

  static int? _parseHK(String? s) {
    if (s == null) return null;
    return int.tryParse(s.trim());
  }
}

class SemesterGPA {
  final int semester;
  final double gpa10;
  SemesterGPA({required this.semester, required this.gpa10});
}

class AcademicResult {
  final String? hocKy;
  final String? maHP;
  final String? tenHP;
  final int soTinChi;
  final double? diemHe10;
  final double? diemHe4;
  final String? diemChu;
  final bool? tinhDiemTichLuy;
  final bool? laDiemCuoiCung;

  AcademicResult({
    this.hocKy,
    this.maHP,
    this.tenHP,
    required this.soTinChi,
    this.diemHe10,
    this.diemHe4,
    this.diemChu,
    this.tinhDiemTichLuy,
    this.laDiemCuoiCung,
  });

  factory AcademicResult.fromJson(Map<String, dynamic> json) {
    return AcademicResult(
      hocKy: json['HocKy']?.toString(),
      maHP: json['MaHP'],
      tenHP: json['TenHP'],
      soTinChi: json['SoTinChi'] ?? 0,
      diemHe10: json['DiemHe10'] != null
          ? (json['DiemHe10'] as num).toDouble()
          : null,
      diemHe4: json['DiemHe4'] != null
          ? (json['DiemHe4'] as num).toDouble()
          : null,
      diemChu: json['DiemChu'],
      tinhDiemTichLuy: json['TinhDiemTichLuy'],
      laDiemCuoiCung: json['LaDiemCuoiCung'],
    );
  }

  bool get isPassed => diemHe10 != null && diemHe10! >= 4.0;
  bool get isFailed => diemHe10 != null && diemHe10! < 4.0;
}

class CurriculumItem {
  final int? hocKy;
  final String? maHP;
  final String? tenHP;
  final int soTinChi;

  CurriculumItem({this.hocKy, this.maHP, this.tenHP, required this.soTinChi});

  factory CurriculumItem.fromJson(Map<String, dynamic> json) {
    return CurriculumItem(
      hocKy: json['HocKy'],
      maHP: json['MaHP'],
      tenHP: json['TenHP'],
      soTinChi: json['SoTinChi'] ?? 0,
    );
  }
}
