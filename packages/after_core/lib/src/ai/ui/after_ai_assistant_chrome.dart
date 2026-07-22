import 'package:flutter/material.dart';

import 'after_ai_hub_icon.dart';

/// One quick-action chip on the Garage-parity AI home surface.
@immutable
class AfterAiQuickSuggestion {
  const AfterAiQuickSuggestion({
    required this.id,
    required this.title,
    this.prompt,
  });

  final String id;
  final String title;

  /// Text inserted into the composer / sent when tapped. Defaults to [title].
  final String? prompt;

  String get sendText => (prompt ?? title).trim();
}

/// Default feature chips for skeleton Super Apps (Garage-shaped, domain-neutral).
abstract final class AfterAiQuickSuggestionCatalog {
  static List<AfterAiQuickSuggestion> defaultsFor(String appName) {
    final name = appName.replaceAll(RegExp(r'\s*AI\s*$', caseSensitive: false), '').trim();
    final label = name.isEmpty ? 'this app' : name;
    return [
      AfterAiQuickSuggestion(
        id: 'overview',
        title: 'What can $label AI help me with?',
        prompt: 'What can you help me with in $label?',
      ),
      const AfterAiQuickSuggestion(
        id: 'today',
        title: 'Summarize what I should focus on today',
        prompt: 'Summarize what I should focus on today.',
      ),
      const AfterAiQuickSuggestion(
        id: 'howto',
        title: 'How do I get started?',
        prompt: 'How do I get started with the main features?',
      ),
      const AfterAiQuickSuggestion(
        id: 'tips',
        title: 'Give me three quick tips',
        prompt: 'Give me three quick tips for using this app well.',
      ),
      const AfterAiQuickSuggestion(
        id: 'reminders',
        title: 'Help me set smart reminders',
        prompt: 'Help me set useful reminders for my routine.',
      ),
      const AfterAiQuickSuggestion(
        id: 'status',
        title: 'Check my current status',
        prompt: 'Give me a quick status check based on what you know.',
      ),
      const AfterAiQuickSuggestion(
        id: 'explain',
        title: 'Explain a feature in plain language',
        prompt: 'Explain the most important feature in plain language.',
      ),
      const AfterAiQuickSuggestion(
        id: 'emergency',
        title: 'What should I do in an emergency?',
        prompt: 'What should I do first in an emergency situation?',
      ),
    ];
  }
}

/// Title row: animated hub + "{App} AI" + clear chat (Garage `_AiTopPanel`).
class AfterAiAssistantHeader extends StatelessWidget {
  const AfterAiAssistantHeader({
    required this.title,
    required this.hasMessages,
    required this.onClearChat,
    super.key,
  });

  final String title;
  final bool hasMessages;
  final VoidCallback onClearChat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          IconTheme(
            data: IconThemeData(size: 30, color: scheme.primary),
            child: const AfterAiHubIcon(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Clear chat',
            onPressed: hasMessages ? onClearChat : null,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: hasMessages
                  ? scheme.onSurfaceVariant
                  : scheme.onSurfaceVariant.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two-column suggestion cards (Garage `_DynamicQuickSuggestionGrid`).
class AfterAiQuickSuggestionGrid extends StatelessWidget {
  const AfterAiQuickSuggestionGrid({
    required this.suggestions,
    required this.onSuggestion,
    super.key,
  });

  final List<AfterAiQuickSuggestion> suggestions;
  final ValueChanged<AfterAiQuickSuggestion> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final suggestion in suggestions)
              SizedBox(
                width: compact
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 8) / 2,
                child: _AfterAiQuickSuggestionCard(
                  title: suggestion.title,
                  onTap: () => onSuggestion(suggestion),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AfterAiQuickSuggestionCard extends StatelessWidget {
  const _AfterAiQuickSuggestionCard({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25),
          ),
        ),
      ),
    );
  }
}

