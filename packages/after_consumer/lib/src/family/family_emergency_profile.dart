import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'family_ui_strings.dart';

/// Shared ICE (In Case of Emergency) profile — Garage-parity fields for every
/// Super App. Stored locally; cloud sync is product-specific later.
@immutable
class FamilyEmergencyProfile {
  const FamilyEmergencyProfile({
    this.consentAccepted = false,
    this.bloodType,
    this.allergies,
    this.medicalConditions,
    this.medications,
    this.emergencyNotes,
    this.contactName,
    this.contactPhone,
    this.contactRelationship,
  });

  final bool consentAccepted;
  final String? bloodType;
  final String? allergies;
  final String? medicalConditions;
  final String? medications;
  final String? emergencyNotes;
  final String? contactName;
  final String? contactPhone;
  final String? contactRelationship;

  FamilyEmergencyProfile copyWith({
    bool? consentAccepted,
    String? bloodType,
    String? allergies,
    String? medicalConditions,
    String? medications,
    String? emergencyNotes,
    String? contactName,
    String? contactPhone,
    String? contactRelationship,
    bool clearBloodType = false,
    bool clearAllergies = false,
    bool clearMedicalConditions = false,
    bool clearMedications = false,
    bool clearEmergencyNotes = false,
    bool clearContactName = false,
    bool clearContactPhone = false,
    bool clearContactRelationship = false,
  }) {
    return FamilyEmergencyProfile(
      consentAccepted: consentAccepted ?? this.consentAccepted,
      bloodType: clearBloodType ? null : bloodType ?? this.bloodType,
      allergies: clearAllergies ? null : allergies ?? this.allergies,
      medicalConditions: clearMedicalConditions
          ? null
          : medicalConditions ?? this.medicalConditions,
      medications: clearMedications ? null : medications ?? this.medications,
      emergencyNotes:
          clearEmergencyNotes ? null : emergencyNotes ?? this.emergencyNotes,
      contactName: clearContactName ? null : contactName ?? this.contactName,
      contactPhone:
          clearContactPhone ? null : contactPhone ?? this.contactPhone,
      contactRelationship: clearContactRelationship
          ? null
          : contactRelationship ?? this.contactRelationship,
    );
  }

  Map<String, Object?> toJson() => {
        'consentAccepted': consentAccepted,
        'bloodType': bloodType,
        'allergies': allergies,
        'medicalConditions': medicalConditions,
        'medications': medications,
        'emergencyNotes': emergencyNotes,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'contactRelationship': contactRelationship,
      };

  factory FamilyEmergencyProfile.fromJson(Map<String, dynamic> json) {
    return FamilyEmergencyProfile(
      consentAccepted: json['consentAccepted'] == true,
      bloodType: json['bloodType']?.toString(),
      allergies: json['allergies']?.toString(),
      medicalConditions: json['medicalConditions']?.toString(),
      medications: json['medications']?.toString(),
      emergencyNotes: json['emergencyNotes']?.toString(),
      contactName: json['contactName']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      contactRelationship: json['contactRelationship']?.toString(),
    );
  }
}

const _kEmergencyPrefsKey = 'after.family.emergency_profile.v1';

final familyEmergencyProfileProvider = AsyncNotifierProvider<
    FamilyEmergencyProfileController, FamilyEmergencyProfile>(
  FamilyEmergencyProfileController.new,
);

class FamilyEmergencyProfileController
    extends AsyncNotifier<FamilyEmergencyProfile> {
  @override
  Future<FamilyEmergencyProfile> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kEmergencyPrefsKey);
    if (raw == null || raw.isEmpty) {
      return const FamilyEmergencyProfile();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return FamilyEmergencyProfile.fromJson(map);
    } on Object {
      return const FamilyEmergencyProfile();
    }
  }

  Future<void> _persist(FamilyEmergencyProfile profile) async {
    state = AsyncData(profile);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmergencyPrefsKey, jsonEncode(profile.toJson()));
  }

  Future<void> acceptConsent() async {
    final current = state.asData?.value ?? const FamilyEmergencyProfile();
    await _persist(current.copyWith(consentAccepted: true));
  }

  Future<void> save(FamilyEmergencyProfile profile) => _persist(profile);
}

const _kBloodTypes = <String>[
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
  'Unknown',
];

/// Garage-parity emergency profile editor for Settings.
class FamilyEmergencyProfileSection extends ConsumerWidget {
  const FamilyEmergencyProfileSection({
    super.key,
    this.localeCode = 'en',
  });

  final String localeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(familyEmergencyProfileProvider);
    String t(String key) => FamilyUiStrings.t(key, localeCode);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          t('emergency_load_error'),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (profile) {
        if (!profile.consentAccepted) {
          return _ConsentGate(
            localeCode: localeCode,
            onAccept: () => unawaited(
              ref.read(familyEmergencyProfileProvider.notifier).acceptConsent(),
            ),
          );
        }
        return _EmergencyForm(profile: profile, localeCode: localeCode);
      },
    );
  }
}

class _ConsentGate extends StatelessWidget {
  const _ConsentGate({
    required this.onAccept,
    required this.localeCode,
  });

  final VoidCallback onAccept;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    String t(String key) => FamilyUiStrings.t(key, localeCode);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.health_and_safety_rounded),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t('emergency_privacy_title'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  t('emergency_privacy_body'),
                  style: const TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.check_rounded),
            label: Text(t('emergency_consent_cta')),
          ),
        ],
      ),
    );
  }
}

class _EmergencyForm extends ConsumerWidget {
  const _EmergencyForm({
    required this.profile,
    required this.localeCode,
  });

