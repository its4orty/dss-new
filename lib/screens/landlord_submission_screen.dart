import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/landlord.dart';
import '../models/property.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class LandlordSubmissionScreen extends StatefulWidget {
  const LandlordSubmissionScreen({super.key});

  @override
  State<LandlordSubmissionScreen> createState() =>
      _LandlordSubmissionScreenState();
}

class _LandlordSubmissionScreenState extends State<LandlordSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Property Details
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Property Specs
  int _bedrooms = 2;
  int _bathrooms = 1;
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  String _furnishedStatus = 'Unfurnished';

  // Landlord Info
  final _landlordNameController = TextEditingController();
  final _landlordPhoneController = TextEditingController();
  final _landlordEmailController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _postcodeController.dispose();
    _descriptionController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _landlordNameController.dispose();
    _landlordPhoneController.dispose();
    _landlordEmailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Register the landlord
      final landlord = Landlord(
        name: _landlordNameController.text.trim(),
        phone: _landlordPhoneController.text.trim(),
        email: _landlordEmailController.text.trim(),
        propertyCount: 1,
      );
      final landlordId =
          await _firestoreService.registerLandlord(landlord);

      // 2. Create the property
      final property = Property(
        title: _titleController.text.trim(),
        address: _addressController.text.trim(),
        postcode: _postcodeController.text.trim(),
        bedrooms: _bedrooms,
        bathrooms: _bathrooms,
        rent: double.tryParse(_rentController.text.trim()) ?? 0,
        deposit: double.tryParse(_depositController.text.trim()),
        description: _descriptionController.text.trim(),
        furnishedStatus: _furnishedStatus,
        images: [],
        available: false, // not available until reviewed
      );
      final propertyId =
          await _firestoreService.createProperty(property);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property created! Now add photos.'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      // 3. Navigate to photos screen with property ID
      context.push('/landlord/photos', extra: propertyId);
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
      padding: const EdgeInsets.only(top: 24, bottom: 12),
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

  Widget _buildCounterRow({
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required int min,
    required int max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.accentWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.textMedium.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: value > min ? onDecrement : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: value > min
                      ? AppTheme.primaryNavy
                      : AppTheme.textMedium.withOpacity(0.3),
                ),
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? onIncrement : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: value < max
                      ? AppTheme.primaryNavy
                      : AppTheme.textMedium.withOpacity(0.3),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Property'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Text(
                'Submit Your Property',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'List your property for DSS tenants and get guaranteed rent',
                style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
              ),
              const SizedBox(height: 8),

              // ═══════════════════════════════════════
              // Section 1 — Property Details
              // ═══════════════════════════════════════
              _buildSectionHeader('Property Details'),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Property Title',
                  hintText: 'e.g., 2 Bedroom Flat in Bournemouth',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Full property address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter the address' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _postcodeController,
                decoration: const InputDecoration(
                  labelText: 'Postcode',
                  hintText: 'e.g., BH1 1AA',
                  prefixIcon: Icon(Icons.markunread_mailbox),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a postcode' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the property and key features...',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please add a description' : null,
              ),

              // ═══════════════════════════════════════
              // Section 2 — Property Specs
              // ═══════════════════════════════════════
              _buildSectionHeader('Property Specs'),

              Row(
                children: [
                  Expanded(
                    child: _buildCounterRow(
                      label: 'Bedrooms',
                      value: _bedrooms,
                      onDecrement: () =>
                          setState(() => _bedrooms = (_bedrooms - 1).clamp(0, 10)),
                      onIncrement: () =>
                          setState(() => _bedrooms = (_bedrooms + 1).clamp(0, 10)),
                      min: 0,
                      max: 10,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCounterRow(
                      label: 'Bathrooms',
                      value: _bathrooms,
                      onDecrement: () =>
                          setState(() => _bathrooms = (_bathrooms - 1).clamp(0, 5)),
                      onIncrement: () =>
                          setState(() => _bathrooms = (_bathrooms + 1).clamp(0, 5)),
                      min: 0,
                      max: 5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _rentController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Rent (\u00A3)',
                  hintText: 'e.g., 950',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter the rent';
                  }
                  final rent = double.tryParse(v.trim());
                  if (rent == null || rent <= 0) {
                    return 'Rent must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _depositController,
                decoration: const InputDecoration(
                  labelText: 'Deposit (\u00A3)',
                  hintText: 'e.g., 950',
                  prefixIcon: Icon(Icons.savings),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _furnishedStatus,
                decoration: const InputDecoration(
                  labelText: 'Furnished Status',
                  prefixIcon: Icon(Icons.chair),
                ),
                items: ['Unfurnished', 'Part Furnished', 'Furnished']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _furnishedStatus = v!),
              ),

              // ═══════════════════════════════════════
              // Section 3 — Landlord Info
              // ═══════════════════════════════════════
              _buildSectionHeader('Your Details'),

              TextFormField(
                controller: _landlordNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _landlordPhoneController,
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
                controller: _landlordEmailController,
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
                      : const Icon(Icons.arrow_forward),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Next: Upload Photos',
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
