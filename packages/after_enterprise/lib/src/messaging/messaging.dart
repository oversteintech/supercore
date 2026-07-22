import 'dart:async';

import 'package:meta/meta.dart';

import '../scope/enterprise_scope.dart';

@immutable
class MessagingChannel {
  const MessagingChannel({
    required this.id,
    required this.organizationId,
    required this.name,
    this.isPrivate = false,
    this.memberIds = const [],
  });

  final String id;
  final String organizationId;
  final String name;
  final bool isPrivate;
  final List<String> memberIds;
}

@immutable
class MessagingMessage {
  const MessagingMessage({
    required this.id,
    required this.channelId,
    required this.authorId,
    required this.body,
    required this.sentAt,
    this.threadId,
    this.attachments = const [],
  });

  final String id;
  final String channelId;
  final String authorId;
  final String body;
  final DateTime sentAt;
  final String? threadId;
  final List<String> attachments;
}

abstract class MessagingRepository {
  /// Fail-closed: [organizationId] is required (ADR-002).
  Future<List<MessagingChannel>> listChannels({required String organizationId});
  Future<MessagingChannel> createChannel(MessagingChannel channel);
  Future<List<MessagingMessage>> listMessages(String channelId);
  Future<MessagingMessage> postMessage(MessagingMessage message);
  Stream<MessagingMessage> watchChannel(String channelId);
}

class InMemoryMessagingRepository implements MessagingRepository {
  InMemoryMessagingRepository({List<MessagingChannel>? seed})
      : _channels = {
          for (final c in seed ?? const <MessagingChannel>[]) c.id: c,
        };

  final Map<String, MessagingChannel> _channels;
  final Map<String, List<MessagingMessage>> _messages = {};
  final Map<String, StreamController<MessagingMessage>> _controllers = {};
  var _nextId = 1;

  StreamController<MessagingMessage> _controllerFor(String channelId) {
    return _controllers.putIfAbsent(
      channelId,
      () => StreamController<MessagingMessage>.broadcast(),
    );
  }

  @override
  Future<List<MessagingChannel>> listChannels({
    required String organizationId,
  }) async {
    final org = EnterpriseScope.requireOrganizationId(organizationId);
    return _channels.values
        .where((c) => c.organizationId == org)
        .toList(growable: false);
  }

  @override
  Future<MessagingChannel> createChannel(MessagingChannel channel) async {
    final id = channel.id.isEmpty ? 'chan_${_nextId++}' : channel.id;
    final stored = MessagingChannel(
      id: id,
      organizationId: channel.organizationId,
      name: channel.name,
      isPrivate: channel.isPrivate,
      memberIds: channel.memberIds,
    );
    _channels[id] = stored;
    return stored;
  }

  @override
  Future<List<MessagingMessage>> listMessages(String channelId) async {
    return List.unmodifiable(_messages[channelId] ?? const []);
  }

  @override
  Future<MessagingMessage> postMessage(MessagingMessage message) async {
    final id = message.id.isEmpty ? 'msg_${_nextId++}' : message.id;
    final stored = MessagingMessage(
      id: id,
      channelId: message.channelId,
      authorId: message.authorId,
      body: message.body,
      sentAt: message.sentAt,
      threadId: message.threadId,
      attachments: message.attachments,
    );
    _messages.putIfAbsent(message.channelId, () => []).add(stored);
    _controllerFor(message.channelId).add(stored);
    return stored;
  }

  @override
  Stream<MessagingMessage> watchChannel(String channelId) {
    return _controllerFor(channelId).stream;
  }
}
