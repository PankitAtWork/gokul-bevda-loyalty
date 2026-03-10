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
        // Fetch dashboard data to ensure points are up to date
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).fetchDashboard(context);

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

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your Rewards QR Code',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto Flex',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Instruction text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
            child: Text(
              'Scan at checkout to earn or redeem points',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Roboto Flex',
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          // QR Code
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

          const SizedBox(height: 40),

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

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareQrCode,
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
                    onPressed: _saveQrCode,
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

          const SizedBox(height: 24),

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
}
