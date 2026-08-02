import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/transaction.dart';

class TransactionsApi {
  static final Dio _dio = ApiClient.instance.dio;

  static Future<List<Transaction>> getMesTransactions() async {
    final resp =
        await _dio.get('/api/transactions/transactions/mes_transactions/');
    return (resp.data as List).map((e) => Transaction.fromJson(e)).toList();
  }
}
