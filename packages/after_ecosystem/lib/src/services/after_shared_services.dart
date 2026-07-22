import 'package:meta/meta.dart';

import '../identity/after_id.dart';

// ── After Cloud ────────────────────────────────────────────────────────────

@immutable
class AfterCloudObjectRef {
  const AfterCloudObjectRef({
    required this.key,
    required this.moduleId,
    this.contentType,
    this.bytes,
  });

  final String key;
  final String moduleId;
  final String? contentType;
  final int? bytes;
}

abstract class AfterCloudStore {
  Future<void> put(AfterId afterId, AfterCloudObjectRef object);

  Future<AfterCloudObjectRef?> get(AfterId afterId, String key);

  Future<List<AfterCloudObjectRef>> list(AfterId afterId, {String? moduleId});
}

class InMemoryAfterCloudStore implements AfterCloudStore {
  final Map<String, Map<String, AfterCloudObjectRef>> _byUser = {};

  @override
  Future<void> put(AfterId afterId, AfterCloudObjectRef object) async {
    _byUser.putIfAbsent(afterId.value, () => {})[object.key] = object;
  }

  @override
  Future<AfterCloudObjectRef?> get(AfterId afterId, String key) async =>
      _byUser[afterId.value]?[key];

  @override
  Future<List<AfterCloudObjectRef>> list(
    AfterId afterId, {
    String? moduleId,
  }) async {
    final all = _byUser[afterId.value]?.values.toList() ?? const [];
    if (moduleId == null) return all;
    return all.where((o) => o.moduleId == moduleId).toList();
  }
}

// ── After Calendar (merged) ────────────────────────────────────────────────

@immutable
class AfterEcosystemCalendarEvent {
  const AfterEcosystemCalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.sourceProductId,
    this.afterId,
    this.organizationId,
    this.metadata = const {},
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String sourceProductId;
  final AfterId? afterId;
  final String? organizationId;
  final Map<String, Object?> metadata;
}

abstract class AfterEcosystemCalendar {
  Future<void> upsert(AfterEcosystemCalendarEvent event);

  Future<void> remove(String eventId);

  Future<List<AfterEcosystemCalendarEvent>> listMerged({
    required AfterId afterId,
    DateTime? from,
    DateTime? to,
  });
}

class InMemoryAfterEcosystemCalendar implements AfterEcosystemCalendar {
  final Map<String, AfterEcosystemCalendarEvent> _events = {};

  @override
  Future<void> upsert(AfterEcosystemCalendarEvent event) async {
    _events[event.id] = event;
  }

  @override
  Future<void> remove(String eventId) async => _events.remove(eventId);

  @override
  Future<List<AfterEcosystemCalendarEvent>> listMerged({
    required AfterId afterId,
    DateTime? from,
    DateTime? to,
  }) async {
    return _events.values.where((e) {
      if (e.afterId != null && e.afterId != afterId) return false;
      if (from != null && e.end.isBefore(from)) return false;
      if (to != null && e.start.isAfter(to)) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }
}

// ── After Notification Center ──────────────────────────────────────────────

@immutable
class AfterEcosystemNotification {
  const AfterEcosystemNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.sourceProductId,
    required this.createdAt,
    this.afterId,
    this.read = false,
    this.deepLink,
  });

  final String id;
  final String title;
  final String body;
  final String sourceProductId;
  final DateTime createdAt;
  final AfterId? afterId;
  final bool read;
  final String? deepLink;
}

abstract class AfterNotificationCenter {
  Future<void> post(AfterEcosystemNotification notification);

  Future<List<AfterEcosystemNotification>> inbox(AfterId afterId);

  Future<void> markRead(String notificationId);
}

class InMemoryAfterNotificationCenter implements AfterNotificationCenter {
  final Map<String, AfterEcosystemNotification> _items = {};

  @override
  Future<void> post(AfterEcosystemNotification notification) async {
    _items[notification.id] = notification;
  }

