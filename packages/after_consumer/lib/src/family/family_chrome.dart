import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';

/// Product chrome config for login / about / AI labels.
@immutable
class FamilyChromeConfig {
  const FamilyChromeConfig({
    required this.appName,
    required this.supportEmail,
    required this.accent,
    this.headerTitle,
    this.tagline = 'Powered by After Framework',
    this.aiTitle = 'After AI',
    this.defaultLoginEmail = 'you@afterartificial.com',
    this.defaultLoginPassword = 'afterapp',
    this.productId,
  });

  final String appName;
  final String supportEmail;
  final Color accent;

  /// Short shell title like Garage / Health (defaults: strip leading `Super`).
  final String? headerTitle;
  final String tagline;
  final String aiTitle;
  final String defaultLoginEmail;
  final String defaultLoginPassword;

  /// Optional catalog id for shared premium product icons.
  /// Garage leaves this null and keeps local monogram assets.
  final AfterProductId? productId;

  AfterProductIconSpec? get productIconSpec {
    if (productId != null) {
      return AfterProductIconCatalog.byId(productId!);
    }
    return AfterProductIconCatalog.byAppName(appName);
  }

  String get shellTitle {
    if (headerTitle != null && headerTitle!.trim().isNotEmpty) {
      return headerTitle!.trim();
    }
    final name = appName.trim();
    if (name.toLowerCase().startsWith('super') && name.length > 5) {
      return name.substring(5);
    }
    return name;
  }
}

/// Minimal mock auth for scaffolds (same contract as sibling apps).
class FamilyMockAuthRepository implements AfterAuthRepository {
  FamilyMockAuthRepository({this.defaultEmail = 'you@afterartificial.com'});

  final String defaultEmail;
  final _controller = StreamController<AfterAuthSession>.broadcast();
  AfterAuthSession _session = const AfterAuthSession.unauthenticated();

  void _emit(AfterAuthSession session) {
    _session = session;
    _controller.add(session);
  }

  @override
  bool get isAvailable => true;

  @override
  Stream<AfterAuthSession> watchAuthSession() async* {
    yield _session;
    yield* _controller.stream;
  }

  @override
  Future<AfterAuthSession> getCurrentSession() async => _session;

  @override
  Future<AfterAuthUser> signInAnonymously({
    required String installationId,
  }) async {
    final user = AfterAuthUser(
      uid: 'anon_$installationId',
      isAnonymous: true,
      displayName: 'Guest',
      providers: const [AfterAuthProvider.anonymous],
    );
    _emit(
      AfterAuthSession(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        installationId: installationId,
      ),
    );
    return user;
  }

  @override
  Future<AfterAuthUser> signInWithEmailPassword(
    AfterEmailPasswordCredentials credentials,
  ) async {
    final user = AfterAuthUser(
      uid: 'user_${credentials.email.hashCode}',
      isAnonymous: false,
      email: credentials.email,
      displayName: credentials.email.split('@').first,
      emailVerified: true,
      providers: const [AfterAuthProvider.emailPassword],
    );
    _emit(
      AfterAuthSession(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      ),
    );
    return user;
  }

  @override
  Future<AfterAuthUser> signUpWithEmailPassword(
    AfterEmailPasswordCredentials credentials,
  ) =>
      signInWithEmailPassword(credentials);

  @override
  Future<void> sendMagicLink({required String email}) async {}

  @override
  Future<AfterAuthUser> completeMagicLinkSignIn({required String url}) async {
    return signInWithEmailPassword(
      AfterEmailPasswordCredentials(email: defaultEmail, password: 'magic'),
    );
  }

  @override
  Future<AfterAuthUser> signInWithGoogle() async {
    return signInWithEmailPassword(
      AfterEmailPasswordCredentials(email: defaultEmail, password: 'google'),
    );
  }

