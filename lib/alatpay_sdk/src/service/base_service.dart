import 'dart:convert';
import 'package:http/http.dart' as http;
import 'alatpay_exception.dart';

abstract class BaseService {
  final http.Client client;
  final String baseUrl;
  final Map<String, String> headers;

  BaseService(this.client, this.baseUrl, this.headers);

  Future<Map<String, dynamic>> _handleRequest(
    Future<http.Response> Function() fn, {
    required String method,
    required String url,
  }) async {
    AlatPayException.clear();
    try {
      final res = await fn();

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw AlatPayException.fromResponse(res);
      }

      try {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        throw AlatPayApiException("Invalid JSON response");
      }
    } on http.ClientException catch (e) {
      throw AlatPayNetworkException(e.message);
    } catch (e) {
      throw AlatPayException(e.toString());
    }
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = '$baseUrl$path';
    return _handleRequest(
      () =>
          client.post(Uri.parse(url), headers: headers, body: jsonEncode(body)),
      method: 'POST',
      url: url,
    );
  }

  Future<Map<String, dynamic>> get(String path) async {
    final url = '$baseUrl$path';
    return _handleRequest(
      () => client.get(Uri.parse(url), headers: headers),
      method: 'GET',
      url: url,
    );
  }
}
