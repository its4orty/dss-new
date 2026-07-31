import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

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
  String _benefitType = 'Housing Benefit';
  DateTime? _moveDate;

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _moveDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _moveDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration submitted! (placeholder)'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Registration'),
        actions: [
          TextButton(
            onPressed: () => context.go('/tenant/saved'),
            child: const Text(
              'Saved',
              style: TextStyle(color: AppTheme.accentWhite),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/tenant/applications'),
            child: const Text(
              'Applications',
              style: TextStyle(color: AppTheme.accentWhite),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register as a Tenant',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in your details to register interest in DSS-friendly properties',
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
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter your name' : null,
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
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter your phone' : null,
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
                  if (v == null || v.isEmpty) return 'Please enter your email';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Preferred Area
              TextFormField(
                controller: _preferredAreaController,
                decoration: const InputDecoration(
                  labelText: 'Preferred Area',
                  hintText: 'e.g., Manchester, Birmingham',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) => v == null || v.isEmpty
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
                onChanged: (v) => setState(() => _benefitType = v!),
              ),
              const SizedBox(height: 16),

              // Move Date
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expected Move Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _moveDate != null
                        ? '${_moveDate!.day}/${_moveDate!.month}/${_moveDate!.year}'
                        : 'Tap to select date',
                    style: TextStyle(
                      color: _moveDate != null
                          ? AppTheme.textDark
                          : AppTheme.textMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Register'),
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
