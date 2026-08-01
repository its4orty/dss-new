import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/property.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/image_utils.dart';

class AdminEditPropertyScreen extends StatefulWidget {
  final String? propertyId;
  const AdminEditPropertyScreen({super.key, this.propertyId});
  @override
  State<AdminEditPropertyScreen> createState() => _AdminEditPropertyScreenState();
}

class _AdminEditPropertyScreenState extends State<AdminEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirestoreService();
  final _picker = ImagePicker();
  final _title = TextEditingController(), _address = TextEditingController(), _postcode = TextEditingController();
  final _rent = TextEditingController(), _deposit = TextEditingController(), _description = TextEditingController(), _imageUrl = TextEditingController();
  int _bedrooms = 1, _bathrooms = 1;
  String _furnished = 'Unfurnished';
  bool _available = true, _loading = false, _initialising = true, _picking = false;
  List<String> _images = [];
  static const _furnishedOptions = ['Fully Furnished', 'Part Furnished', 'Unfurnished'];

  @override
  void initState() { super.initState(); _loadProperty(); }
  @override
  void dispose() { for (final c in [_title, _address, _postcode, _rent, _deposit, _description, _imageUrl]) c.dispose(); super.dispose(); }

  Future<void> _loadProperty() async {
    if (widget.propertyId != null) {
      try { final p = await _service.getPropertyById(widget.propertyId!); if (p != null) _fill(p); }
      catch (e) { if (mounted) _showError(e); }
    }
    if (mounted) setState(() => _initialising = false);
  }
  void _fill(Property p) {
    _title.text = p.title; _address.text = p.address; _postcode.text = p.postcode;
    _rent.text = p.rent.toStringAsFixed(0); if (p.deposit != null) _deposit.text = p.deposit!.toStringAsFixed(0);
    _description.text = p.description; _bedrooms = p.bedrooms < 1 ? 1 : p.bedrooms; _bathrooms = p.bathrooms < 1 ? 1 : p.bathrooms;
    _furnished = _furnishedOptions.contains(p.furnishedStatus) ? p.furnishedStatus : 'Unfurnished'; _available = p.available; _images = List.of(p.images);
  }
  void _showError(Object e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.errorRed));

  Future<void> _pickPhoto() async {
    setState(() => _picking = true);
    try {
      // image_picker performs the native resize and JPEG compression before bytes are read.
      final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 70);
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (mounted) setState(() => _images.add('data:image/jpeg;base64,${base64Encode(bytes)}'));
      }
    } catch (e) { if (mounted) _showError(e); }
    finally { if (mounted) setState(() => _picking = false); }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final p = Property(title: _title.text.trim(), address: _address.text.trim(), postcode: _postcode.text.trim(), bedrooms: _bedrooms, bathrooms: _bathrooms,
      rent: double.parse(_rent.text.trim()), deposit: _deposit.text.trim().isEmpty ? null : double.parse(_deposit.text.trim()), description: _description.text.trim(), images: _images,
      furnishedStatus: _furnished, available: _available);
    try {
      if (widget.propertyId == null) await _service.createProperty(p); else await _service.updateProperty(widget.propertyId!, p);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.propertyId == null ? 'Property created' : 'Property updated'), backgroundColor: AppTheme.successGreen)); Navigator.pop(context, true); }
    } catch (e) { if (mounted) _showError(e); } finally { if (mounted) setState(() => _loading = false); }
  }
  Widget _field(TextEditingController c, String label, {int maxLines = 1, TextInputType? type, String? Function(String?)? validator}) => Padding(
    padding: const EdgeInsets.only(bottom: 14), child: TextFormField(controller: c, maxLines: maxLines, keyboardType: type, validator: validator ?? (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), filled: true)));
  Widget _counter(String label, int value, void Function(int) setValue) => Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))), IconButton(onPressed: value > 1 ? () => setValue(value - 1) : null, icon: const Icon(Icons.remove_circle_outline)), Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), IconButton(onPressed: () => setValue(value + 1), icon: const Icon(Icons.add_circle_outline))]);

  Widget _photosSection() {
    final imagePaths = _images.where((path) => !isVideoPath(path)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      SizedBox(height: 104, child: imagePaths.isEmpty ? const Center(child: Text('No photos added yet')) : ListView.separated(scrollDirection: Axis.horizontal, itemCount: imagePaths.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (context, index) => Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: _imageWidget(imagePaths[index], width: 104, height: 104)),
        Positioned(right: 2, top: 2, child: InkWell(onTap: () => setState(() => _images.remove(imagePaths[index])), child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 20)))),
      ]))),
    const SizedBox(height: 8),
    OutlinedButton.icon(onPressed: _picking ? null : _pickPhoto, icon: _picking ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_photo_alternate_outlined), label: const Text('Add Photo')),
    const SizedBox(height: 8),
    Row(children: [Expanded(child: TextField(controller: _imageUrl, decoration: const InputDecoration(labelText: 'Or paste image URL', border: OutlineInputBorder(), filled: true), keyboardType: TextInputType.url)), const SizedBox(width: 8), IconButton(icon: const Icon(Icons.add_circle, color: AppTheme.primaryNavy, size: 32), onPressed: () { final u = _imageUrl.text.trim(); if (u.isNotEmpty) { setState(() => _images.add(u)); _imageUrl.clear(); } })]),
  ]);

  Widget _imageWidget(String source, {required double width, required double height}) {
    if (source.startsWith('data:')) { try { return Image.memory(base64Decode(source.substring(source.indexOf(',') + 1)), width: width, height: height, fit: BoxFit.cover); } catch (_) {} }
    return Image.network(resolvePropertyImageUrl(source), width: width, height: height, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.propertyId == null ? 'Add Property' : 'Edit Property')),
    body: _initialising ? const Center(child: CircularProgressIndicator()) : Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(18), children: [
      _field(_title, 'Title'), _field(_address, 'Address'), _field(_postcode, 'Postcode'), _counter('Bedrooms', _bedrooms, (v) => setState(() => _bedrooms = v)), _counter('Bathrooms', _bathrooms, (v) => setState(() => _bathrooms = v)), const SizedBox(height: 8),
      _field(_rent, 'Monthly rent (£)', type: TextInputType.number, validator: (v) => double.tryParse(v?.trim() ?? '') == null ? 'Enter a valid amount' : null), _field(_deposit, 'Deposit (£) (optional)', type: TextInputType.number, validator: (v) => v!.trim().isEmpty || double.tryParse(v.trim()) != null ? null : 'Enter a valid amount'), _field(_description, 'Description', maxLines: 4),
      DropdownButtonFormField<String>(value: _furnished, decoration: const InputDecoration(labelText: 'Furnished Status', border: OutlineInputBorder(), filled: true), items: _furnishedOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _furnished = v!)), SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Available'), value: _available, onChanged: (v) => setState(() => _available = v)), const SizedBox(height: 12),
      _photosSection(), const SizedBox(height: 24), SizedBox(height: 50, child: ElevatedButton(onPressed: _loading ? null : _save, child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(widget.propertyId == null ? 'Create Property' : 'Save Changes')))
    ])));
}
