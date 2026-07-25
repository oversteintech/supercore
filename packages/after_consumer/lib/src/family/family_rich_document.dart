import 'package:flutter/material.dart';

/// One titled block inside a corporate info / legal sheet.
@immutable
class FamilyDocSection {
  const FamilyDocSection({required this.title, required this.body});

  final String title;
  final String body;
}

/// Renders settings/legal copy with hierarchy: paragraphs, bullets, and
/// `Label — detail` definition rows. Supports light `**bold**` markers.
class FamilyRichBody extends StatelessWidget {
  const FamilyRichBody(
    this.text, {
    super.key,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base =
        style ??
        theme.textTheme.bodyMedium?.copyWith(
          height: 1.55,
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 14,
        );
    final blocks = _parseBlocks(text);
    if (blocks.isEmpty) {
      return Text(text, style: base);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          blocks[i].build(context, base!),
        ],
      ],
    );
  }
}

sealed class _DocBlock {
  const _DocBlock();
  Widget build(BuildContext context, TextStyle base);
}

class _ParagraphBlock extends _DocBlock {
  const _ParagraphBlock(this.text);
  final String text;

  @override
  Widget build(BuildContext context, TextStyle base) {
    return Text.rich(_span(text, base));
  }
}

class _BulletBlock extends _DocBlock {
  const _BulletBlock(this.items);
  final List<(String marker, String text)> items;

  @override
  Widget build(BuildContext context, TextStyle base) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                child: items[i].$1 == '•'
                    ? Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        items[i].$1,
                        style: base.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text.rich(_span(items[i].$2, base))),
            ],
          ),
        ],
      ],
    );
  }
}

class _DefinitionBlock extends _DocBlock {
  const _DefinitionBlock(this.rows);
  final List<(String label, String detail)> rows;

  @override
  Widget build(BuildContext context, TextStyle base) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = base.copyWith(
      fontWeight: FontWeight.w800,
      color: scheme.onSurface,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: rows[i].$1, style: labelStyle),
                TextSpan(text: '  ', style: base),
                TextSpan(text: rows[i].$2, style: base),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

TextSpan _span(String raw, TextStyle base) {
  final bold = base.copyWith(
    fontWeight: FontWeight.w800,
    color: base.color,
  );
  final parts = <InlineSpan>[];
  final re = RegExp(r'\*\*(.+?)\*\*');
  var start = 0;
  for (final match in re.allMatches(raw)) {
    if (match.start > start) {
      parts.add(TextSpan(text: raw.substring(start, match.start), style: base));
    }
    parts.add(TextSpan(text: match.group(1), style: bold));
    start = match.end;
  }
  if (start < raw.length) {
    parts.add(TextSpan(text: raw.substring(start), style: base));
  }
  if (parts.isEmpty) {
    return TextSpan(text: raw, style: base);
  }
  return TextSpan(children: parts);
}

List<_DocBlock> _parseBlocks(String text) {
  final lines = text.replaceAll('\r\n', '\n').split('\n');
  final blocks = <_DocBlock>[];
  final paragraph = <String>[];
  final bullets = <(String, String)>[];
  final defs = <(String, String)>[];

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    blocks.add(_ParagraphBlock(paragraph.join(' ').trim()));
    paragraph.clear();
  }

  void flushBullets() {
    if (bullets.isEmpty) return;
    blocks.add(_BulletBlock(List<(String, String)>.from(bullets)));
    bullets.clear();
  }

  void flushDefs() {
    if (defs.isEmpty) return;
    blocks.add(_DefinitionBlock(List<(String, String)>.from(defs)));
    defs.clear();
  }

  for (final rawLine in lines) {
    final line = rawLine.trimRight();
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      flushParagraph();
      flushBullets();
      flushDefs();
      continue;
    }

    final bulletMatch =
        RegExp(r'^((?:[-•*])|(\d+\.))\s+(.*)$').firstMatch(trimmed);
    if (bulletMatch != null) {
      flushParagraph();
      flushDefs();
      final marker = bulletMatch.group(2) ?? '•';
      bullets.add((marker, bulletMatch.group(3)!.trim()));
      continue;
    }

    // "Camera — profile photos" / "Camera - profile photos" definition rows.
    final emDash = RegExp(r'^(.{2,48}?)\s+[—–-]\s+(.+)$').firstMatch(trimmed);
    if (emDash != null && !trimmed.contains('. ')) {
      flushParagraph();
      flushBullets();
      defs.add((emDash.group(1)!.trim(), emDash.group(2)!.trim()));
      continue;
    }

    // "Data controller: OVERSTEIN" style label rows.
    final colon = RegExp(r'^([^:]{2,40}):\s+(.+)$').firstMatch(trimmed);
    if (colon != null &&
        !trimmed.toLowerCase().startsWith('http') &&
        !colon.group(1)!.contains('.')) {
      flushParagraph();
      flushBullets();
      defs.add((colon.group(1)!.trim(), colon.group(2)!.trim()));
      continue;
    }

    flushBullets();
    flushDefs();
    // Split "Intro: • a • b" / "Intro. • a\n• b" into paragraph + bullets.
    if (trimmed.contains('•')) {
      final parts = trimmed.split(RegExp(r'\s*•\s*'));
      final lead = parts.first.trim();
      if (lead.isNotEmpty) {
        paragraph.add(lead);
        flushParagraph();
      } else {
        flushParagraph();
      }
      for (var i = 1; i < parts.length; i++) {
        final item = parts[i].trim();
        if (item.isNotEmpty) bullets.add(('•', item));
      }
      continue;
    }

    paragraph.add(trimmed);
  }

  flushParagraph();
  flushBullets();
  flushDefs();
  return blocks;
}

/// Corporate bottom sheet for privacy / permissions / rights style documents.
Future<void> showFamilyDocumentSheet({
  required BuildContext context,
  required String title,
  String? intro,
  required List<FamilyDocSection> sections,
  required String closeLabel,
  IconData icon = Icons.article_outlined,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final scheme = theme.colorScheme;
      final height = MediaQuery.sizeOf(ctx).height * 0.88;
      return SafeArea(
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: scheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    if (intro != null && intro.trim().isNotEmpty) ...[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest.withValues(
                            alpha: 0.55,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: scheme.outlineVariant.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: FamilyRichBody(intro),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    for (var i = 0; i < sections.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _FamilyDocSectionCard(
                        index: i + 1,
                        section: sections[i],
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(closeLabel),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _FamilyDocSectionCard extends StatelessWidget {
  const _FamilyDocSectionCard({
    required this.index,
    required this.section,
  });

  final int index;
  final FamilyDocSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    section.title.replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FamilyRichBody(section.body),
          ],
        ),
      ),
    );
  }
}
