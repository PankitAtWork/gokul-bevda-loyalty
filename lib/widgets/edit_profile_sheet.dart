import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _address1Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateRegionController;
  late TextEditingController _birthDateController;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _address1Controller = TextEditingController(text: user?.address1 ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _stateRegionController = TextEditingController(text: user?.stateRegion ?? '');
    
    String dob = user?.birthDate ?? '';
    if (dob.isNotEmpty) {
      try {
        if (dob.contains('T')) dob = dob.split('T')[0];
        DateTime parsedDate;
        if (dob.contains('-')) {
          parsedDate = DateTime.parse(dob);
        } else {
          parsedDate = DateFormat('MM/dd/yyyy').parse(dob);
        }
        dob = DateFormat('MM/dd/yyyy').format(parsedDate);
      } catch (e) {
        // If parsing fails, just keep the original string
      }
    }
    _birthDateController = TextEditingController(text: dob);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_birthDateController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('MM/dd/yyyy').parse(_birthDateController.text);
      } catch (e) {
        // ignore
      }
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _address1Controller.dispose();
    _cityController.dispose();
    _stateRegionController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = auth.currentUser;
      
      if (currentUser == null) return;

      // Create an updated user object
      final updatedUser = User(
        contactId: currentUser.contactId,
        spId: currentUser.spId,
        vendorId: currentUser.vendorId,
        employeeId: currentUser.employeeId,
        customerId: currentUser.customerId,
        contactType: currentUser.contactType,
        firstName: _firstNameController.text.trim(),
        middleName: currentUser.middleName,
        lastName: _lastNameController.text.trim(),
        gender: currentUser.gender,
        salutation: currentUser.salutation,
        phoneExt: currentUser.phoneExt,
        cell: currentUser.cell,
        phone1: currentUser.phone1,
        phone2: currentUser.phone2,
        beeper: currentUser.beeper,
        birthDate: _birthDateController.text.trim(),
        email: _emailController.text.trim(),
        marriageDate: currentUser.marriageDate,
        note: currentUser.note,
        address1: _address1Controller.text.trim(),
        address2: currentUser.address2,
        fax: currentUser.fax,
        city: _cityController.text.trim(),
        stateRegion: _stateRegionController.text.trim(),
        country: currentUser.country,
        zip: currentUser.zip,
        image: currentUser.image,
        nonActive: currentUser.nonActive,
        createUserId: currentUser.createUserId,
        createDateTime: currentUser.createDateTime,
        updateUserId: currentUser.updateUserId,
        updateDateTime: currentUser.updateDateTime,
        website: currentUser.website,
        gstNumber: currentUser.gstNumber,
        stateCode: currentUser.stateCode,
        isToken: currentUser.isToken,
        tokenNo: currentUser.tokenNo,
        tokenExpDate: currentUser.tokenExpDate,
        fintechVendor: currentUser.fintechVendor,
        ltPassword: currentUser.ltPassword,
      );

      final success = await auth.updateUserProfile(updatedUser, context);
      
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isEmail = false, bool isDate = false, bool isOptional = false, VoidCallback? onTap, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          suffixIcon: isDate ? const Icon(Icons.calendar_today, color: Colors.grey) : null,
        ),
        keyboardType: isEmail ? TextInputType.emailAddress : (isDate ? TextInputType.datetime : TextInputType.text),
        validator: (value) {
          if (!isOptional && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          if (isEmail && value != null && value.trim().isNotEmpty && !value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine bottom padding for keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 24, 
        left: 20, 
        right: 20,
        // Add padding at the bottom based on the keyboard
        bottom: bottomInset > 0 ? bottomInset + 16 : 24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto Flex',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              // Wrap in Flexible to allow scrolling if content is too large
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildTextField('First Name', _firstNameController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Last Name', _lastNameController)),
                        ],
                      ),
                      _buildTextField('Email', _emailController, isEmail: true),
                      _buildTextField('Birth Date (mm/dd/yyyy)', _birthDateController, isDate: true, isOptional: true, readOnly: true, onTap: () => _selectDate(context)),
                      _buildTextField('Address', _address1Controller, isOptional: true),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('City', _cityController, isOptional: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('State', _stateRegionController, isOptional: true)),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return ElevatedButton(
                  onPressed: auth.uiBlocked ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: auth.uiBlocked 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto Flex',
                        ),
                      ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