/// Bottom composer: + | multiline field | send↑ / mic (Garage `_AiComposerBar`).
class AfterAiComposerBar extends StatefulWidget {
  const AfterAiComposerBar({
    required this.controller,
    required this.isBusy,
    required this.onSend,
    this.hintText = 'Ask Mate…',
    this.isRecording = false,
    this.onAttach,
    this.onToggleRecording,
    this.recordingLabel = 'Listening…',
    super.key,
  });

  final TextEditingController controller;
  final bool isBusy;
  final VoidCallback onSend;
  final String hintText;
  final bool isRecording;
  final VoidCallback? onAttach;
  final VoidCallback? onToggleRecording;
  final String recordingLabel;

  @override
  State<AfterAiComposerBar> createState() => _AfterAiComposerBarState();
}

class _AfterAiComposerBarState extends State<AfterAiComposerBar> {
  static const _attachIconSize = 22.0;
  static const _actionButtonSize = 40.0;
  static const _inputMaxHeight = 112.0;

  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AfterAiComposerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _hasText = widget.controller.text.trim().isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: MediaQuery.viewInsetsOf(context).bottom == 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isRecording)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: scheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.recordingLabel,
                          style: TextStyle(
                            color: scheme.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _composerIconButton(
                      tooltip: 'Attach',
                      onPressed: widget.isBusy ? null : widget.onAttach,
                      icon: Icons.add_rounded,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: _inputMaxHeight,
                        ),
                        child: TextField(
                          controller: widget.controller,
                          enabled: !widget.isBusy,
                          minLines: 1,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(fontSize: 16, height: 1.35),
                          decoration: InputDecoration(
                            hintText: widget.hintText,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTrailingButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _composerIconButton({
    required String tooltip,
    required VoidCallback? onPressed,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: _actionButtonSize,
      height: _actionButtonSize,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: _attachIconSize,
          color: scheme.onSurfaceVariant,
        ),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(
          minWidth: _actionButtonSize,
          minHeight: _actionButtonSize,
        ),
        style: IconButton.styleFrom(
          fixedSize: const Size(_actionButtonSize, _actionButtonSize),
        ),
      ),
    );
  }

  ButtonStyle _actionButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? sideColor,
  }) {
    return IconButton.styleFrom(
      fixedSize: const Size(_actionButtonSize, _actionButtonSize),
      minimumSize: const Size(_actionButtonSize, _actionButtonSize),
      padding: EdgeInsets.zero,
      iconSize: _attachIconSize,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      side: sideColor == null ? null : BorderSide(color: sideColor),
    );
  }

  Widget _buildTrailingButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (widget.isRecording) {
      return SizedBox(
        width: _actionButtonSize,
        height: _actionButtonSize,
        child: IconButton.filled(
          style: _actionButtonStyle(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: widget.isBusy ? null : widget.onToggleRecording,
          icon: const Icon(Icons.stop_rounded),
        ),
      );
    }

    if (_hasText) {
      return SizedBox(
        width: _actionButtonSize,
        height: _actionButtonSize,
        child: IconButton.filled(
          style: _actionButtonStyle(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
          ),
          onPressed: widget.isBusy ? null : widget.onSend,
          icon: widget.isBusy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.onPrimary,
                  ),
                )
              : Icon(
                  Icons.arrow_upward_rounded,
                  color: scheme.onPrimary,
                ),
        ),
      );
    }

    return SizedBox(
      width: _actionButtonSize,
      height: _actionButtonSize,
      child: IconButton.outlined(
        style: _actionButtonStyle(sideColor: scheme.outlineVariant),
        onPressed: widget.isBusy ? null : widget.onToggleRecording,
        icon: const Icon(Icons.mic_none_rounded),
      ),
    );
  }
}

/// Chat bubble — Garage-lite message row.
class AfterAiMessageBubble extends StatelessWidget {
  const AfterAiMessageBubble({
    required this.text,
    required this.isUser,
    super.key,
  });

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isUser
                ? scheme.primaryContainer
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              text,
              style: TextStyle(
                height: 1.35,
                color: isUser
                    ? scheme.onPrimaryContainer
                    : scheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
