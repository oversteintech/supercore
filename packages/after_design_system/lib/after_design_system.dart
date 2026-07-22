/// After Design System — shared visual language for AfterArtificial Super Apps.
///
/// Premium AI-first tokens and components. Apply with [AfterThemeData.light]
/// / [AfterThemeData.dark], then use `After*` widgets throughout the product.
library;

// Foundations
export 'src/foundations/colors.dart';
export 'src/foundations/elevations.dart';
export 'src/foundations/icons.dart';
export 'src/foundations/motion.dart';
export 'src/foundations/radius.dart';
export 'src/foundations/shadows.dart';
export 'src/foundations/spacing.dart';
export 'src/foundations/theme.dart';
export 'src/foundations/typography.dart';

// Components
export 'src/components/buttons.dart';
export 'src/components/cards.dart';
export 'src/components/charts.dart';
export 'src/components/dashboard.dart';
export 'src/components/dialogs.dart';
export 'src/components/empty_states.dart';
export 'src/components/inputs.dart';
export 'src/components/loading.dart';
export 'src/components/navigation_bar.dart';
export 'src/components/shell_top_bar.dart';
export 'src/components/settings_section.dart';
export 'src/components/premium_themes_accordion.dart';

// Premium themes (Garage flagship pack — shared across Super Apps)
export 'src/premium_themes/theme.dart';
export 'src/premium_themes/after_theme_style.dart';
export 'src/premium_themes/after_framework_theme.dart';
export 'src/premium_themes/after_premium_app_shell.dart';
export 'src/premium_themes/premium_theme_shell.dart';
export 'src/premium_themes/overstein_brand_colors.dart';

// OVERSTEIN company branding (identical splash across every Super App)
export 'src/branding/overstein_logo.dart';
export 'src/branding/overstein_company_splash.dart'
    show
        AfterLaunchShell,
        OversteinCompanySplash,
        OversteinCompanySplashStore,
        OversteinCompanySplashTiming;
export 'src/branding/after_product_icons.dart';

// Membership chrome (Garage-parity header colors)
export 'src/membership/after_user_plan_colors.dart';
