/// After Consumer — OS layer for AfterArtificial B2C Super Apps.
///
/// A thin set of helpers on top of `after_core` that keeps the consumer
/// family (SuperGarage reference, SuperHealth, SuperFinance, SuperHome,
/// SuperTravel, SuperPet, SuperSports, SuperNews, SuperFarm, …)
/// architecturally consistent.
library;

export 'package:after_design_system/after_design_system.dart'
    show
        AfterProductIconCatalog,
        AfterProductIconMark,
        AfterProductIconSpec,
        AfterProductIconStyle,
        AfterProductIconStyleAccess,
        AfterProductId;

export 'src/catalog/consumer_feature_catalog.dart';
export 'src/di/consumer_providers.dart';
export 'src/family/entity_editor_sheet.dart';
export 'src/family/family_animated_profile_avatar.dart';
export 'src/family/family_auth_chrome.dart';
export 'src/family/family_auth_wiring.dart';
export 'src/family/family_avatar_options.dart';
export 'src/family/family_avatar_picker.dart';
export 'src/family/family_chrome.dart';
export 'src/family/family_cloud_sync.dart';
export 'src/family/family_crud_list_page.dart';
export 'src/family/family_dashboard.dart';
export 'src/family/family_field_labels.dart';
export 'src/family/family_map_record.dart';
export 'src/family/family_membership_controller.dart';
export 'src/family/family_scoped_list.dart';
export 'src/family/family_session_effects.dart';
export 'src/family/family_membership_badge.dart';
export 'src/family/family_plans_chrome.dart';
export 'src/family/family_profile_field_editors.dart';
export 'src/family/family_profile_identity.dart';
export 'src/family/family_settings_chrome.dart';
export 'src/family/family_settings_screen.dart';
export 'src/family/family_emergency_profile.dart';
export 'src/family/family_shell_header.dart';
export 'src/family/family_theme.dart';
export 'src/family/family_theme_controller.dart';
export 'src/family/family_product_icon_controller.dart';
export 'src/family/family_ui_strings.dart';
export 'src/launch/after_launch_consent.dart';
export 'src/launch/after_launch_consent_gate.dart';
export 'src/launch/after_launch_consent_strings.dart';
export 'src/launch/after_legal_consent_screen.dart';
export 'src/launch/after_location_permission.dart';
export 'src/launch/after_permission_consent_screen.dart';
export 'src/location/after_current_locality.dart';
export 'src/membership/consumer_membership.dart';
export 'src/vault/personal_vault.dart';
