import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property.dart';
import '../models/tenant.dart';
import '../models/landlord.dart';
import '../models/enquiry.dart';

class FirestoreService {
  final FirebaseFirestore db;

  FirestoreService({FirebaseFirestore? firestore})
      : db = firestore ?? FirebaseFirestore.instance;

  // ──────────────────────────────────────────────
  // Properties
  // ──────────────────────────────────────────────

  Future<List<Property>> getProperties() async {
    try {
      final snapshot = await db.collection('properties').get();
      return snapshot.docs
          .map((doc) => Property.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch properties: $e');
    }
  }

  Future<List<Property>> getFeaturedProperties({int limit = 6}) async {
    try {
      final snapshot = await db
          .collection('properties')
          .where('available', isEqualTo: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => Property.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured properties: $e');
    }
  }

  Future<List<Property>> searchProperties(String query) async {
    try {
      final snapshot = await db
          .collection('properties')
          .where('available', isEqualTo: true)
          .get();
      final queryLower = query.toLowerCase();
      return snapshot.docs
          .map((doc) => Property.fromMap(doc.data(), doc.id))
          .where((p) =>
              p.title.toLowerCase().contains(queryLower) ||
              p.address.toLowerCase().contains(queryLower) ||
              p.postcode.toLowerCase().contains(queryLower) ||
              p.description.toLowerCase().contains(queryLower))
          .toList();
    } catch (e) {
      throw Exception('Failed to search properties: $e');
    }
  }

  Future<Property?> getPropertyById(String id) async {
    try {
      final doc = await db.collection('properties').doc(id).get();
      if (!doc.exists) return null;
      return Property.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch property: $e');
    }
  }

  Future<String> createProperty(Property property) async {
    try {
      final docRef =
          await db.collection('properties').add(property.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create property: $e');
    }
  }

  Future<void> updateProperty(String id, Property property) async {
    try {
      await db.collection('properties').doc(id).update(property.toMap());
    } catch (e) {
      throw Exception('Failed to update property: $e');
    }
  }

  Future<void> updatePropertyImages(String id, List<String> imagePaths) async {
    try {
      await db.collection('properties').doc(id).update({
        'images': imagePaths,
      });
    } catch (e) {
      throw Exception('Failed to update property images: $e');
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      await db.collection('properties').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  Future<void> togglePropertyAvailability(String id, bool available) async {
    try {
      await db.collection('properties').doc(id).update({
        'available': available,
      });
    } catch (e) {
      throw Exception('Failed to update property availability: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Tenants
  // ──────────────────────────────────────────────

  Future<String> registerTenant(Tenant tenant) async {
    try {
      final docRef = await db.collection('tenants').add(tenant.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to register tenant: $e');
    }
  }

  Future<Tenant?> getTenant(String id) async {
    try {
      final doc = await db.collection('tenants').doc(id).get();
      if (!doc.exists) return null;
      return Tenant.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch tenant: $e');
    }
  }

  Future<void> updateTenant(String id, Tenant tenant) async {
    try {
      await db.collection('tenants').doc(id).update(tenant.toMap());
    } catch (e) {
      throw Exception('Failed to update tenant: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Landlords
  // ──────────────────────────────────────────────

  Future<String> registerLandlord(Landlord landlord) async {
    try {
      final docRef = await db.collection('landlords').add(landlord.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to register landlord: $e');
    }
  }

  Future<Landlord?> getLandlord(String id) async {
    try {
      final doc = await db.collection('landlords').doc(id).get();
      if (!doc.exists) return null;
      return Landlord.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch landlord: $e');
    }
  }

  Future<List<Landlord>> getAllLandlords() async {
    try {
      final snapshot = await db.collection('landlords').get();
      return snapshot.docs
          .map((doc) => Landlord.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch landlords: $e');
    }
  }

  Future<void> submitManagementRequest({
    required String propertyAddress,
    required int numberOfProperties,
    required String managementType,
    required String additionalNotes,
    required String contactName,
    required String contactPhone,
    required String contactEmail,
  }) async {
    try {
      await db.collection('management_requests').add({
        'propertyAddress': propertyAddress,
        'numberOfProperties': numberOfProperties,
        'managementType': managementType,
        'additionalNotes': additionalNotes,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'contactEmail': contactEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'new',
      });
    } catch (e) {
      throw Exception('Failed to submit management request: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Enquiries
  // ──────────────────────────────────────────────

  Future<String> createEnquiry(Enquiry enquiry) async {
    try {
      final docRef = await db.collection('enquiries').add(enquiry.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create enquiry: $e');
    }
  }

  Future<List<Enquiry>> getEnquiriesForProperty(String propertyId) async {
    try {
      final snapshot = await db
          .collection('enquiries')
          .where('propertyId', isEqualTo: propertyId)
          .get();
      return snapshot.docs
          .map((doc) => Enquiry.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch property enquiries: $e');
    }
  }

  Future<List<Enquiry>> getEnquiriesForTenant(String tenantId) async {
    try {
      final snapshot = await db
          .collection('enquiries')
          .where('tenantId', isEqualTo: tenantId)
          .get();
      return snapshot.docs
          .map((doc) => Enquiry.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tenant enquiries: $e');
    }
  }

  Future<List<Enquiry>> getAllEnquiries() async {
    try {
      final snapshot = await db
          .collection('enquiries')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Enquiry.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all enquiries: $e');
    }
  }

  Future<void> updateEnquiryStatus(String id, String status) async {
    try {
      await db.collection('enquiries').doc(id).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update enquiry status: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Contact Messages
  // ──────────────────────────────────────────────

  Future<void> submitContactMessage({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    try {
      await db.collection('contact_messages').add({
        'name': name,
        'email': email,
        'phone': phone,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      throw Exception('Failed to submit contact message: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Waitlist
  // ──────────────────────────────────────────────

  Future<void> addToWaitlist(String email) async {
    try {
      await db.collection('waitlist').add({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add to waitlist: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Admin Analytics
  // ──────────────────────────────────────────────

  Future<Map<String, int>> getDashboardStats() async {
    try {
      final propsSnapshot = await db.collection('properties').get();
      final enquiriesSnapshot = await db.collection('enquiries').get();
      final landlordsSnapshot = await db.collection('landlords').get();
      final tenantsSnapshot = await db.collection('tenants').get();

      final totalProperties = propsSnapshot.docs.length;
      final availableProperties = propsSnapshot.docs
          .where((d) => d.data()['available'] == true)
          .length;
      final newApplications = enquiriesSnapshot.docs
          .where((d) => d.data()['status'] == 'new')
          .length;
      final waitingListCount = tenantsSnapshot.docs.length;
      final newLandlords = landlordsSnapshot.docs.length;

      // Monthly leads: enquiries created in the last 30 days
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final monthlyLeads = enquiriesSnapshot.docs.where((d) {
        final data = d.data();
        if (data['createdAt'] == null) return false;
        final createdAt = (data['createdAt'] as dynamic).toDate() as DateTime;
        return createdAt.isAfter(thirtyDaysAgo);
      }).length;

      return {
        'totalProperties': totalProperties,
        'availableProperties': availableProperties,
        'newApplications': newApplications,
        'waitingListCount': waitingListCount,
        'newLandlords': newLandlords,
        'monthlyLeads': monthlyLeads,
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }
}
