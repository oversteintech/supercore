import 'package:flutter/material.dart';

import 'family_rich_document.dart';
import 'family_ui_strings.dart';

/// Opens the shared KVKK / privacy / terms / permissions sheet (20 locales).
///
/// Used by Settings and by first-launch Legal taps when products do not
/// supply a custom document screen.
Future<void> openFamilyLegalDocument(
  BuildContext context, {
  required String localeCode,
  required String appName,
  required String supportEmail,
  required FamilyLegalDocumentKind kind,
}) {
  String s(String key) => FamilyUiStrings.t(
        key,
        localeCode,
        args: {'app': appName, 'email': supportEmail},
      );

  switch (kind) {
    case FamilyLegalDocumentKind.privacy:
      return showFamilyDocumentSheet(
        context: context,
        title: s('privacy_policy'),
        intro: s('privacy_policy_intro'),
        closeLabel: s('ok'),
        sections: [
          for (var i = 1; i <= 8; i++)
            FamilyDocSection(
              title: s('privacy_s${i}_title'),
              body: s('privacy_s${i}_body'),
            ),
        ],
        icon: Icons.privacy_tip_rounded,
      );
    case FamilyLegalDocumentKind.terms:
      return showFamilyDocumentSheet(
        context: context,
        title: s('terms'),
        intro: s('terms_intro'),
        closeLabel: s('ok'),
        sections: [
          for (var i = 1; i <= 6; i++)
            FamilyDocSection(
              title: s('terms_s${i}_title'),
              body: s('terms_s${i}_body'),
            ),
        ],
        icon: Icons.description_rounded,
      );
    case FamilyLegalDocumentKind.permissions:
      return showFamilyDocumentSheet(
        context: context,
        title: s('permissions'),
        intro: s('permissions_body'),
        closeLabel: s('ok'),
        sections: [
          for (var i = 1; i <= 3; i++)
            FamilyDocSection(
              title: s('privacy_perm_s${i}_title'),
              body: s('privacy_perm_s${i}_body'),
            ),
        ],
        icon: Icons.security_rounded,
      );
  }
}

enum FamilyLegalDocumentKind { privacy, terms, permissions }
