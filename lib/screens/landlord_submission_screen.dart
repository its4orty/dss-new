import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class LandlordSubmissionScreen extends StatefulWidget {
  const LandlordSubmissionScreen({super.key});

  @override
  State<LandlordSubmissionScreen> createState() =>
      _LandlordSubmissionScreenState();
}

class _LandlordSubmissionScreenState extends State<LandlordSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _bedrooms = 2;
  int _bathrooms = 1;
  String _rent = '';
  String _furnishedStatus = 'Unfurnished';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property submitted for review! (placeholder)'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      context.go('/landlord/photos');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _postcodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Property'),
        actions: [
          TextButton(
            onPressed: () => context.go('/landlord/photos'),
            child: const Text(
              'Photos',
              style: TextStyle(color: AppTheme.accentWhite),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/landlord/management'),
            child: const Text(
              'Management',
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
                'Submit Your Property',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'List your property for DSS tenants and get guaranteed rent',
                style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
              ),
              const SizedBox(height: 24),

              // Property Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Property Title',
                  hintText: 'e.g., Modern 2-Bed Flat',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Full property address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter the address' : null,
              ),
              const SizedBox(height: 16),

              // Postcode
              TextFormField(
                controller: _postcodeController,
                decoration: const InputDecoration(
                  labelText: 'Postcode',
                  hintText: 'e.g., M1 1AA',
                  prefixIcon: Icon(Icons.markunread_mailbox),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter a postcode' : null,
              ),
              const SizedBox(height: 16),

              // Bedrooms & Bathrooms
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bedrooms'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(
                                  () => _bedrooms = (_bedrooms - 1).clamp(1, 10)),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$_bedrooms',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(
                                  () => _bedrooms = (_bedrooms + 1).clamp(1, 10)),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bathrooms'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(
                                  () => _bathrooms = (_bathrooms - 1).clamp(1, 5)),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$_bathrooms',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(
                                  () => _bathrooms = (_bathrooms + 1).clamp(1, 5)),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Rent
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Monthly Rent (£)',
                  hintText: 'e.g., 950',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _rent = v,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter the rent' : null,
              ),
              const SizedBox(height: 16),

              // Furnished Status
              DropdownButtonFormField<String>(
                value: _furnishedStatus,
                decoration: const InputDecoration(
                  labelText: 'Furnished Status',
                  prefixIcon: Icon(Icons.chair),
                ),
                items: ['Unfurnished', 'Part Furnished', 'Fully Furnished']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _furnishedStatus = v!),
              ),
              const SizedBox(height: 16),

              // Description
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
                    v == null || v.isEmpty ? 'Please add a description' : null,
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.real_estate_agent),
                  label: const Text('Submit Property'),
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
