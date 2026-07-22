import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sortFamilyDashboardSections orders by priority then order', () {
    final sections = sortFamilyDashboardSections([
      FamilyDashboardSection(
        id: 'b',
        priority: FamilyDashboardPriority.dailyValue,
        order: 2,
        builder: (_) => const SizedBox(),
      ),
      FamilyDashboardSection(
        id: 'a',
        priority: FamilyDashboardPriority.hero,
        order: 0,
        builder: (_) => const SizedBox(),
      ),
      FamilyDashboardSection(
        id: 'hidden',
        priority: FamilyDashboardPriority.hero,
        visible: false,
        builder: (_) => const SizedBox(),
      ),
    ]);
    expect(sections.map((s) => s.id), ['a', 'b']);
  });

  test('FamilyMembershipController persists plan', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        afterSharedPreferencesProvider.overrideWithValue(prefs),
        afterAuthRepositoryProvider.overrideWithValue(
          FamilyMockAuthRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final provider =
        NotifierProvider<FamilyMembershipController, FamilyMembershipState>(
      () => FamilyMembershipController('test.plan'),
    );

    expect(container.read(provider).plan, AfterUserPlan.free);
    await container.read(provider.notifier).setPlan(AfterUserPlan.premium);
    expect(container.read(provider).plan, AfterUserPlan.premium);
    expect(prefs.getString('test.plan'), 'premium');
  });

  test('FamilyScopedListController upsert and delete', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        afterSharedPreferencesProvider.overrideWithValue(prefs),
        afterAuthRepositoryProvider.overrideWithValue(
          FamilyMockAuthRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final provider = NotifierProvider<_ItemList, List<_Item>>(
      _ItemList.new,
    );
    await container.read(provider.notifier).upsert(const _Item(id: '1', title: 'A'));
    await container.read(provider.notifier).upsert(const _Item(id: '2', title: 'B'));
    expect(container.read(provider), hasLength(2));
    await container.read(provider.notifier).deleteById('1');
    expect(container.read(provider).single.id, '2');
  });
}

class _Item {
  const _Item({required this.id, required this.title});
  final String id;
  final String title;
}

class _ItemList extends FamilyScopedListController<_Item> {
  @override
  String get storageKey => 'test.items';

  @override
  String itemId(_Item item) => item.id;

  @override
  _Item decodeItem(Map<String, dynamic> json) => _Item(
        id: '${json['id']}',
        title: '${json['title']}',
      );

  @override
  Map<String, dynamic> encodeItem(_Item item) => {
        'id': item.id,
        'title': item.title,
      };
}
