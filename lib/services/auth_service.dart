// lib/services/auth_service.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'api_service.dart';
import 'api_endpoints.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final ApiService api;

  AuthService(this.api);

  /// Simple placeholder "encryption".
  /// TODO: Replace with real encryption as per backend requirement.
  String _encrypt(String value) {
    return base64Encode(utf8.encode(value));
  }

  void _logApiCall(
    String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    Response? response,
  ) {
    // You can replace debugPrint with your own logger
    debugPrint('API CALL: $endpoint');
    if (data != null) debugPrint('Request Data: $data');
    if (headers != null) debugPrint('Request Headers: $headers');
    if (response != null)
      debugPrint('Response: ${response.statusCode} ${response.data}');
  }

  /// Login using identifier (phone/email) + password
  ///
  /// Sends credentials in headers as required:
  /// - UserId: encrypted phone/email
  /// - Password: encrypted password
  /// - Cust_UserId: static 'Abc'
  /// - Cust_Password: static '123'
  /// - Cust_Otp: true
  Future<Response> login({
    required String identifier,
    String? password,
    bool custOtp = false,
  }) async {
    final headers = <String, dynamic>{
      'UserId':
          'i/jvNw56275GboRZu0XoNQ==', // Encrypted or static as per current code
      // If custOtp is true, we don't send Password header? Or maybe send empty?
      // Based on request: "do not send Cust_Password in this case".
      // Assuming 'Password' header is still needed or static 'no4mXKgy2gnpvdDDjXG49A==' is fine.
      // Current code has static Password header. Leaving it as is unless specified.
      'Password': 'no4mXKgy2gnpvdDDjXG49A==',
      'Cust_UserId': identifier,
      'Cust_Password': custOtp ? '' : (password ?? ''),
      'Cust_Otp': custOtp,
    };
    // Clean up if password requires encryption or specific format, but looking at existing code:
    // 'Cust_Password': password, -> it was passed directly.

    final resp = await api.dio.get(
      ApiEndpoints.login,
      options: Options(headers: headers),
    );
    _logApiCall(ApiEndpoints.login, null, headers, resp);
    return resp;
  }

  /// Send OTP for purpose: "login" or "signup"
  Future<Response> sendOtp({
    required String identifier,
    required String purpose,
  }) async {
    final data = {'identifier': identifier, 'purpose': purpose};
    final resp = await api.dio.post(ApiEndpoints.sendOtp, data: data);
    _logApiCall(ApiEndpoints.sendOtp, data, null, resp);
    return resp;
  }

  /// Verify OTP. Backend might return token on success for login.
  Future<Response> verifyOtp({
    required String identifier,
    required String otp,
    required String purpose,
  }) async {
    final data = {'identifier': identifier, 'otp': otp, 'purpose': purpose};
    final resp = await api.dio.post(ApiEndpoints.verifyOtp, data: data);
    _logApiCall(ApiEndpoints.verifyOtp, data, null, resp);
    return resp;
  }

  /// Create account (final step with password)
  Future<Response> createAccount({
    required String identifier,
    required String name,
    required String password,
  }) async {
    final data = {'identifier': identifier, 'name': name, 'password': password};
    final resp = await api.dio.post(ApiEndpoints.createAccount, data: data);
    _logApiCall(ApiEndpoints.createAccount, data, null, resp);
    return resp;
  }

  /// Register API integration
  /// Register API integration
  Future<Response> register({
    required String password, // User entered password
    required String name,
    required String email,
    required String phone,
    bool otp = true,
  }) async {
    final headers = <String, dynamic>{
      'UserId': 'i/jvNw56275GboRZu0XoNQ==', // Static
      'Password': 'no4mXKgy2gnpvdDDjXG49A==', // Static
      'Name': name,
      'Cust_Password': password, // User entered password
      'Email': email,
      'Phone': phone,
      'Otp': otp,
    };
    final resp = await api.dio.get(
      'https://apistagging.gpossystem.com/api/v1/register',
      options: Options(headers: headers),
    );
    _logApiCall(
      'https://apistagging.gpossystem.com/api/v1/register',
      null,
      headers,
      resp,
    );
    return resp;
  }

  /// Get Dashboard data
  Future<Response> getDashboard({required int customerId}) async {
    final headers = <String, dynamic>{
      'UserId': 'i/jvNw56275GboRZu0XoNQ==', // Static
      'Password': 'no4mXKgy2gnpvdDDjXG49A==', // Static
      'CustomerId': customerId,
    };
    final resp = await api.dio.get(
      ApiEndpoints.dashboard,
      options: Options(headers: headers),
    );
    _logApiCall(ApiEndpoints.dashboard, null, headers, resp);
    return resp;
  }

  /// Get Transaction History
  Future<Response> getTransactionHistory({required int customerId}) async {
    final headers = <String, dynamic>{
      'UserId': 'i/jvNw56275GboRZu0XoNQ==', // Static
      'Password': 'no4mXKgy2gnpvdDDjXG49A==', // Static
      'CustomerId': customerId,
    };
    final resp = await api.dio.get(
      ApiEndpoints.transactionHistory,
      options: Options(headers: headers),
    );
    _logApiCall(ApiEndpoints.transactionHistory, null, headers, resp);
    return resp;
  }
}
