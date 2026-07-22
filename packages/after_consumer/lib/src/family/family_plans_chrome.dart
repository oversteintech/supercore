import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';

import 'family_chrome.dart';
import 'family_membership_badge.dart';
import 'family_membership_controller.dart';

/// Canonical consumer ladder — same as SuperGarage (Free / Silver / Gold / Business).
abstract final class FamilyPlanCatalog {
  static const List<AfterUserPlan> selectable = [
    AfterUserPlan.free,
    AfterUserPlan.premium,
    AfterUserPlan.superPlan,
    AfterUserPlan.business,
  ];

  static String title(AfterUserPlan plan) => switch (plan) {
        AfterUserPlan.free => 'Free',
        AfterUserPlan.premium => 'Silver',
        AfterUserPlan.superPlan => 'Gold',
        AfterUserPlan.business => 'Business',
        AfterUserPlan.superadmin => 'Admin',
      };

  static String badge(AfterUserPlan plan) =>
      AfterMembershipBadge.forPlan(plan);

  static String summary(AfterUserPlan plan) => switch (plan) {
        AfterUserPlan.free =>
          'Essential access — core features for getting started.',
        AfterUserPlan.premium =>
          'Silver — premium themes, comfort extras, personalization. 3 months free.',
        AfterUserPlan.superPlan =>
          'Gold — unlimited AI, live data, community & advanced tools. 2 months free.',
        AfterUserPlan.business =>
          'Business — fleets, teams, export & org-ready capabilities.',
        AfterUserPlan.superadmin => 'Full platform access.',
      };

  static String? highlight(AfterUserPlan plan) => switch (plan) {
        AfterUserPlan.premium => '3 months free',
        AfterUserPlan.superPlan => '2 months free',
        AfterUserPlan.business => 'Best for teams',
        _ => null,
      };
}

bool _familyPlansSheetVisible = false;

Future<bool> showFamilyPlansSheet({
  required BuildContext context,
  required FamilyChromeConfig config,
  required FamilyMembershipState membership,
  required Future<void> Function(AfterUserPlan plan) onSetPlan,
  AfterUserPlan? highlightPlan,
  Future<void> Function(AfterUserPlan plan)? onPurchasePlan,
  String? footerNote,
}) async {
  if (_familyPlansSheetVisible) return false;
  _familyPlansSheetVisible = true;
  try {
    final result = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => FamilyPlansSheet(
        config: config,
        membership: membership,
        onSetPlan: onSetPlan,
        highlightPlan: highlightPlan,
        onPurchasePlan: onPurchasePlan,
        footerNote: footerNote,
      ),
    );
    return result ?? false;
  } finally {
    _familyPlansSheetVisible = false;
  }
}

/// Garage-parity plan picker sheet (mock select for scaffolds).
class FamilyPlansSheet extends StatelessWidget {
  const FamilyPlansSheet({
    required this.config,
    required this.membership,
    required this.onSetPlan,
    this.highlightPlan,
    this.onPurchasePlan,
    this.footerNote,
    super.key,
  });

  final FamilyChromeConfig config;
  final FamilyMembershipState membership;
  final Future<void> Function(AfterUserPlan plan) onSetPlan;

  /// Optional IAP / store purchase path (flagship Garage). When set, paid
  /// plan taps call this instead of [onSetPlan].
  final Future<void> Function(AfterUserPlan plan)? onPurchasePlan;
  final AfterUserPlan? highlightPlan;
  final String? footerNote;

  @override
  Widget build(BuildContext context) {
    final current = membership.plan;
    // Leave headroom for the modal drag handle so tall plan lists scroll
    // instead of overflowing the screen (Garage upgrade sheet pattern).
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your plan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '${config.appName} — Free, Silver, Gold & Business',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              for (final plan in FamilyPlanCatalog.selectable) ...[
                FamilyPlanTile(
                  plan: plan,
                  selected: current == plan ||
                      (plan == AfterUserPlan.superPlan &&
                          membership.isSuperAdmin),
                  highlighted: highlightPlan == plan ||
                      FamilyPlanCatalog.highlight(plan) != null,
                  highlightLabel: FamilyPlanCatalog.highlight(plan),
                  enabled: !membership.isSuperAdmin,
                  onSelect: membership.isSuperAdmin
                      ? null
                      : () async {
                          final purchase = onPurchasePlan;
                          if (purchase != null && plan != AfterUserPlan.free) {
                            await purchase(plan);
                          } else {
                            await onSetPlan(plan);
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                ),
                const SizedBox(height: 10),
              ],
              if (membership.isSuperAdmin)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Admin plan is active — tier selection is locked.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: config.accent,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                footerNote ??
                    (onPurchasePlan != null
                        ? 'Store billing applies for paid tiers.'
                        : 'Scaffold billing: selecting a plan updates membership '
                            'instantly. Store IAP plugs in later via After '
                            'subscription ports.'),
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FamilyPlanTile extends StatelessWidget {
  const FamilyPlanTile({
    required this.plan,
    required this.selected,
    required this.enabled,
    this.highlighted = false,
    this.highlightLabel,
    this.onSelect,
    super.key,
  });

  final AfterUserPlan plan;
  final bool selected;
  final bool enabled;
  final bool highlighted;
  final String? highlightLabel;
  final Future<void> Function()? onSelect;

  @override
  Widget build(BuildContext context) {
    final accent = AfterUserPlanColors.accent(plan);
    final border = highlighted || selected
        ? accent
        : Theme.of(context).colorScheme.outlineVariant;

    return Material(
      color: AfterUserPlanColors.tileBackground(
        plan,
        Theme.of(context).colorScheme,
      ),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: (!enabled || onSelect == null)
            ? null
            : () => unawaited(onSelect!()),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: border,
              width: selected || highlighted ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (highlightLabel != null && !selected) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    highlightLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FamilyMembershipPlanBadge(
                    plan: plan,
                    label: FamilyPlanCatalog.badge(plan),
                    pill: true,
                    fontSize: 11,
                  ),
                  Text(
                    FamilyPlanCatalog.title(plan),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded, color: accent, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                FamilyPlanCatalog.summary(plan),
                style: TextStyle(
                  height: 1.35,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (enabled && !selected && onSelect != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => unawaited(onSelect!()),
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    child: Text(
                      plan == AfterUserPlan.free ? 'Select Free' : 'Choose plan',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen membership / plans (Garage ladder).
class FamilyMembershipPlansScreen extends StatelessWidget {
  const FamilyMembershipPlansScreen({
    required this.config,
    required this.membership,
    required this.onSetPlan,
    super.key,
  });

  final FamilyChromeConfig config;
  final FamilyMembershipState membership;
  final Future<void> Function(AfterUserPlan plan) onSetPlan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membership')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SuperGarageCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current plan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  FamilyMembershipPlanBadge(
                    plan: membership.plan,
                    label: membership.badge,
                    pill: true,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    FamilyPlanCatalog.title(membership.plan),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(FamilyPlanCatalog.summary(membership.plan)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Plans',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          for (final plan in FamilyPlanCatalog.selectable) ...[
            FamilyPlanTile(
              plan: plan,
              selected: membership.plan == plan ||
                  (plan == AfterUserPlan.superPlan && membership.isSuperAdmin),
              highlighted: FamilyPlanCatalog.highlight(plan) != null &&
                  plan == AfterUserPlan.superPlan,
              highlightLabel: FamilyPlanCatalog.highlight(plan),
              enabled: !membership.isSuperAdmin,
              onSelect: membership.isSuperAdmin
                  ? null
                  : () => onSetPlan(plan),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