  final FamilyEmergencyProfile profile;
  final String localeCode;

  Future<void> _editText({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String? current,
    required bool multiline,
    required FamilyEmergencyProfile Function(String?) apply,
  }) async {
    final controller = TextEditingController(text: current ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: multiline ? 4 : 1,
          decoration: InputDecoration(hintText: title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(FamilyUiStrings.t('cancel', localeCode)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(FamilyUiStrings.t('save', localeCode)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    final next = apply(result.isEmpty ? null : result);
    await ref.read(familyEmergencyProfileProvider.notifier).save(next);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String t(String key) => FamilyUiStrings.t(key, localeCode);
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.bloodtype_rounded),
          title: Text(t('emergency_blood_type')),
          subtitle: Text(
            profile.bloodType?.trim().isNotEmpty == true
                ? profile.bloodType!
                : t('emergency_not_set'),
          ),
          trailing: const Icon(Icons.edit_outlined, size: 18),
          onTap: () async {
            final selected = await showDialog<String>(
              context: context,
              builder: (ctx) => SimpleDialog(
                title: Text(t('emergency_blood_type')),
                children: [
                  for (final type in _kBloodTypes)
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, type),
                      child: Text(
                        type == 'Unknown'
                            ? t('emergency_blood_unknown')
                            : type,
                      ),
                    ),
                ],
              ),
            );
            if (selected == null) return;
            await ref.read(familyEmergencyProfileProvider.notifier).save(
                  profile.copyWith(
                    bloodType: selected == 'Unknown' ? null : selected,
                    clearBloodType: selected == 'Unknown',
                  ),
                );
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.contact_emergency_rounded),
          title: Text(t('emergency_contact')),
          subtitle: Text(
            [
              if (profile.contactName?.trim().isNotEmpty == true)
                profile.contactName!,
              if (profile.contactPhone?.trim().isNotEmpty == true)
                profile.contactPhone!,
              if (profile.contactRelationship?.trim().isNotEmpty == true)
                profile.contactRelationship!,
            ].isEmpty
                ? t('emergency_contact_add')
                : [
                    if (profile.contactName?.trim().isNotEmpty == true)
                      profile.contactName!,
                    if (profile.contactPhone?.trim().isNotEmpty == true)
                      profile.contactPhone!,
                    if (profile.contactRelationship?.trim().isNotEmpty == true)
                      '(${profile.contactRelationship!})',
                  ].join(' · '),
          ),
          trailing: const Icon(Icons.edit_outlined, size: 18),
          onTap: () => unawaited(_editContact(context, ref)),
        ),
        const Divider(height: 1),
        _fieldTile(
          context,
          ref,
          icon: Icons.warning_amber_rounded,
          title: t('emergency_allergies'),
          value: profile.allergies,
          multiline: true,
          apply: (v) => profile.copyWith(
            allergies: v,
            clearAllergies: v == null,
          ),
        ),
        const Divider(height: 1),
        _fieldTile(
          context,
          ref,
          icon: Icons.medical_services_outlined,
          title: t('emergency_conditions'),
          value: profile.medicalConditions,
          multiline: false,
          apply: (v) => profile.copyWith(
            medicalConditions: v,
            clearMedicalConditions: v == null,
          ),
        ),
        const Divider(height: 1),
        _fieldTile(
          context,
          ref,
          icon: Icons.medication_rounded,
          title: t('emergency_medications'),
          value: profile.medications,
          multiline: false,
          apply: (v) => profile.copyWith(
            medications: v,
            clearMedications: v == null,
          ),
        ),
        const Divider(height: 1),
        _fieldTile(
          context,
          ref,
          icon: Icons.notes_rounded,
          title: t('emergency_notes'),
          value: profile.emergencyNotes,
          multiline: true,
          apply: (v) => profile.copyWith(
            emergencyNotes: v,
            clearEmergencyNotes: v == null,
          ),
        ),
      ],
    );
  }

  Widget _fieldTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String? value,
    required bool multiline,
    required FamilyEmergencyProfile Function(String?) apply,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value?.trim().isNotEmpty == true
            ? value!
            : FamilyUiStrings.t('emergency_not_set', localeCode),
      ),
      trailing: const Icon(Icons.edit_outlined, size: 18),
      onTap: () => unawaited(
        _editText(
          context: context,
          ref: ref,
          title: title,
          current: value,
          multiline: multiline,
          apply: apply,
        ),
      ),
    );
  }

  Future<void> _editContact(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController(text: profile.contactName ?? '');
    final phoneCtrl = TextEditingController(text: profile.contactPhone ?? '');
    final relCtrl =
        TextEditingController(text: profile.contactRelationship ?? '');
    String t(String key) => FamilyUiStrings.t(key, localeCode);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('emergency_contact')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: t('emergency_name')),
              ),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: t('phone')),
              ),
              TextField(
                controller: relCtrl,
                decoration: InputDecoration(
                  labelText: t('emergency_relationship'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('save')),
          ),
        ],
      ),
    );
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final rel = relCtrl.text.trim();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    relCtrl.dispose();
    if (ok != true) return;
    await ref.read(familyEmergencyProfileProvider.notifier).save(
          profile.copyWith(
            contactName: name.isEmpty ? null : name,
            contactPhone: phone.isEmpty ? null : phone,
            contactRelationship: rel.isEmpty ? null : rel,
            clearContactName: name.isEmpty,
            clearContactPhone: phone.isEmpty,
            clearContactRelationship: rel.isEmpty,
          ),
        );
  }
}
