import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalog/enterprise_feature_catalog.dart';
import '../di/enterprise_providers.dart';
import '../runtime/enterprise_product_runtime.dart';

/// Platform-owned enterprise tabs — identical across every B2B Super App.
enum EnterpriseShellTab {
  home,
  tasks,
  calendar,
  documents,
  ai,
  more,
}

final enterpriseShellTabProvider =
    NotifierProvider<EnterpriseShellTabNotifier, EnterpriseShellTab>(
  EnterpriseShellTabNotifier.new,
);

class EnterpriseShellTabNotifier extends Notifier<EnterpriseShellTab> {
  @override
  EnterpriseShellTab build() => EnterpriseShellTab.home;

  void select(EnterpriseShellTab tab) => state = tab;
}

/// Auth gate owned by the platform. Products only supply [login] + [home].
class AfterEnterpriseAuthGate extends ConsumerWidget {
  const AfterEnterpriseAuthGate({
    required this.login,
    required this.home,
    super.key,
  });

  final Widget login;
  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(afterAuthSessionProvider);
    return sessionAsync.when(
      loading: () => const Scaffold(body: Center(child: AfterLoading())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Auth error: $error', textAlign: TextAlign.center),
          ),
        ),
      ),
      data: (session) {
        if (session.isLoading) {
          return const Scaffold(body: Center(child: AfterLoading()));
        }
        if (!session.isAuthenticated) return login;
        return home;
      },
    );
  }
}

/// Platform MainShell — tabs never diverge per vertical.
///
/// Products inject vertical feature pages via [onOpenFeature] and optional
/// [homeHeader]. OS module bodies are platform placeholders until richer
/// shared screens land; they must not be re-forked in product repos.
class AfterEnterpriseMainShell extends ConsumerStatefulWidget {
  const AfterEnterpriseMainShell({
    required this.onOpenFeature,
    super.key,
    this.homeHeader,
    this.resolveLabel,
    this.aiBody,
    this.tasksBody,
    this.calendarBody,
    this.documentsBody,
    this.moreBody,
  });

  final EnterpriseFeaturePageBuilder onOpenFeature;
  final EnterpriseHomeHeaderBuilder? homeHeader;
  final String Function(String key)? resolveLabel;
  final Widget? aiBody;
  final Widget? tasksBody;
  final Widget? calendarBody;
  final Widget? documentsBody;
  final Widget? moreBody;

  @override
  ConsumerState<AfterEnterpriseMainShell> createState() =>
      _AfterEnterpriseMainShellState();
}

