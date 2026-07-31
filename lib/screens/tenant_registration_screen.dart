import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/tenant.dart';
import '../services/firestore_service.dart';
import '../services/tenant_session.dart';

class TenantRegistrationScreen extends StatefulWidget {
  const TenantRegistrationScreen({super.key});

  @override
  State<TenantRegistrationScreen> createState() =>
      _TenantRegistrationScreenState();
}

class _TenantRegistrationScreenState extends State<TenantRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _preferredAreaController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  String _benefitType = 'Housing Benefit';
  DateTime? _moveDate;
  bool _isSubmitting = false;

  final List<String> _benefitTypes = [
    'Housing Benefit',
    'Universal Credit',
    'PIP',
    'ESA',
    'Other',
  ];

  @override
  void dispose() {
    _fullnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _preferredAreaController.dispose();
    super.dispose();
  }

  // ── Date Picker ────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _moveDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.secondaryGold,
              onPrimary: AppTheme.primaryNavy,
              surface: AppTheme.accentWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _moveDate = picked);
    }
  }

  // ── Submit ─────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final tenant = Tenant(
        fullname: _fullnameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        preferredArea: _preferredAreaController.text.trim(),
        benefitType: _benefitType,
        moveDate: _moveDate,
      );

      final tenantId = await _firestoreService.registerTenant(tenant);

      // Persist the tenant ID locally so saved/applications screens
      // know which tenant is active.
      await TenantSession.setTenantId(tenantId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      // Navigate to saved properties screen
      context.go('/tenant/saved');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Register as Tenant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Icon(Icons.person_add_alt_1,
                  size: 48, color: AppTheme.secondaryGold),
              const SizedBox(height: 12),
              Text(
                'Register as a Tenant',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in your details to register interest '
                'in DSS-friendly properties',
                style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
              ),
              const SizedBox(height: 24),

              // Full Name
              TextFormField(
                controller: _fullnameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Please enter your full name'
                        : null,
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
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
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(v.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Preferred Area
              TextFormField(
                controller: _preferredAreaController,
                decoration: const InputDecoration(
                  labelText: 'Preferred Area',
                  hintText: 'e.g., Bournemouth, Poole',
                  prefixIcon: Icon(Icons.location_on),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Please enter a preferred area'
                        : null,
              ),
              const SizedBox(height: 16),

              // Benefit Type
              DropdownButtonFormField<String>(
                value: _benefitType,
                decoration: const InputDecoration(
                  labelText: 'Benefit Type',
                  prefixIcon: Icon(Icons.account_balance),
                ),
                items: _benefitTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _benefitType = v);
                },
              ),
              const SizedBox(height: 16),

              // Move Date
              InkWell(
                onTap: _isSubmitting ? null : _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expected Move Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _moveDate != null
                        ? '${_moveDate!.day.toString().padLeft(2, '0')}/'
                            '${_moveDate!.month.toString().padLeft(2, '0')}/'
                            '${_moveDate!.year}'
                        : 'Tap to select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: _moveDate != null
                          ? AppTheme.textDark
                          : AppTheme.textMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
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
                      : const Icon(Icons.person_add),
                  label: Text(
                    _isSubmitting ? 'Registering…' : 'Register',
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
