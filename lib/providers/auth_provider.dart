// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/dashboard_data.dart';
import '../models/transaction_history.dart';
import '../utils/validators.dart';

enum AuthFlow {
  idle,
  sendingOtp,
  verifyingOtp,
  loggingIn,
  creatingAccount,
  changingPassword,
}

class AuthProvider with ChangeNotifier {
  final AuthService authService;

  AuthProvider(this.authService);

  // UI & flow state
  AuthFlow flow = AuthFlow.idle;
  bool uiBlocked = false;

  // Auth data
  String? token;
  User? currentUser;
  String? currentIdentifier; // phone/email being processed
  String? currentEmail;
  String? currentPhone;
  String? currentName; // user name being processed
  String? otpPurpose; // "login" or "signup"
  bool otpSent = false;
  String? receivedOtp; // For client-side verification

  // Dashboard data
  DashboardData? dashboardData;
  bool loadingDashboard = false;

  List<TransactionHistoryItem> transactionHistory = [];
  bool loadingTransactionHistory = false;

  double get totalPointsEarned {
    return transactionHistory
        .where((t) => t.collectedPoint > 0)
        .fold(0.0, (sum, t) => sum + t.collectedPoint);
  }

  double get totalPointsRedeemed {
    return transactionHistory
        .where((t) => t.collectedPoint < 0)
        .fold(0.0, (sum, t) => sum + t.collectedPoint.abs());
  }

  // ---- Helpers ----
  void _setUiBlocked(bool blocked) {
    uiBlocked = blocked;
    notifyListeners();
  }

  void _setFlow(AuthFlow f) {
    flow = f;
    notifyListeners();
  }

