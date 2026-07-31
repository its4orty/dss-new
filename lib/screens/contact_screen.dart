import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // ── Helpers ──

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Call DSS Lets?'),
        content: const Text('This will open your phone dialler to call\n01202 000000.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Call'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final uri = Uri.parse('tel:+441202000000');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  // ────────────────────────────────────────────────────────────
  // Contact Form Bottom Sheet
  // ────────────────────────────────────────────────────────────

  void _showContactForm() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (buildCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(buildCtx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Send us a Message',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'We\'ll get back to you within 24 hours',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 14),

                      // Email
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter your email';
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Phone
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Please enter your phone number' : null,
                      ),
                      const SizedBox(height: 14),

                      // Message
                      TextFormField(
                        controller: messageCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Your Message',
                          prefixIcon: Icon(Icons.message_outlined),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Please enter a message' : null,
                      ),
                      const SizedBox(height: 20),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: AppTheme.accentWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    await _firestoreService.submitContactMessage(
                                      name: nameCtrl.text.trim(),
                                      email: emailCtrl.text.trim(),
                                      phone: phoneCtrl.text.trim(),
                                      message: messageCtrl.text.trim(),
                                    );
                                    if (buildCtx.mounted) Navigator.pop(buildCtx);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Row(
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.white),
                                              SizedBox(width: 10),
                                              Text('Message sent! We\'ll get back to you soon.'),
                                            ],
                                          ),
                                          backgroundColor: AppTheme.successGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (buildCtx.mounted) {
                                      ScaffoldMessenger.of(buildCtx).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.error_outline, color: Colors.white),
                                              const SizedBox(width: 10),
                                              Expanded(child: Text('Failed to send: $e')),
                                            ],
                                          ),
                                          backgroundColor: AppTheme.errorRed,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Send Message', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Current day helper ──

  bool _isToday(int weekday) {
    return DateTime.now().weekday == weekday;
  }

  // ────────────────────────────────────────────────────────────
  // Build
  // ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              color: AppTheme.primaryNavy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get in Touch',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.accentWhite,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "We're here to help you find your next home",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.accentWhite.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            // ── Action Tiles ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                children: [
                  // Row 1: Call + WhatsApp
                  Row(
                    children: [
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.phone_rounded,
                          title: 'Call Us',
                          subtitle: '01202 000000',
                          color: AppTheme.primaryNavy,
                          onTap: _launchPhone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.chat_bubble_rounded,
                          title: 'WhatsApp',
                          subtitle: 'Chat with us',
                          color: const Color(0xFF25D366),
                          onTap: () => _launchExternalUrl('https://wa.me/447000000000'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Email + Form
                  Row(
                    children: [
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.email_rounded,
                          title: 'Email Us',
                          subtitle: 'info@dsslets.co.uk',
                          color: const Color(0xFFEA4335),
                          onTap: () => _launchExternalUrl(
                            'mailto:info@dsslets.co.uk?subject=DSS%20Lets%20Enquiry',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.edit_note_rounded,
                          title: 'Contact Form',
                          subtitle: 'Send us a message',
                          color: const Color(0xFF6C63FF),
                          onTap: _showContactForm,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Office Hours ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.accentWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: AppTheme.primaryNavy, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Office Hours',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildOfficeHourRow('Monday – Friday', '9:00 AM – 6:00 PM',
                        isToday: _isToday(DateTime.monday) ||
                            _isToday(DateTime.tuesday) ||
                            _isToday(DateTime.wednesday) ||
                            _isToday(DateTime.thursday) ||
                            _isToday(DateTime.friday)),
                    const Divider(height: 20),
                    _buildOfficeHourRow('Saturday', '10:00 AM – 4:00 PM',
                        isToday: _isToday(DateTime.saturday)),
                    const Divider(height: 20),
                    _buildOfficeHourRow('Sunday', 'Closed',
                        isToday: _isToday(DateTime.sunday), isClosed: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Address ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.accentWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: AppTheme.primaryNavy, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Our Office',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'DSS Lets\n123 High Street\nBournemouth\nBH1 1AA\nUnited Kingdom',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMedium,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeHourRow(String day, String hours,
      {bool isToday = false, bool isClosed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isToday) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                day,
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                  color: isToday ? AppTheme.primaryNavy : AppTheme.textDark,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryGold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isClosed ? FontWeight.w600 : FontWeight.w400,
              color: isClosed ? AppTheme.errorRed : AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Action Tile Widget
// ────────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMedium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