class _AfterEnterpriseMainShellState
    extends ConsumerState<AfterEnterpriseMainShell> {
  final Set<int> _visited = <int>{EnterpriseShellTab.home.index};
  final Map<int, Widget> _bodies = <int, Widget>{};

  String _tr(String key) => widget.resolveLabel?.call(key) ?? key;

  Widget _body(int index) {
    return _bodies.putIfAbsent(index, () {
      switch (EnterpriseShellTab.values[index]) {
        case EnterpriseShellTab.home:
          return _PlatformHome(
            header: widget.homeHeader,
            resolveLabel: _tr,
            onOpenFeature: widget.onOpenFeature,
          );
        case EnterpriseShellTab.tasks:
          return widget.tasksBody ??
              _OsModulePlaceholder(
                title: _tr('nav.tasks'),
                message: 'Tasks module — platform owned (after_enterprise).',
              );
        case EnterpriseShellTab.calendar:
          return widget.calendarBody ??
              _OsModulePlaceholder(
                title: _tr('nav.calendar'),
                message: 'Calendar module — platform owned (after_enterprise).',
              );
        case EnterpriseShellTab.documents:
          return widget.documentsBody ??
              _OsModulePlaceholder(
                title: _tr('nav.documents'),
                message:
                    'Documents module — platform owned (after_enterprise).',
              );
        case EnterpriseShellTab.ai:
          return widget.aiBody ??
              _OsModulePlaceholder(
                title: _tr('nav.ai'),
                message: 'Enterprise AI — bind via after_ai / EnterpriseAi.',
              );
        case EnterpriseShellTab.more:
          return widget.moreBody ?? const _PlatformMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(enterpriseShellTabProvider);
    final index = EnterpriseShellTab.values.indexOf(tab);
    _visited.add(index);
    final runtime = ref.watch(enterpriseProductRuntimeProvider);
    final appName = runtime.manifest.appName.trim();
    final shortTitle = appName.toLowerCase().startsWith('super') &&
            appName.length > 5
        ? appName.substring(5).trim()
        : appName;

    return Scaffold(
      body: Column(
        children: [
          AfterShellTopBar(
            plan: AfterUserPlan.free,
            title: shortTitle,
            locationLabel: null,
            onLocationTap: () {},
            onNotifications: () {},
            onAi: () {
              ref
                  .read(enterpriseShellTabProvider.notifier)
                  .select(EnterpriseShellTab.ai);
            },
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                for (final tabIndex in _visited)
                  Offstage(
                    offstage: tabIndex != index,
                    child: TickerMode(
                      enabled: tabIndex == index,
                      child: KeyedSubtree(
                        key: ValueKey<int>(tabIndex),
                        child: _body(tabIndex),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AfterNavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          ref
              .read(enterpriseShellTabProvider.notifier)
              .select(EnterpriseShellTab.values[i]);
        },
        destinations: [
          AfterNavDestination(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: _tr('nav.home'),
          ),
          AfterNavDestination(
            icon: Icons.checklist_outlined,
            selectedIcon: Icons.checklist,
            label: _tr('nav.tasks'),
          ),
          AfterNavDestination(
            icon: Icons.calendar_today_outlined,
            selectedIcon: Icons.calendar_today,
            label: _tr('nav.calendar'),
          ),
          AfterNavDestination(
            icon: Icons.folder_outlined,
            selectedIcon: Icons.folder,
            label: _tr('nav.documents'),
          ),
          AfterNavDestination(
            icon: Icons.auto_awesome_outlined,
            selectedIcon: Icons.auto_awesome,
            label: _tr('nav.ai'),
          ),
          AfterNavDestination(
            icon: Icons.more_horiz,
            selectedIcon: Icons.more_horiz,
            label: _tr('nav.more'),
          ),
        ],
      ),
    );
  }
}

class _PlatformHome extends ConsumerWidget {
  const _PlatformHome({
    required this.onOpenFeature,
    required this.resolveLabel,
    this.header,
  });

  final EnterpriseHomeHeaderBuilder? header;
  final EnterpriseFeaturePageBuilder onOpenFeature;
  final String Function(String key) resolveLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(enterpriseProductRuntimeProvider);
    final widgets = ref.watch(afterDashboardVisibleWidgetsProvider);
    final features = runtime.features;

    return AfterScaffoldBody(
      child: ListView(
        padding: const EdgeInsets.all(AfterSpacing.md),
        children: [
          if (header != null) ...[
            header!(context),
            const SizedBox(height: AfterSpacing.md),
          ],
          Text(
            runtime.manifest.appName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            runtime.domain,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AfterSpacing.md),
          if (widgets.isNotEmpty)
            AfterDashboard(
              widgets: widgets,
              shrinkWrap: true,
              resolveLabel: resolveLabel,
              padding: EdgeInsets.zero,
            ),
          const SizedBox(height: AfterSpacing.lg),
          AfterSectionHeader(title: resolveLabel('nav.features')),
          const SizedBox(height: AfterSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final feature = features[index];
              return AfterCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => onOpenFeature(ctx, feature),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.extension_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Spacer(),
                    Text(
                      resolveLabel(feature.titleKey),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      resolveLabel(feature.subtitleKey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OsModulePlaceholder extends StatelessWidget {
  const _OsModulePlaceholder({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AfterEmptyState(
      title: title,
      subtitle: message,
      icon: Icons.widgets_outlined,
    );
  }
}

class _PlatformMore extends ConsumerWidget {
  const _PlatformMore();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(enterpriseProductRuntimeProvider);
    final session = ref.watch(afterAuthSessionProvider).value;
    final email = session?.user?.email;
    final isAdmin = AfterSuperAdmin.isSuperAdminEmail(email);
    final org = ref.watch(currentOrganizationProvider);

    return ListView(
      padding: const EdgeInsets.all(AfterSpacing.md),
      children: [
        AfterCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                runtime.manifest.appName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${runtime.manifest.packageName} · '
                '${runtime.manifest.productLine.name}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              org.when(
                data: (o) => Text(
                  o?.name ?? 'No organization',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 8),
                Text(
                  'AfterSuperAdmin: ${email ?? ''}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AfterSpacing.md),
        const AfterEmptyState(
          title: 'Organization · RBAC · Audit · Settings',
          subtitle:
              'Enterprise OS surfaces — inherited from after_enterprise. '
              'Do not re-implement in the product repo.',
          icon: Icons.settings_outlined,
        ),
      ],
    );
  }
}
