// lib/screens/tabs/barcode_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../models/user.dart';
import '../../widgets/edit_profile_sheet.dart';
class BarcodeTabContent extends StatefulWidget {
  const BarcodeTabContent({super.key});

  @override
  State<BarcodeTabContent> createState() => _BarcodeTabContentState();
}

class _BarcodeTabContentState extends State<BarcodeTabContent> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _qrData;

  @override
  void initState() {
    super.initState();
    _loadQrData();
  }

  Future<void> _loadQrData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (mounted) {
        // Fetch dashboard data and latest user data
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await Future.wait([
          auth.fetchDashboard(context),
          auth.fetchLatestUserData(context),
        ]);

        final qrString = _generateQrData(context);
        Map<String, dynamic> data = {};
        if (qrString.isNotEmpty) {
          try {
            data = jsonDecode(qrString);
          } catch (e) {
            print("Error decoding QR data: $e");
          }
        }

        setState(() {
          _qrData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<File?> _generateQrFile() async {
    try {
      final qrData = _generateQrData(context);
      if (qrData.isEmpty) {
        throw Exception("No QR data");
      }

      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          color: const Color(0xFF000000),
          gapless: true,
          embeddedImageStyle: null,
          embeddedImage: null,
        );

        // Generate image data
        final picData = await painter.toImageData(
          875,
          format: ui.ImageByteFormat.png,
        );
        if (picData == null) {
          throw Exception("Failed to generate QR image");
        }

        final pngBytes = picData.buffer.asUint8List();

        // Get temp directory
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/qr_code.png').create();
        await file.writeAsBytes(pngBytes);
        return file;
      } else {
        throw Exception("Invalid QR data");
      }
    } catch (e) {
      debugPrint("Error generating QR file: $e");
      return null;
    }
  }

  Future<void> _shareQrCode() async {
    if (!mounted) return;

    debugPrint("Share QR Code button pressed");
    try {
      final file = await _generateQrFile();
      if (file != null) {
        debugPrint("QR File generated at: ${file.path}");
        final xFile = XFile(file.path);
        // Using shareXFiles directly
        await Share.shareXFiles([xFile], text: 'Bevdaa Rewards QR Code');
        debugPrint("Share dialog initiated");
      } else {
        debugPrint("File generation returned null");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate image for sharing'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error in _shareQrCode: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveQrCode() async {
    if (!mounted) return;

    try {
      // Check permissions logic if needed, but Gal handles simple saving via putImage usually without explicit request on modern android
      // Still requesting photos on iOS/Android if permissions are denied just in case
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        // Request might trigger on older androids
        await Permission.storage.request();
      }
      if (Platform.isIOS ||
          (Platform.isAndroid && await Permission.photos.status.isDenied)) {
        await Permission.photos.request();
      }

      final file = await _generateQrFile();
      if (file != null) {
        await Gal.putImage(file.path, album: 'Bevdaa');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR code saved to gallery'),
              backgroundColor: AppTheme.primary,
            ),
          );
        }
      } else {
        throw Exception("Failed to generate file");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving QR code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getUserName(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.currentUser != null) {
      final firstName = auth.currentUser!.firstName ?? '';
      final lastName = auth.currentUser!.lastName ?? '';
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) return fullName;
    }
    return _qrData?['name'] ?? 'User Name';
  }

  String _getUserPoints(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    // Prioritize dashbaord data as it is the source of truth for points
    if (auth.dashboardData != null) {
      return auth.dashboardData!.customerPoints.toString();
    }
    // Fallback to QR data if available
    return _qrData?['points']?.toString() ?? '0';
  }

  String _generateQrData(BuildContext context) {
    // Generate JSON for QR code
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser != null) {
      final user = auth.currentUser!;
      final Map<String, dynamic> data = {
        "first_name": user.firstName ?? '',
        "last_name": user.lastName ?? '',
        "email_id": user.email ?? '',
        "contact_id": user.contactId,
        "customer_id": user.customerId,
      };
      return jsonEncode(data);
    }
    // Fallback if no user loaded (should generally rely on AuthProvider)
    return '';
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Provider.of<AuthProvider>(context, listen: false).clearAuth();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/auth', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              final messenger = ScaffoldMessenger.of(context);
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              final success = await authProvider.deleteAccount(context);

              if (success && mounted) {
                // Return to login screen
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/auth', (route) => false);
                // Show snackbar after navigation starts so it appears on the new route
                messenger.showSnackBar(
                  const SnackBar(content: Text('Account deleted successfully')),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Container(
        color: Colors.white,
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      );
    }

    if (_error != null) {
      final isNetworkError =
          _error!.toLowerCase().contains('network') ||
          _error!.toLowerCase().contains('connection') ||
          _error!.toLowerCase().contains('timeout');

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isNetworkError ? Icons.wifi_off : Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                isNetworkError ? 'Network Error' : 'Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontFamily: 'Roboto Flex',
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Roboto Flex',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadQrData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_qrData == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: 'Roboto Flex',
          ),
        ),
      );
    }

    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto Flex',
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 24, color: AppTheme.primary),
                      onPressed: () => _showEditProfileSheet(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_2, size: 28, color: AppTheme.primary),
                      onPressed: () => _showQrBottomSheet(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // User Info Card with red shadow rectangle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.1),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 120, // Match SVG height
                child: Stack(
                  children: [
                    // Background shadow rectangle
                    SvgPicture.asset(
                      'assets/images/red_shadow_rectangle.svg',
                      width: double.infinity,
                      height: 177,
                      fit: BoxFit.fill,
                    ),
                    // Content
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getUserName(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto Flex',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_getUserPoints(context)} Points Available',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Roboto Flex',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Detailed User Info
          if (user != null) ...[
            _buildInfoRow('First Name', user.firstName ?? 'N/A'),
            _buildInfoRow('Last Name', user.lastName ?? 'N/A'),
            _buildInfoRow('Birthday', _formatDate(user.birthDate) ?? 'N/A'),
            _buildInfoRow('Address', _formatAddress(user)),
          ],

          const SizedBox(height: 32),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto Flex',
                    color: Colors.red,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Delete Account Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _deleteAccount,
                icon: const Icon(Icons.delete_forever, color: Colors.grey),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto Flex',
                    color: Colors.grey,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String? _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    if (dateStr.contains('T')) {
      return dateStr.split('T')[0];
    }
    return dateStr;
  }

  String _formatAddress(User user) {
    List<String> parts = [];
    if (user.address1 != null && user.address1!.isNotEmpty) parts.add(user.address1!);
    if (user.address2 != null && user.address2!.isNotEmpty) parts.add(user.address2!);
    if (user.city != null && user.city!.isNotEmpty) parts.add(user.city!);
    if (user.stateRegion != null && user.stateRegion!.isNotEmpty) parts.add(user.stateRegion!);
    if (user.country != null && user.country!.isNotEmpty) parts.add(user.country!);
    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontFamily: 'Roboto Flex',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto Flex',
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const EditProfileSheet(),
    );
  }

  void _showQrBottomSheet(BuildContext context) {
    Scaffold.of(context).showBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Rewards QR Code',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto Flex',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan at checkout to earn or redeem points',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'Roboto Flex',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: QrImageView(
                      data: _generateQrData(context),
                      version: QrVersions.auto,
                      size: 240.0,
                      gapless: false,
                      backgroundColor: Colors.white,
                      errorStateBuilder: (cxt, err) {
                        return const Center(
                          child: Text(
                            "Error generating QR code",
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _shareQrCode();
                            },
                            icon: SvgPicture.asset(
                              'assets/images/share.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppTheme.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: const Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto Flex',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                                side: const BorderSide(
                                  color: AppTheme.primary,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _saveQrCode();
                            },
                            icon: SvgPicture.asset(
                              'assets/images/download.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppTheme.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto Flex',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                                side: const BorderSide(
                                  color: AppTheme.primary,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
