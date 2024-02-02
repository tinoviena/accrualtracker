import 'dart:async';
import 'package:accrualtracker/domain_model.dart';
import 'package:accrualtracker/http_data_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDataProvider implements DataProvider {
  SqliteDataProvider._create();

  static FutureOr<SqliteDataProvider> create() async {
    SqliteDataProvider provider = SqliteDataProvider._create();
  }

  @override
  // TODO: implement apiUrl
  String get apiUrl => throw UnimplementedError();

  @override
  Future<String> getData() {
    // TODO: implement getData
    throw UnimplementedError();
  }

  @override
  Future<double> getTotal(String account) {
    // TODO: implement getTotal
    throw UnimplementedError();
  }

  @override
  Future<String> postData(Map<String, dynamic> jsonData) {
    // TODO: implement postData
    throw UnimplementedError();
  }

  @override
  // TODO: implement secret
  String get secret => throw UnimplementedError();
}