  Future<void> _saveToken(String t) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('auth_token', t);
    token = t;
  }

  Future<void> _saveUser(User user) async {
    final sp = await SharedPreferences.getInstance();
    // Save full user json
    await sp.setString('user_data', jsonEncode(user.toJson()));
    // Also save customer_id for quick check if needed, though user_data is enough
    if (user.customerId != null) {
      await sp.setInt('customer_id', user.customerId!);
    }

    // Maintain token compatibility if needed, but user said "dont use token to verify auth"
    if (token != null) {
      await sp.setString('auth_token', token!);
    }

    currentUser = user;
    notifyListeners();
  }

  Future<void> loadUser() async {
    final sp = await SharedPreferences.getInstance();
    final userStr = sp.getString('user_data');
    if (userStr != null && userStr.isNotEmpty) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userStr);
        currentUser = User.fromJson(userMap);

        // Restore token if it exists in prefs, just in case api service needs it
        if (currentUser?.customerId != null) {
          token = currentUser!.customerId.toString();
        } else {
          token = sp.getString('auth_token');
        }

        notifyListeners();
      } catch (e) {
        print("Error loading user: $e");
        await clearAuth();
      }
    }
  }

  // Renamed or deprecated loadToken in favor of loadUser
  Future<String?> loadToken() async {
    await loadUser();
    return token;
  }

  // Generic error dialog helper (caller must supply BuildContext)
  void _showError(BuildContext ctx, String message) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---- Public methods called by UI ----

  /// Login (Password or OTP)
  Future<bool> login({
    required String identifier,
    String? password,
    bool custOtp = false,
    String? countryCode,
    required BuildContext ctx,
  }) async {
    _setUiBlocked(true);
    _setFlow(
      AuthFlow.loggingIn,
    ); // reuse loggingIn flow or create new if needed
    try {
      final resp = await authService.login(
        identifier: identifier,
        password: password,
        custOtp: custOtp,
        countryCode: countryCode,
      );
      // Handle nested API response structure
      if (resp.statusCode == 200) {
        final responseData = resp.data;

        // Check if response has nested Data structure
        if (responseData is Map<String, dynamic>) {
          // First check outer Result
          final outerResult = responseData['Result'];
          if (outerResult == true && responseData.containsKey('Data')) {
            final innerData = responseData['Data'];

            bool isSuccess = false;
            String innerMsg = responseData['Msg']?.toString() ?? '';
            List<dynamic>? userList;
            Map<String, dynamic>? tokenSourceData;

            if (innerData is Map<String, dynamic>) {
              final innerResult = innerData['Result'];
              final innerStatus = innerData['Status'];
              innerMsg = innerData['Msg']?.toString() ?? innerMsg;

              if (innerResult == true && innerStatus == 200) {
                isSuccess = true;
                if (innerData.containsKey('Data') && innerData['Data'] is List) {
                  userList = innerData['Data'] as List;
                }
                tokenSourceData = innerData;
              }
            } else if (innerData is List) {
              isSuccess = true;
              userList = innerData;
              tokenSourceData = responseData;
            }

            if (isSuccess) {
              if (userList != null && userList.isNotEmpty) {
                final userData = userList.first;
                if (userData is Map<String, dynamic>) {
                  try {
                    currentUser = User.fromJson(userData);
                    notifyListeners();

                    // Handle OTP case
                    if (custOtp) {
                      var otp = userData['OTP']?.toString();
                      if (otp == null && tokenSourceData != null && tokenSourceData.containsKey('OTP')) {
                        otp = tokenSourceData['OTP']?.toString();
                      }
                      if (otp != null && otp.isNotEmpty) {
                        receivedOtp = otp;
                        notifyListeners();
                        return true;
                      }
                    }

                    // Handle Token
                    String? serverToken;
                    if (userData['istoken'] == true) {
                      serverToken = userData['tokenno'];
                    }
                    if (serverToken == null || serverToken.isEmpty) {
                      if (tokenSourceData != null && tokenSourceData.containsKey('Token')) {
                        serverToken = tokenSourceData['Token'] as String?;
                      }
                    }

                    // Save user data
                    await _saveUser(currentUser!);

                    // Check customer_id for auth verification as requested
                    if (currentUser!.customerId != null) {
                      return true;
                    } else {
                      _showError(ctx, "Login succeeded but Customer ID missing.");
                      return false;
                    }
                  } catch (e) {
                    print("Error parsing user: $e");
                    _showError(ctx, "Error parsing user data received from server.");
                    return false;
                  }
                }
              }
            } else {
              // Inner failure
              final errorMsg = innerMsg.isNotEmpty
                  ? innerMsg
                  : 'Authentication failed. Please check your credentials and try again.';
              _showError(ctx, errorMsg);
              return false;
            }
          }
        }

        // Fallback or explicit token check from previous logic (if the structure is different than expected)
        // If we reached here, it means we didn't return true from above block.

        // ... (Keep existing fallback if needed, or just fail if strict structure)

        _showError(ctx, responseData['Msg']?.toString() ?? 'Login failed');
        return false;
      } else {
        _showError(ctx, resp.data?.toString() ?? 'Login failed');
        return false;
      }
    } on DioException catch (e) {
      // Handle DioException with nested response structure
      if (e.response?.statusCode == 200 && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('Data')) {
          final innerData = responseData['Data'];
          if (innerData is Map<String, dynamic>) {
            final innerMsg = innerData['Msg']?.toString() ?? '';
            if (innerMsg.isNotEmpty) {
              _showError(ctx, innerMsg);
              return false;
            }
          }
        }
      }

      final msg =
          e.response?.data?.toString() ??
          e.message ??
          'Login failed. Please check your credentials and try again.';
      _showError(ctx, msg);
      return false;
    } catch (e) {
      _showError(ctx, e.toString());
      return false;
    } finally {
      _setUiBlocked(false);
      _setFlow(AuthFlow.idle);
    }
  }

  // Auth data (continued)
  String? verificationToken; // Store X-OTP-Token here from sendOtp
  String? signupOtp; // Store the OTP entered during signup here

  /// Send OTP (for login or signup)
  Future<bool> sendOtp({
    required String identifier,
    required String purpose, // "login" or "signup"
    String? countryCode,
    required BuildContext ctx,
  }) async {
    _setUiBlocked(true);
    _setFlow(AuthFlow.sendingOtp);
    try {
      final resp = await authService.sendOtp(
        identifier: identifier,
        purpose: purpose,
        countryCode: countryCode,
      );

      // Check response status
      if (resp.statusCode == 200) {
        final data = resp.data;

        // Logic: Check Result and Data.Result
        // Structure: { Result: true, Status: 0, Msg: "", Data: { Result: false, ... } }

        bool outerResult = data['Result'] == true;
        bool innerResult = false;
        String errorMsg = '';

        if (data['Data'] != null && data['Data'] is Map<String, dynamic>) {
          innerResult = data['Data']['Result'] == true;
          errorMsg = data['Data']['Msg']?.toString() ?? '';

          // Current logic req: "check for both result, and if both are true then only start verificatin ui"
        } else if (outerResult && data['Data'] is String) {
          innerResult = true;
          errorMsg = '';
        }

        if (outerResult && innerResult) {
          // Success!
          // Extract X-OTP-Token from headers
          // headers map keys might be case-insensitive or not, usually lower case in Dio if configured,
          // but let's check carefully.
          // Headers in Dio response are usually in `resp.headers`.
          // `resp.headers.value('X-OTP-Token')`

          final otpToken = resp.headers.value('X-OTP-Token');
          if (otpToken != null) {
            verificationToken = otpToken;
          } else {
            // If missing, maybe it's in body? But requirement says "response header will have X-OTP-Token"
            debugPrint(
              'Warning: X-OTP-Token header missing in sendOtp response',
            );
          }

          currentIdentifier = identifier;
          otpPurpose = purpose;
          otpSent = true;
          notifyListeners();
          return true;
        } else {
          // Failure
          // "otherwise show msg to user via toast"
          _showError(
            ctx,
            errorMsg.isNotEmpty
                ? errorMsg
                : (data['Msg']?.toString() ?? 'Send OTP failed'),
          );
          return false;
        }
      } else {
        _showError(ctx, resp.data?.toString() ?? 'Send OTP failed');
        return false;
      }
    } on DioException catch (e) {
      _showError(
        ctx,
        e.response?.data?.toString() ?? e.message ?? 'Send OTP failed',
      );
      return false;
    } catch (e) {
      _showError(ctx, 'An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setUiBlocked(false);
      _setFlow(AuthFlow.idle);
    }
  }

  /// Verify OTP (for login or signup).
  Future<bool> verifyOtp({
    required String otp,
    required BuildContext ctx,
  }) async {
    if (currentIdentifier == null || otpPurpose == null) {
      _showError(ctx, 'No identifier in progress. Please resend OTP.');
      return false;
    }

    // Check if we have verificationToken
    if (verificationToken == null) {
      // If we don't have token, maybe we can't verify?
      // "store that for later verifyOtp API( we need to pass there)"
      // Proceeding might fail, but let's try or show error?
      // Let's warn but try, or handle gracefully.
    }

    _setUiBlocked(true);
    _setFlow(AuthFlow.verifyingOtp);
    try {
      final resp = await authService.verifyOtp(
        identifier: currentIdentifier!,
        otp: otp,
        token:
            verificationToken ??
            '', // Pass empty if null, strict requirement likely fails
      );

      if (resp.statusCode == 200) {
        final responseData = resp.data;

        // Structure same as login:
        // { Result: true, ..., Data: { Result: true, Status: 200, Msg: "Auth Passed", Data: [User...], ... } }

        bool outerResult = responseData['Result'] == true;
        bool innerResult = false;
        String innerMsg = responseData['Msg']?.toString() ?? '';

        Map<String, dynamic>? innerData;

        if (responseData['Data'] != null &&
            responseData['Data'] is Map<String, dynamic>) {
          innerData = responseData['Data'];
          innerResult = innerData!['Result'] == true;
          innerMsg = innerData['Msg']?.toString() ?? innerMsg;
        } else if (outerResult && responseData['Data'] is List) {
          // If Data is directly a List and outer Result is true, treat innerResult as true
          innerResult = true;
        } else if (outerResult && responseData['Data'] == null) {
          // Explicit null data case from previous requirements
          innerResult = true;
        }

        if (outerResult && innerResult) {
          // Success

          // Let's check if there is User Data in the response
          bool userFound = false;
          User? parsedUser;

          // The response structure from verifyOtp might have the data at the root
          // e.g. { Result: true, Status: 0, Msg: "...", Data: [{...}] }
          // OR it might provide innerData if there is nested structure.

          List<dynamic>? userList;
          if (responseData['Data'] is List) {
            userList = responseData['Data'] as List;
          } else if (innerData != null && innerData['Data'] is List) {
            userList = innerData['Data'] as List;
          }

          if (userList != null && userList.isNotEmpty) {
            final userData = userList.first;
            if (userData is Map<String, dynamic>) {
              try {
                parsedUser = User.fromJson(userData);
                userFound = true;
              } catch (e) {
                print("Error parsing user from verifyOtp: $e");
              }
            }
          }

          if (userFound && parsedUser != null) {
            currentUser = parsedUser;

            // Only save the session automatically if the user is explicitly logging in.
            // For forgot password or signup workflows, keep it in memory only.
            if (otpPurpose == 'login') {
              await _saveUser(currentUser!);
            }

            notifyListeners();

            if (otpPurpose == 'login') {
              return true; // Will navigate to home
            } else {
              return true; // For signup flow, we successfully verified OTP. It will move to next step.
            }
          } else {
            // No customer found (e.g. Data: null)
            String msgToShow = innerMsg.isNotEmpty
                ? innerMsg
                : (responseData['Msg']?.toString() ??
                      'Verification Successful, No customer found!');
            _showError(ctx, msgToShow);
            return false;
          }
        } else {
          _showError(
            ctx,
            innerMsg.isNotEmpty
                ? innerMsg
                : (responseData['Msg']?.toString() ?? 'Verification failed'),
          );
          return false;
        }
      } else {
        _showError(ctx, resp.data?.toString() ?? 'Verify OTP failed');
        return false;
      }
    } on DioException catch (e) {
      _showError(
        ctx,
        e.response?.data?.toString() ?? e.message ?? 'Verify OTP failed',
      );
      return false;
    } catch (e) {
      _showError(ctx, e.toString());
      return false;
    } finally {
      _setUiBlocked(false);
      _setFlow(AuthFlow.idle);
    }
  }

  /// Create account (final step after signup OTP verifies)
  Future<bool> createAccount({
    required String identifier,
    required String name,
    required String password,
    required BuildContext ctx,
  }) async {
    _setUiBlocked(true);
    _setFlow(AuthFlow.creatingAccount);
    try {
      final resp = await authService.createAccount(
        identifier: identifier,
        name: name,
        password: password,
      );
      if (resp.statusCode == 200) {
        final data = resp.data;
        final serverToken = data['token'] as String?;
        if (serverToken != null && serverToken.isNotEmpty) {
          await _saveToken(serverToken);
          return true;
        } else {
          // account created but token missing — still a success, but caller may choose to navigate to login
          return true;
        }
      } else {
        _showError(ctx, resp.data?.toString() ?? 'Create account failed');
        return false;
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?.toString() ??
          e.message ??
          'Failed to create account. Please try again.';
      _showError(ctx, msg);
      return false;
    } catch (e) {
      _showError(ctx, e.toString());
      return false;
    } finally {
      _setUiBlocked(false);
      _setFlow(AuthFlow.idle);
    }
  }

  Future<bool> registerUser({
    required String phoneOrEmail,
    required String password,
    required String name,
    required String enteredOtp, // Added OTP field
    String? email,
    String? phone,
    String? countryCode,
    required BuildContext ctx,
  }) async {
    _setUiBlocked(true);
    _setFlow(AuthFlow.creatingAccount);
    try {
      // Determine phone or email
      String finalEmail = email ?? '';
      String finalPhone = phone ?? '';

      // If neither explicitly provided, derive from phoneOrEmail
      if (finalEmail.isEmpty && finalPhone.isEmpty) {
        if (Validators.isEmail(phoneOrEmail)) {
          finalEmail = phoneOrEmail;
          finalPhone = ''; // Explicitly blank
        } else {
          finalPhone = phoneOrEmail;
          finalEmail = ''; // Explicitly blank
        }
      } else {
        // If one was provided, ensure the other is blank if it was null
        if (email != null && phone == null) finalPhone = '';
        if (phone != null && email == null) finalEmail = '';
      }

      final resp = await authService.register(
        password: password,
        name: name,
        email: finalEmail,
        phone: finalPhone,
        token: verificationToken ?? '', // X-OTP-Token
        enteredOtp: enteredOtp,
        countryCode: countryCode,
      );
      if (resp.statusCode == 200) {
        final responseData = resp.data;
        if (responseData is Map<String, dynamic>) {
          final rootResult = responseData['Result'];
          final rootMsg = responseData['Msg']?.toString() ?? '';

          if (rootResult == false) {
            _showError(
              ctx,
              rootMsg.isNotEmpty ? rootMsg : 'Registration failed.',
            );
            return false;
          }

          // Handle nested Data structure if present and not null
          if (responseData.containsKey('Data') &&
              responseData['Data'] != null) {
            final innerData = responseData['Data'];
            if (innerData is Map<String, dynamic>) {
              final innerResult = innerData['Result'];
              final innerStatus = innerData['Status'];
              final innerMsg = innerData['Msg']?.toString() ?? '';

              if (innerResult == false ||
                  innerStatus == 401 ||
                  (innerStatus != null &&
                      innerStatus != 0 &&
                      innerStatus != 200)) {
                _showError(
                  ctx,
                  innerMsg.isNotEmpty ? innerMsg : 'Registration failed.',
                );
                return false;
              }
              if (innerResult == true) {
                // Registration success: Parse User
                if (innerData.containsKey('Data') &&
                    innerData['Data'] is List) {
                  final userList = innerData['Data'] as List;
                  if (userList.isNotEmpty) {
                    final userData = userList.first;
                    if (userData is Map<String, dynamic>) {
                      try {
                        currentUser = User.fromJson(userData);

                        await _saveUser(currentUser!);
                        notifyListeners();

                        if (currentUser!.customerId != null) {
                          return true;
                        } else {
                          _showError(
                            ctx,
                            "Registration succeeded but Customer ID missing.",
                          );
                          return false;
                        }
                      } catch (e) {
                        print("Error parsing user: $e");
                        _showError(
                          ctx,
                          "Error parsing user data received from server.",
                        );
                        return false;
                      }
                    }
                  }
                }
                // Fallback if no user data found but result was true
                return true;
              }
            }
          }
        }
        // Fallback: Success if statusCode == 200 and root Result was not false
        return true;
      } else {
        _showError(ctx, resp.data?.toString() ?? 'Registration failed');
        return false;
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?.toString() ?? e.message ?? 'Registration failed.';
      _showError(ctx, msg);
      return false;
    } catch (e) {
      _showError(ctx, e.toString());
      return false;
    } finally {
      _setUiBlocked(false);
      _setFlow(AuthFlow.idle);
    }
  }

  /// Resets the OTP state for UI logic (like closing/reopening bottom sheets)
  void resetOtpState() {
    otpSent = false;
    otpPurpose = null;
    // We optionally keep or reset currentIdentifier based on if we want to retain the typed value.
    // However, the sheet uses its own local controller for the input, so resetting currentIdentifier is fine.
    currentIdentifier = null;
    verificationToken = null;
    notifyListeners();
  }

  /// Clear auth (for logout)
  Future<void> clearAuth() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('auth_token');
    await sp.remove('user_data');
    await sp.remove('customer_id');

    token = null;
    currentUser = null;
    currentIdentifier = null;
    currentEmail = null;
    currentPhone = null;
    currentName = null;
    otpPurpose = null;
    otpSent = false;
    verificationToken = null;
    signupOtp = null;
    notifyListeners();
  }

  /// Change Password
  Future<bool> changePassword(String newPassword, BuildContext ctx) async {
    if (currentUser == null || currentUser!.customerId == null) {
      _showError(
        ctx,
        'Customer information not found. Cannot change password.',
      );
      return false;
    }

    _setUiBlocked(true);
    _setFlow(AuthFlow.changingPassword);

    try {
      final resp = await authService.changePassword(
        customerId: currentUser!.customerId!,
        newPassword: newPassword,
      );

      if (resp.statusCode == 200) {
        var responseData = resp.data;

        // Handle string response decoding if needed
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            print("Failed to decode response: $e");
          }
        }

        if (responseData is Map<String, dynamic>) {
          bool outerResult = responseData['Result'] == true;
          bool innerResult = false;
          String errorMsg = responseData['Msg']?.toString() ?? '';

          if (responseData['Data'] != null &&
              responseData['Data'] is Map<String, dynamic>) {
            final innerData = responseData['Data'];
            innerResult = innerData['Result'] == true;
            if (innerData['Msg'] != null &&
                innerData['Msg'].toString().isNotEmpty) {
              errorMsg = innerData['Msg'].toString();
            }
          } else if (outerResult) {
            innerResult = true;
          }

          if (outerResult && innerResult) {
            // Wipe the temporary auth state used passing the customer ID to the payload.
            // The user must explicitly log back in using their new credentials.
            await clearAuth();

            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    errorMsg.isNotEmpty
                        ? errorMsg
                        : 'Password changed successfully',
                  ),
                ),
              );
            }
            return true;
          } else {
            _showError(
              ctx,
              errorMsg.isNotEmpty ? errorMsg : 'Failed to change password.',
            );
            return false;
          }
        } else {
          _showError(ctx, 'Unexpected response format.');
          return false;
        }
      } else {
        _showError(ctx, resp.data?.toString() ?? 'Failed to change password.');
        return false;
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?.toString() ??
          e.message ??
          'Failed to change password.';
      _showError(ctx, msg);
      return false;
    } catch (e) {
      _showError(ctx, e.toString());
      return false;
    } finally {
      _setUiBlocked(false);
      _setFlow(AuthFlow.idle);
    }
  }

  /// Delete Account
  Future<bool> deleteAccount(BuildContext ctx) async {
    if (currentUser == null || currentUser!.customerId == null) {
      _showError(ctx, 'Customer information not found. Cannot delete account.');
      return false;
    }

    _setUiBlocked(true);
    notifyListeners();

    try {
      final resp = await authService.deleteAccount(
        customerId: currentUser!.customerId!,
      );

      if (resp.statusCode == 200) {
        var responseData = resp.data;

        // Handle case where response is returned as a plain string
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            print("Failed to decode response: $e");
          }
        }

        if (responseData is Map<String, dynamic>) {
          final result = responseData['Result'];
          final msg = responseData['Msg']?.toString() ?? '';

          bool isSuccess = false;
          if (result is bool) {
            isSuccess = result;
          } else if (result != null) {
            isSuccess = result.toString().toLowerCase() == 'true';
          }

          if (isSuccess) {
            // Delete success. Show message and log out.
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    msg.isNotEmpty ? msg : 'Account deleted successfully',
                  ),
                ),
              );
            }
            await clearAuth();
            return true;
          } else {
            // Delete failed based on logical Result
            _showError(ctx, msg.isNotEmpty ? msg : 'Failed to delete account.');
            return false;
          }
        } else {
          _showError(ctx, 'Unexpected response format.');
          return false;
        }
      } else {
        _showError(ctx, resp.data?.toString() ?? 'Failed to delete account.');
        return false;
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?.toString() ??
          e.message ??
          'Failed to delete account.';
      _showError(ctx, msg);
      return false;
    } catch (e) {
      _showError(ctx, e.toString());
      return false;
    } finally {
      _setUiBlocked(false);
      notifyListeners();
    }
  }

  /// Fetch dashboard data
  Future<void> fetchDashboard(BuildContext ctx) async {
    // If we don't have a user, try loading from prefs
    if (currentUser == null) {
      await loadUser();
    }

    if (currentUser == null || currentUser!.customerId == null) {
      // Cannot fetch dashboard without customerId
      return;
    }

    loadingDashboard = true;
    notifyListeners();

    try {
      final resp = await authService.getDashboard(
        customerId: currentUser!.customerId!,
      );

      if (resp.statusCode == 200) {
        final responseData = resp.data;
        if (responseData is Map<String, dynamic> &&
            responseData['Result'] == true &&
            responseData['Data'] != null) {
          dashboardData = DashboardData.fromJson(responseData['Data']);

          // Persist points to SharedPreferences as requested
          final sp = await SharedPreferences.getInstance();
          await sp.setInt('user_points', dashboardData!.customerPoints);
        }
      }
    } catch (e) {
      print("Error fetching dashboard: $e");
    } finally {
      loadingDashboard = false;
      notifyListeners();
    }
  }

  /// Fetch Transaction History
  Future<void> fetchTransactionHistory(BuildContext ctx) async {
    if (currentUser == null) {
      await loadUser();
    }
    if (currentUser == null || currentUser!.customerId == null) return;

    loadingTransactionHistory = true;
    notifyListeners();

    try {
      final resp = await authService.getTransactionHistory(
        customerId: currentUser!.customerId!,
      );
      if (resp.statusCode == 200) {
        final response = TransactionHistoryResponse.fromJson(resp.data);
        if (response.result) {
          final sortedData = response.data;
          sortedData.sort((a, b) {
            try {
              DateTime dateA = DateTime.parse(a.txnDate);
              DateTime dateB = DateTime.parse(b.txnDate);
              return dateB.compareTo(dateA);
            } catch (e) {
              return 0;
            }
          });
          transactionHistory = sortedData;
        } else {
          debugPrint('Transaction history API error: ${response.msg}');
        }
      }
    } catch (e) {
      debugPrint('Error fetching transaction history: $e');
    } finally {
      loadingTransactionHistory = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(User updatedUser, BuildContext ctx) async {
    if (currentUser == null || currentUser!.customerId == null) {
      _showError(ctx, 'Customer information not found. Cannot update profile.');
      return false;
    }

    _setUiBlocked(true);
    notifyListeners();
    try {
      final resp = await authService.updateCustomer(
        customerId: currentUser!.customerId!,
        firstName: updatedUser.firstName ?? '',
        lastName: updatedUser.lastName ?? '',
        birthday: updatedUser.birthDate,
        address: updatedUser.address1,
        city: updatedUser.city,
        state: updatedUser.stateRegion,
      );

      if (resp.statusCode == 200) {
        var responseData = resp.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            print("Failed to decode response: $e");
          }
        }

        if (responseData is Map<String, dynamic>) {
          bool outerResult = responseData['Result'] == true;
          bool innerResult = false;
          String errorMsg = responseData['Msg']?.toString() ?? '';

          if (responseData['Data'] != null && responseData['Data'] is Map<String, dynamic>) {
            final innerData = responseData['Data'];
            innerResult = innerData['Result'] == true;
            if (innerData['Msg'] != null && innerData['Msg'].toString().isNotEmpty) {
              errorMsg = innerData['Msg'].toString();
            }
          } else if (outerResult) {
            innerResult = true;
          }

          if (outerResult && innerResult) {
            currentUser = updatedUser;
            await _saveUser(currentUser!);
            notifyListeners();

            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    errorMsg.isNotEmpty ? errorMsg : 'Profile updated successfully',
                  ),
                ),
              );
            }
            return true;
          } else {
            _showError(ctx, errorMsg.isNotEmpty ? errorMsg : 'Failed to update profile.');
            return false;
          }
        } else {
           _showError(ctx, 'Unexpected response format.');
           return false;
        }
      } else {
        _showError(ctx, resp.data?.toString() ?? 'Failed to update profile.');
        return false;
      }
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Failed to update profile.';
      if (ctx.mounted) {
        _showError(ctx, msg);
      }
      return false;
    } catch (e) {
      if (ctx.mounted) {
        _showError(ctx, 'Failed to update profile: $e');
      }
      return false;
    } finally {
      _setUiBlocked(false);
      notifyListeners();
    }
  }

  /// Fetch latest user data from server
  Future<void> fetchLatestUserData(BuildContext ctx) async {
    if (currentUser == null || currentUser!.customerId == null) return;

    try {
      final resp = await authService.getCustomer(
        customerId: currentUser!.customerId!,
        phone: currentIdentifier ?? currentUser!.phone1 ?? currentUser!.cell,
      );

      if (resp.statusCode == 200) {
        final responseData = resp.data;
        if (responseData is Map<String, dynamic> &&
            responseData['Result'] == true &&
            responseData['Data'] != null) {
          
          final innerData = responseData['Data'];
          if (innerData is List && innerData.isNotEmpty) {
             final userData = innerData.first;
             if (userData is Map<String, dynamic>) {
               try {
                 currentUser = User.fromJson(userData);
                 await _saveUser(currentUser!);
                 notifyListeners();
               } catch (e) {
                 print("Error parsing user from GetCustomer: $e");
               }
             }
          }
        }
      }
    } catch (e) {
      print("Error fetching latest user data: $e");
    }
  }
}