  @override
  Future<AfterAuthUser> signInWithApple() async {
    return signInWithEmailPassword(
      AfterEmailPasswordCredentials(email: defaultEmail, password: 'apple'),
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<AfterAuthUser?> reloadCurrentUser() async => _session.user;

  @override
  Future<void> signOut() async {
    _emit(
      AfterAuthSession.unauthenticated(
        installationId: _session.installationId,
      ),
    );
  }

  @override
  Future<void> deleteAccount() async => signOut();

  @override
  Future<String?> getAccessToken() async => 'mock.family.access.token';
}

/// About card / screen content.
class FamilyAboutScreen extends StatelessWidget {
  const FamilyAboutScreen({
    required this.config,
    this.version = '0.1.0',
    super.key,
  });

  final FamilyChromeConfig config;
  final String version;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(config.appName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Version $version'),
          const SizedBox(height: 16),
          Text(config.tagline),
          const SizedBox(height: 8),
          const Text('Built by Overstein Labs · AfterArtificial Super Apps'),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email_outlined),
            title: Text(config.supportEmail),
          ),
        ],
      ),
    );
  }
}

/// Garage-parity AI chat shell — hub header, feature chips, message list,
/// and Mate-style composer (+ / field / send↑·mic). Apps inject [onSend].
class FamilyAiChatScreen extends StatefulWidget {
  const FamilyAiChatScreen({
    required this.title,
    required this.onSend,
    this.welcomeMessage =
        'Ask me anything about this Super App. Mock AI is ready.',
    this.suggestions,
    this.inputHint,
    super.key,
  });

  final String title;
  final Future<String> Function(String prompt) onSend;
  final String welcomeMessage;

  /// When null, [AfterAiQuickSuggestionCatalog.defaultsFor] is used.
  final List<AfterAiQuickSuggestion>? suggestions;
  final String? inputHint;

  @override
  State<FamilyAiChatScreen> createState() => _FamilyAiChatScreenState();
}

class _FamilyAiChatScreenState extends State<FamilyAiChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _lines = <({bool user, String text})>[];
  var _busy = false;
  var _recording = false;
  var _showSuggestions = true;

  List<AfterAiQuickSuggestion> get _suggestions =>
      widget.suggestions ?? AfterAiQuickSuggestionCatalog.defaultsFor(widget.title);

  @override
  void initState() {
    super.initState();
    _lines.add((user: false, text: widget.welcomeMessage));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _sendText(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _busy) return;
    setState(() {
      _lines.add((user: true, text: text));
      _input.clear();
      _busy = true;
      _showSuggestions = false;
      _recording = false;
    });
    _scrollToEnd();
    try {
      final reply = await widget.onSend(text);
      if (!mounted) return;
      setState(() => _lines.add((user: false, text: reply)));
      _scrollToEnd();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _lines.add((user: false, text: 'Error: $e')));
      _scrollToEnd();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() => _sendText(_input.text);

  void _clearChat() {
    setState(() {
      _lines
        ..clear()
        ..add((user: false, text: widget.welcomeMessage));
      _showSuggestions = true;
      _recording = false;
    });
  }

  void _toggleRecording() {
    if (_busy) return;
    setState(() => _recording = !_recording);
    if (_recording) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Voice input attaches when the mic port is wired.'),
        ),
      );
      setState(() => _recording = false);
    }
  }

  void _onAttach() {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('Attachments plug in later via After AI ports.'),
      ),
    );
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final userMessageCount = _lines.where((l) => l.user).length;

    return Column(
      children: [
        if (!keyboardOpen)
          AfterAiAssistantHeader(
            title: widget.title,
            hasMessages: userMessageCount > 0,
            onClearChat: _clearChat,
          ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              if (_showSuggestions && userMessageCount == 0) ...[
                AfterAiQuickSuggestionGrid(
                  suggestions: _suggestions,
                  onSuggestion: (s) => _sendText(s.sendText),
                ),
                const SizedBox(height: 16),
              ],
              for (var i = 0; i < _lines.length; i++) ...[
                AfterAiMessageBubble(
                  text: _lines[i].text,
                  isUser: _lines[i].user,
                ),
                if (i != _lines.length - 1) const SizedBox(height: 10),
              ],
              if (_busy) ...[
                const SizedBox(height: 12),
                const AfterAiThinking(),
              ],
            ],
          ),
        ),
        AfterAiComposerBar(
          controller: _input,
          isBusy: _busy,
          isRecording: _recording,
          hintText: widget.inputHint ?? 'Ask ${widget.title}…',
          onSend: () => unawaited(_send()),
          onAttach: _onAttach,
          onToggleRecording: _toggleRecording,
        ),
      ],
    );
  }
}

/// Live tab scaffold — apps supply body (mock streams, tickers, etc.).
class FamilyLiveScaffold extends StatelessWidget {
  const FamilyLiveScaffold({
    required this.title,
    required this.child,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
