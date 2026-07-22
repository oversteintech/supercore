import 'dart:async';
import 'dart:convert';

import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  const FamilyEmergencyProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(familyEmergencyProfileProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Could not load emergency profile',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (profile) {
        if (!profile.consentAccepted) {
          return _ConsentGate(
            onAccept: () => unawaited(
              ref.read(familyEmergencyProfileProvider.notifier).acceptConsent(),
            ),
          );
        }
        return _EmergencyForm(profile: profile);
      },
    );
  }
}

class _ConsentGate extends StatelessWidget {
  const _ConsentGate({required this.onAccept});

  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.health_and_safety_rounded),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Emergency profile privacy',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Blood type, contacts, and medical notes stay on this device '
                  'unless you later enable cloud sync. Share them only with '
                  'people you trust in an emergency.',
                  style: TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.check_rounded),
            label: const Text('I understand — set up profile'),
          ),
        ],
      ),
    );
  }
}

class _EmergencyForm extends ConsumerWidget {
  const _EmergencyForm({required this.profile});

  final FamilyEmergencyProfile profile;

  Future<void> _editText({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String? current,
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
          maxLines: title.contains('Notes') || title.contains('Allerg') ? 4 : 1,
          decoration: InputDecoration(hintText: title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
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
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.bloodtype_rounded),
          title: const Text('Blood type'),
          subtitle: Text(profile.bloodType?.trim().isNotEmpty == true
              ? profile.bloodType!
              : 'Not set'),
          trailing: const Icon(Icons.edit_outlined, size: 18),
          onTap: () async {
            final selected = await showDialog<String>(
              context: context,
              builder: (ctx) => SimpleDialog(
                title: const Text('Blood type'),
                children: [
                  for (final type in _kBloodTypes)
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, type),
                      child: Text(type),
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
          title: const Text('Emergency contact'),
          subtitle: Text(
            [
              if (profile.contactName?.trim().isNotEmpty == true)
                profile.contactName!,
              if (profile.contactPhone?.trim().isNotEmpty == true)
                profile.contactPhone!,
              if (profile.contactRelationship?.trim().isNotEmpty == true)
                profile.contactRelationship!,
            ].isEmpty
                ? 'Add a primary contact'
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
          title: 'Allergies',
          value: profile.allergies,
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
          title: 'Medical conditions',
          value: profile.medicalConditions,
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
          title: 'Medications',
          value: profile.medications,
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
          title: 'Emergency notes',
          value: profile.emergencyNotes,
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
    required FamilyEmergencyProfile Function(String?) apply,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value?.trim().isNotEmpty == true ? value! : 'Not set'),
      trailing: const Icon(Icons.edit_outlined, size: 18),
      onTap: () => unawaited(
        _editText(
          context: context,
          ref: ref,
          title: title,
          current: value,
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emergency contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: relCtrl,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
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