  @override
  Future<List<AfterEcosystemNotification>> inbox(AfterId afterId) async {
    return _items.values.where((n) => n.afterId == afterId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> markRead(String notificationId) async {
    final n = _items[notificationId];
    if (n == null) return;
    _items[notificationId] = AfterEcosystemNotification(
      id: n.id,
      title: n.title,
      body: n.body,
      sourceProductId: n.sourceProductId,
      createdAt: n.createdAt,
      afterId: n.afterId,
      read: true,
      deepLink: n.deepLink,
    );
  }
}

// ── After Search (federated) ───────────────────────────────────────────────

@immutable
class AfterEcosystemSearchHit {
  const AfterEcosystemSearchHit({
    required this.id,
    required this.title,
    required this.sourceProductId,
    this.subtitle,
    this.score = 0,
    this.route,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String sourceProductId;
  final double score;
  final String? route;
}

abstract class AfterEcosystemSearchIndex {
  Future<void> upsert({
    required String sourceProductId,
    required String id,
    required String title,
    String? subtitle,
    String? route,
    Set<String> tokens = const {},
  });

  Future<List<AfterEcosystemSearchHit>> search(
    String query, {
    AfterId? afterId,
    int limit = 20,
  });
}

class InMemoryAfterEcosystemSearchIndex implements AfterEcosystemSearchIndex {
  final List<_SearchDoc> _docs = [];

  @override
  Future<void> upsert({
    required String sourceProductId,
    required String id,
    required String title,
    String? subtitle,
    String? route,
    Set<String> tokens = const {},
  }) async {
    _docs.removeWhere((d) => d.sourceProductId == sourceProductId && d.id == id);
    _docs.add(
      _SearchDoc(
        sourceProductId: sourceProductId,
        id: id,
        title: title,
        subtitle: subtitle,
        route: route,
        tokens: {
          ...tokens,
          ...title.toLowerCase().split(RegExp(r'\s+')),
          if (subtitle != null)
            ...subtitle.toLowerCase().split(RegExp(r'\s+')),
        },
      ),
    );
  }

  @override
  Future<List<AfterEcosystemSearchHit>> search(
    String query, {
    AfterId? afterId,
    int limit = 20,
  }) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return const [];
    final hits = <AfterEcosystemSearchHit>[];
    for (final d in _docs) {
      final score = d.tokens.where((t) => t.contains(q) || q.contains(t)).length;
      if (score > 0) {
        hits.add(
          AfterEcosystemSearchHit(
            id: d.id,
            title: d.title,
            subtitle: d.subtitle,
            sourceProductId: d.sourceProductId,
            score: score.toDouble(),
            route: d.route,
          ),
        );
      }
    }
    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits.take(limit).toList();
  }
}

class _SearchDoc {
  _SearchDoc({
    required this.sourceProductId,
    required this.id,
    required this.title,
    required this.tokens,
    this.subtitle,
    this.route,
  });

  final String sourceProductId;
  final String id;
  final String title;
  final String? subtitle;
  final String? route;
  final Set<String> tokens;
}

// ── After Wallet ───────────────────────────────────────────────────────────

@immutable
class AfterWalletLedgerEntry {
  const AfterWalletLedgerEntry({
    required this.id,
    required this.afterId,
    required this.amount,
    required this.currency,
    required this.label,
    required this.at,
    this.sourceProductId,
  });

  final String id;
  final AfterId afterId;
  final double amount;
  final String currency;
  final String label;
  final DateTime at;
  final String? sourceProductId;
}

/// Ledger-only balances — **not** payment rails (ADR-010).
abstract class AfterWallet {
  Future<void> record(AfterWalletLedgerEntry entry);

  Future<List<AfterWalletLedgerEntry>> history(AfterId afterId);
}

/// Preferred name for the ledger port (ADR-010).
typedef AfterWalletLedger = AfterWallet;

class InMemoryAfterWallet implements AfterWallet {
  final List<AfterWalletLedgerEntry> _entries = [];

  @override
  Future<void> record(AfterWalletLedgerEntry entry) async => _entries.add(entry);

  @override
  Future<List<AfterWalletLedgerEntry>> history(AfterId afterId) async =>
      _entries.where((e) => e.afterId == afterId).toList();
}

// ── After Family ───────────────────────────────────────────────────────────

@immutable
class AfterFamilyMember {
  const AfterFamilyMember({
    required this.afterId,
    required this.displayName,
    this.role = 'member',
  });

  final AfterId afterId;
  final String displayName;
  final String role;
}

@immutable
class AfterFamilySpace {
  const AfterFamilySpace({
    required this.id,
    required this.name,
    required this.members,
  });

  final String id;
  final String name;
  final List<AfterFamilyMember> members;
}

abstract class AfterFamilyGraph {
  Future<AfterFamilySpace?> spaceFor(AfterId afterId);

  Future<AfterFamilySpace> upsert(AfterFamilySpace space);
}

class InMemoryAfterFamilyGraph implements AfterFamilyGraph {
  final Map<String, AfterFamilySpace> _spaces = {};

  @override
  Future<AfterFamilySpace?> spaceFor(AfterId afterId) async {
    for (final s in _spaces.values) {
      if (s.members.any((m) => m.afterId == afterId)) return s;
    }
    return null;
  }

  @override
  Future<AfterFamilySpace> upsert(AfterFamilySpace space) async {
    _spaces[space.id] = space;
    return space;
  }
}

// ── After Marketplace ──────────────────────────────────────────────────────

@immutable
class AfterMarketplaceListing {
  const AfterMarketplaceListing({
    required this.id,
    required this.title,
    required this.moduleId,
    this.description = '',
  });

  final String id;
  final String title;
  final String moduleId;
  final String description;
}

abstract class AfterMarketplace {
  Future<List<AfterMarketplaceListing>> listListings();

  Future<void> publish(AfterMarketplaceListing listing);
}

class InMemoryAfterMarketplace implements AfterMarketplace {
  final Map<String, AfterMarketplaceListing> _listings = {};

  @override
  Future<List<AfterMarketplaceListing>> listListings() async =>
      _listings.values.toList();

  @override
  Future<void> publish(AfterMarketplaceListing listing) async {
    _listings[listing.id] = listing;
  }
}

// ── After Documents (ecosystem vault) ──────────────────────────────────────

@immutable
class AfterEcosystemDocument {
  const AfterEcosystemDocument({
    required this.id,
    required this.title,
    required this.sourceProductId,
    required this.afterId,
    this.mimeType,
    this.sharedWithFamily = false,
  });

  final String id;
  final String title;
  final String sourceProductId;
  final AfterId afterId;
  final String? mimeType;
  final bool sharedWithFamily;
}

abstract class AfterEcosystemDocuments {
  Future<void> upsert(AfterEcosystemDocument doc);

  Future<List<AfterEcosystemDocument>> listFor(AfterId afterId);
}

class InMemoryAfterEcosystemDocuments implements AfterEcosystemDocuments {
  final Map<String, AfterEcosystemDocument> _docs = {};

  @override
  Future<void> upsert(AfterEcosystemDocument doc) async => _docs[doc.id] = doc;

  @override
  Future<List<AfterEcosystemDocument>> listFor(AfterId afterId) async =>
      _docs.values.where((d) => d.afterId == afterId).toList();
}

// ── After Analytics (ecosystem) ────────────────────────────────────────────

abstract class AfterEcosystemAnalytics {
  Future<void> track({
    required String name,
    required String sourceProductId,
    AfterId? afterId,
    Map<String, Object?> props = const {},
  });
}

class InMemoryAfterEcosystemAnalytics implements AfterEcosystemAnalytics {
  final List<Map<String, Object?>> events = [];

  @override
  Future<void> track({
    required String name,
    required String sourceProductId,
    AfterId? afterId,
    Map<String, Object?> props = const {},
  }) async {
    events.add({
      'name': name,
      'sourceProductId': sourceProductId,
      if (afterId != null) 'afterId': afterId.value,
      'props': props,
    });
  }
}

// ── After Settings (global) ────────────────────────────────────────────────

abstract class AfterEcosystemSettings {
  Future<T?> get<T>(AfterId afterId, String key);

  Future<void> set(AfterId afterId, String key, Object? value);
}

class InMemoryAfterEcosystemSettings implements AfterEcosystemSettings {
  final Map<String, Map<String, Object?>> _byUser = {};

  @override
  Future<T?> get<T>(AfterId afterId, String key) async {
    final v = _byUser[afterId.value]?[key];
    return v is T ? v : null;
  }

  @override
  Future<void> set(AfterId afterId, String key, Object? value) async {
    _byUser.putIfAbsent(afterId.value, () => {})[key] = value;
  }
}

// ── After Personalization ──────────────────────────────────────────────────

@immutable
class AfterPersonalizationProfile {
  const AfterPersonalizationProfile({
    required this.afterId,
    this.preferredModules = const <String>[],
    this.homeLayoutHints = const <String, Object?>{},
    this.traits = const <String, Object?>{},
  });

  final AfterId afterId;
  final List<String> preferredModules;
  final Map<String, Object?> homeLayoutHints;
  final Map<String, Object?> traits;
}

abstract class AfterPersonalization {
  Future<AfterPersonalizationProfile> profileFor(AfterId afterId);

  Future<void> save(AfterPersonalizationProfile profile);
}

class InMemoryAfterPersonalization implements AfterPersonalization {
  final Map<String, AfterPersonalizationProfile> _profiles = {};

  @override
  Future<AfterPersonalizationProfile> profileFor(AfterId afterId) async {
    return _profiles[afterId.value] ??
        AfterPersonalizationProfile(afterId: afterId);
  }

  @override
  Future<void> save(AfterPersonalizationProfile profile) async {
    _profiles[profile.afterId.value] = profile;
  }
}
