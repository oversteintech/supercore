import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Garage-parity collapsible host for premium theme tiles.
///
/// Put premium theme children under this accordion — never as a flat chip row
/// beside Light/Dark.
///
/// When collapsed, only the title shows on the banner (no subtitle). Expanding
/// reveals the subtitle plus the theme tiles.
class AfterPremiumThemesAccordion extends StatefulWidget {
  const AfterPremiumThemesAccordion({
    required this.title,
    required this.subtitle,
    required this.locked,
    required this.children,
    this.initiallyExpanded = false,
    this.controller,
    this.expansionStorageId,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool locked;
  final bool initiallyExpanded;
  final List<Widget> children;
  final ExpansibleController? controller;
  final String? expansionStorageId;

  @override
  State<AfterPremiumThemesAccordion> createState() =>
      _AfterPremiumThemesAccordionState();
}

class _AfterPremiumThemesAccordionState
    extends State<AfterPremiumThemesAccordion> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant AfterPremiumThemesAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded &&
        widget.controller == null) {
      _expanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        controller: widget.controller,
        initiallyExpanded: widget.initiallyExpanded,
        maintainState: false,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 12),
        showTrailingIcon: false,
        onExpansionChanged: (expanded) {
          setState(() => _expanded = expanded);
        },
        title: AfterPremiumThemesBanner(
          title: widget.title,
          subtitle: widget.subtitle,
          locked: widget.locked,
          showSubtitle: _expanded,
        ),
        children: [
          ClipRect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium themes accordion header — contrast flips with theme brightness.
///
/// Dark app theme → white panel + dark text.
/// Light app theme → dark panel + light text.
class AfterPremiumThemesBanner extends StatefulWidget {
  const AfterPremiumThemesBanner({
    required this.title,
    required this.subtitle,
    required this.locked,
    this.showSubtitle = true,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool locked;

  /// When false (collapsed accordion), only the title is shown.
  final bool showSubtitle;

  static const _silverMid = Color(0xFFB8BEC6);

  static const _frameGradientLight = <Color>[
    Color(0xFFFFFFFF),
    Color(0xFFE5E7EB),
    Color(0xFFB8BEC6),
    Color(0xFF9CA3AF),
    Color(0xFF6B7280),
    Color(0xFFB8BEC6),
    Color(0xFFF3F4F6),
    Color(0xFFFFFFFF),
  ];

  static const _frameGradientDark = <Color>[
    Color(0xFF111827),
    Color(0xFF374151),
    Color(0xFF6B7280),
    Color(0xFF9CA3AF),
    Color(0xFF4B5563),
    Color(0xFF1F2937),
    Color(0xFF111827),
  ];

  @override
  State<AfterPremiumThemesBanner> createState() =>
      _AfterPremiumThemesBannerState();
}

class _AfterPremiumThemesBannerState extends State<AfterPremiumThemesBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _frameController;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _frameController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce == _reduceMotion) {
      if (!reduce && !_frameController.isAnimating) {
        _frameController.repeat();
      }
      return;
    }
    _reduceMotion = reduce;
    if (reduce) {
      _frameController.stop();
      _frameController.value = 0;
    } else {
      _frameController.repeat();
    }
  }

  @override
  void dispose() {
    _frameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Dark chrome → white fill; light chrome → dark fill.
    final fill = isDark ? Colors.white : const Color(0xFF1F2937);
    final text = isDark ? const Color(0xFF1F2937) : Colors.white;
    final frame = isDark
        ? AfterPremiumThemesBanner._frameGradientLight
        : AfterPremiumThemesBanner._frameGradientDark;
    final spin = _reduceMotion ? 0.0 : _frameController.value;

    return AnimatedBuilder(
      animation: _frameController,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: SweepGradient(
              colors: frame,
              transform: GradientRotation(spin * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: AfterPremiumThemesBanner._silverMid.withValues(
                  alpha: isDark ? 0.28 : 0.4,
                ),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.2),
            child: child,
          ),
        );
      },
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Icon(
                widget.locked
                    ? Icons.lock_rounded
                    : Icons.auto_awesome_rounded,
                color: text.withValues(alpha: 0.88),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: text,
                        height: 1.15,
                      ),
                    ),
                    if (widget.showSubtitle &&
                        widget.subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: text.withValues(alpha: 0.72),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.expand_more_rounded,
                color: text.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
