import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class LandlordManagementScreen extends StatefulWidget {
  const LandlordManagementScreen({super.key});

  @override
  State<LandlordManagementScreen> createState() =>
      _LandlordManagementScreenState();
}

class _LandlordManagementScreenState extends State<LandlordManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  int _numberOfProperties = 1;
  String _managementType = 'Full Management';
  bool _isSubmitting = false;

  static const List<String> _managementTypes = [
    'Full Management',
    'Tenant Find Only',
    'Rent Collection',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _firestoreService.submitManagementRequest(
        propertyAddress: _addressController.text.trim(),
        numberOfProperties: _numberOfProperties,
        managementType: _managementType,
        additionalNotes: _notesController.text.trim(),
        contactName: _contactNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(
            Icons.check_circle,
            color: AppTheme.successGreen,
            size: 56,
          ),
          title: const Text(
            'Request Submitted!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
          content: const Text(
            'Thank you! Our team will review your management request and get in touch within 24 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMedium),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/home');
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryNavy,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info Banner ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryNavy.withOpacity(0.1),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primaryNavy),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Let DSS Lets manage your property. We find tenants, '
                        'handle paperwork, and guarantee your rent — so you '
                        'can sit back and relax.',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ═══════════════════════════════════════
              // Section 1 — Property Info
              // ═══════════════════════════════════════
              _buildSectionHeader('Property Information'),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Property Address',
                  hintText: 'Full address of the property to manage',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter the property address'
                    : null,
              ),
              const SizedBox(height: 14),

              // Number of Properties counter
              Row(
                children: [
                  const Text(
                    'Number of Properties',
                    style: TextStyle(fontSize: 14, color: AppTheme.textDark),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.textMedium.withOpacity(0.3)),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _numberOfProperties > 1
                              ? () => setState(() => _numberOfProperties--)
                              : null,
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: _numberOfProperties > 1
                                ? AppTheme.primaryNavy
                                : AppTheme.textMedium.withOpacity(0.3),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '$_numberOfProperties',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _numberOfProperties < 50
                              ? () => setState(() => _numberOfProperties++)
                              : null,
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: _numberOfProperties < 50
                                ? AppTheme.primaryNavy
                                : AppTheme.textMedium.withOpacity(0.3),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Management Type
              DropdownButtonFormField<String>(
                value: _managementType,
                decoration: const InputDecoration(
                  labelText: 'Management Type',
                  prefixIcon: Icon(Icons.manage_accounts),
                ),
                items: _managementTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _managementType = v!),
              ),
              const SizedBox(height: 14),

              // Additional Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  hintText:
                      'Any special requirements or information about the property...',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),

              // ═══════════════════════════════════════
              // Section 2 — Contact Details
              // ═══════════════════════════════════════
              _buildSectionHeader('Your Contact Details'),

              TextFormField(
                controller: _contactNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  final digits = v.replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 10) {
                    return 'Phone number must be at least 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _contactEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(v.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // ── Submit Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryNavy,
                          ),
                        )
                      : const Icon(Icons.manage_accounts),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Request Management',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
