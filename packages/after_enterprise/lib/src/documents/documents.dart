import 'package:after_core/after_core.dart';
import 'package:meta/meta.dart';

import '../scope/enterprise_scope.dart';

/// Metadata pointer for an enterprise document. Actual binary content lives
/// in a vault (S3/GCS/etc.) referenced by [vaultKey].
@immutable
class EnterpriseDocument {
  const EnterpriseDocument({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.mimeType,
    required this.vaultKey,
    this.size = 0,
    this.tags = const [],
    this.uploadedBy,
    this.uploadedAt,
    this.version = 1,
    this.checksum,
    this.metadata = const {},
  });

  final String id;
  final String organizationId;
  final String name;
  final String mimeType;
  final String vaultKey;
  final int size;
  final List<String> tags;
  final String? uploadedBy;
  final DateTime? uploadedAt;
  final int version;
  final String? checksum;
  final Map<String, String> metadata;
}

abstract class DocumentRepository {
  /// Fail-closed: [organizationId] is required (ADR-002).
  Future<List<EnterpriseDocument>> listDocuments({
    required String organizationId,
    List<String>? tags,
  });

  Future<Page<EnterpriseDocument>> pageDocuments({
    required String organizationId,
    PageQuery query = const PageQuery(),
    List<String>? tags,
  });

  Future<EnterpriseDocument?> getDocument(String id);
  Future<EnterpriseDocument> registerDocument(EnterpriseDocument document);
  Future<void> deleteDocument(String id);
}

class InMemoryDocumentRepository implements DocumentRepository {
  InMemoryDocumentRepository({List<EnterpriseDocument>? seed})
      : _docs = {
          for (final d in seed ?? const <EnterpriseDocument>[]) d.id: d,
        };

  final Map<String, EnterpriseDocument> _docs;
  var _nextId = 1;

  @override
  Future<List<EnterpriseDocument>> listDocuments({
    required String organizationId,
    List<String>? tags,
  }) async {
    final org = EnterpriseScope.requireOrganizationId(organizationId);
    return _docs.values.where((d) {
      if (d.organizationId != org) return false;
      if (tags != null && tags.isNotEmpty) {
        if (!tags.every(d.tags.contains)) return false;
      }
      return true;
    }).toList(growable: false);
  }

  @override
  Future<Page<EnterpriseDocument>> pageDocuments({
    required String organizationId,
    PageQuery query = const PageQuery(),
    List<String>? tags,
  }) async {
    final all = await listDocuments(organizationId: organizationId, tags: tags);
    return Page.fromList(all, query);
  }

  @override
  Future<EnterpriseDocument?> getDocument(String id) async => _docs[id];

  @override
  Future<EnterpriseDocument> registerDocument(
    EnterpriseDocument document,
  ) async {
    final id = document.id.isEmpty ? 'doc_${_nextId++}' : document.id;
    final stored = EnterpriseDocument(
      id: id,
      organizationId: document.organizationId,
      name: document.name,
      mimeType: document.mimeType,
      vaultKey: document.vaultKey,
      size: document.size,
      tags: document.tags,
      uploadedBy: document.uploadedBy,
      uploadedAt: document.uploadedAt ?? DateTime.now().toUtc(),
      version: document.version,
      checksum: document.checksum,
      metadata: document.metadata,
    );
    _docs[id] = stored;
    return stored;
  }

  @override
  Future<void> deleteDocument(String id) async {
    _docs.remove(id);
  }
}
