# After Design System

Shared visual language for **AfterArtificial** Super Apps (reference: Super Garage by OVERSTEIN).

Premium, AI-first UI — calm like Apple, precise like Linear — with a unique ice-on-graphite identity.

## Install

```yaml
dependencies:
  after_design_system:
    path: packages/after_design_system
```

## Quick start

```dart
import 'package:after_design_system/after_design_system.dart';

MaterialApp(
  theme: AfterThemeData.light(),
  darkTheme: AfterThemeData.dark(),
  themeMode: ThemeMode.system,
  home: Scaffold(
    appBar: AfterAppBar(title: const Text('Super App')),
    body: AfterScaffoldBody(
      child: Column(
        children: [
          AfterCard(
            child: Text('Hello', style: context.afterTypography.titleMedium),
          ),
          AfterButton(
            label: 'Ask Mate',
            variant: AfterButtonVariant.ai,
            icon: AfterIcons.ai,
            onPressed: () {},
          ),
        ],
      ),
    ),
    bottomNavigationBar: AfterNavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      destinations: const [
        AfterNavDestination(icon: AfterIcons.home, label: 'Home'),
        AfterNavDestination(icon: AfterIcons.ai, label: 'AI'),
      ],
    ),
  ),
);
```

## Contents

| Area | API |
|------|-----|
| Colors | `AfterColors`, `AfterColorScheme` |
| Typography | `AfterTypography` |
| Spacing | `AfterSpacing` |
| Radius | `AfterRadius` |
| Elevation / shadows | `AfterElevations`, `AfterShadows` |
| Motion | `AfterMotion`, `AfterFadeSlide` |
| Icons | `AfterIconSpec`, `AfterIcons`, `AfterIcon` |
| Theme | `AfterThemeData`, `context.afterColors` |
| Buttons | `AfterButton`, `AfterIconButton` |
| Cards | `AfterCard`, `AfterScaffoldBody` |
| Dialogs | `showAfterDialog`, `showAfterBottomSheet` |
| Navigation | `AfterNavigationBar`, `AfterAppBar`, `AfterSegmentedControl` |
| Inputs | `AfterTextField`, `AfterSearchField`, `AfterSwitchTile` |
| Charts | `AfterSparkline`, `AfterBarChart`, `AfterProgressRing` |
| Empty states | `AfterEmptyState`, `AfterInlineBanner` |
| Loading | `AfterLoading`, `AfterSkeleton`, `AfterAiThinking` |

## Design principles

1. **Ice on graphite** — luminous cyan/ice accent on OVERSTEIN graphite; never default purple gradients.
2. **Hairline over blob** — prefer 1px borders; soft layered shadows only when elevated.
3. **Motion budget** — shell / hero / AI thinking; not every card.
4. **Shared states** — use `AfterLoading` / `AfterEmptyState` instead of one-offs.
5. **Platform fonts** — SF / Roboto by default; override via `AfterTypography(fontFamily: …)`.

See also: `docs/AFTERARTIFICIAL_PLATFORM_STANDARD_v1.md`.
