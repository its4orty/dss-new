import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/property.dart';
import '../services/firestore_service.dart';

class PropertySearchScreen extends StatefulWidget {
  const PropertySearchScreen({super.key});

  @override
  State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _debounceTimer;
  String _query = '';
  bool _isSearching = false;
  List<Property>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Autofocus after first frame to ensure proper transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _query = '';
        _results = null;
        _isSearching = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _query = value;
      _isSearching = true;
      _error = null;
    });

    // Debounce: wait 500ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await _firestoreService.searchProperties(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _isSearching = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _error = 'Failed to search. Please try again.';
      });
    }
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    _focusNode.requestFocus();
    setState(() {
      _query = '';
      _results = null;
      _isSearching = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: true,
          style: const TextStyle(color: AppTheme.accentWhite),
          cursorColor: AppTheme.secondaryGold,
          decoration: const InputDecoration(
            hintText: 'Search by area, postcode, or keyword...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ── No query yet ──
    if (_query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 72,
              color: AppTheme.textMedium.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Start typing to search',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter an area, postcode, or keyword',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMedium.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    // ── Searching (loading) ──
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.primaryNavy,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMedium,
              ),
            ),
          ],
        ),
      );
    }

    // ── Error ──
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: AppTheme.errorRed,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _performSearch(_query),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ── No results ──
    if (_results == null || _results!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 72,
              color: AppTheme.textMedium.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No properties match your search',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMedium,
              ),
            ),
          ],
        ),
      );
    }

    // ── Search Results ──
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${_results!.length} propert${_results!.length == 1 ? 'y' : 'ies'} found',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: _results!.length,
            itemBuilder: (context, index) {
              return _SearchResultCard(property: _results![index]);
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Search Result Card — same design as Property List card
// ═══════════════════════════════════════════════════════════════
class _SearchResultCard extends StatelessWidget {
  final Property property;

  const _SearchResultCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        property.images.isNotEmpty && property.images.first.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/properties/${property.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Property Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: property.images.first,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 180,
                            color: AppTheme.primaryNavy.withOpacity(0.08),
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 180,
                            color: AppTheme.primaryNavy.withOpacity(0.08),
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        )
                      : Container(
                          height: 180,
                          color: AppTheme.primaryNavy.withOpacity(0.08),
                          child: const Icon(
                            Icons.home_rounded,
                            size: 56,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                ),
                // ── DSS Accepted Badge ──
                if (property.available)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'DSS Accepted',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // ── Rent Price Badge ──
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '£${property.rent.toStringAsFixed(0)} PCM',
                      style: const TextStyle(
                        color: AppTheme.secondaryGold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Property Details ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.textMedium,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.postcode.isNotEmpty
                              ? '${property.address}, ${property.postcode}'
                              : property.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _SearchInfoChip(
                        icon: Icons.bed_rounded,
                        label:
                            '${property.bedrooms} Bed${property.bedrooms != 1 ? 's' : ''}',
                      ),
                      const SizedBox(width: 14),
                      _SearchInfoChip(
                        icon: Icons.bathtub_rounded,
                        label:
                            '${property.bathrooms} Bath${property.bathrooms != 1 ? 's' : ''}',
                      ),
                      const Spacer(),
                      Text(
                        '£${property.rent.toStringAsFixed(0)} PCM',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.secondaryGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/properties/${property.id}'),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryNavy),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SearchInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppTheme.textMedium),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMedium,
          ),
        ),
      ],
    );
  }
}
