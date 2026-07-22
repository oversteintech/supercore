import 'package:after_core/after_core.dart';
import 'package:after_ecosystem/after_ecosystem.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AfterEcosystemFabric fabric;

  setUp(() {
    fabric = AfterEcosystemFabric.inMemory();
  });

  test('After ID signs in once for the ecosystem', () async {
    const user = AfterAuthUser(
      uid: 'u1',
      isAnonymous: false,
      email: 'member@afterartificial.com',
    );
    final session = await fabric.identity.signInWithAuthUser(user);
    expect(session.afterId.value, 'aid_u1');
    expect(await fabric.identity.currentSession(), session);
  });

  test('event bus publishes influence chain events', () async {
    final seen = <String>[];
    final sub = fabric.events.subscribe(typePrefix: 'garage').listen((e) {
      seen.add(e.type);
    });
    await fabric.events.emit(
      type: AfterEventTypes.garageMaintenanceCompleted,
      sourceProductId: 'super_garage',
      afterId: const AfterId('aid_1'),
      payload: {'vehicleId': 'v1', 'cost': 420},
    );
    await Future<void>.delayed(Duration.zero);
    expect(seen, [AfterEventTypes.garageMaintenanceCompleted]);
    await sub.cancel();
  });

  test('product APIs invoke via secure bridge; cross-line needs interop scope',
      () async {
    final auditLog = <Map<String, Object?>>[];
    fabric = AfterEcosystemFabric.inMemory(auditLog: auditLog);
    fabric.apis.register(
      AfterProductApi(
        productId: 'super_finance',
        displayName: 'SuperFinance',
        line: AfterEcosystemLine.consumer,
        endpoints: const [
          AfterProductEndpoint(
            name: 'recordExpense',
            description: 'Record an expense',
            requiredScopes: ['finance.write'],
          ),
        ],
        invoke: (call) async => {'ok': true, 'args': call.args},
      ),
    );
    fabric.apis.register(
      AfterProductApi(
        productId: 'super_hospital',
        displayName: 'SuperHospital',
        line: AfterEcosystemLine.enterprise,
        endpoints: const [
          AfterProductEndpoint(
            name: 'ping',
            description: 'Health',
          ),
        ],
        invoke: (call) async => 'pong',
      ),
    );

    final result = await fabric.invoke(
      callerLine: AfterEcosystemLine.consumer,
      call: const AfterProductApiCall(
        targetProductId: 'super_finance',
        endpoint: 'recordExpense',
        callerProductId: 'super_garage',
        afterId: AfterId('aid_1'),
        scopes: {'finance.write'},
        args: {'amount': 420},
      ),
    );
    expect(result, isA<Map<String, Object?>>());
    expect(auditLog, isNotEmpty);

    expect(
      () => fabric.invoke(
        callerLine: AfterEcosystemLine.enterprise,
        call: const AfterProductApiCall(
          targetProductId: 'super_finance',
          endpoint: 'recordExpense',
          callerProductId: 'super_hospital',
          afterId: AfterId('aid_1'),
          scopes: {'finance.write'},
        ),
      ),
      throwsA(isA<AfterInteropException>()),
    );

    final cross = await fabric.invoke(
      callerLine: AfterEcosystemLine.enterprise,
      call: const AfterProductApiCall(
        targetProductId: 'super_finance',
        endpoint: 'recordExpense',
        callerProductId: 'super_hospital',
        afterId: AfterId('aid_1'),
        scopes: {'finance.write', 'interop.cross_line'},
        args: {'amount': 10},
      ),
    );
    expect(cross, isA<Map<String, Object?>>());
  });

  test('merged calendar + federated search + AI context', () async {
    const aid = AfterId('aid_ctx');
    await fabric.calendar.upsert(
      AfterEcosystemCalendarEvent(
        id: 'c1',
        title: 'Brake service',
        start: DateTime.utc(2026, 7, 20, 9),
        end: DateTime.utc(2026, 7, 20, 10),
        sourceProductId: 'super_garage',
        afterId: aid,
      ),
    );
    await fabric.calendar.upsert(
      AfterEcosystemCalendarEvent(
        id: 'c2',
        title: 'Flight to IST',
        start: DateTime.utc(2026, 7, 22, 14),
        end: DateTime.utc(2026, 7, 22, 18),
        sourceProductId: 'super_travel',
        afterId: aid,
      ),
    );
    final merged = await fabric.calendar.listMerged(afterId: aid);
    expect(merged.map((e) => e.sourceProductId), [
      'super_garage',
      'super_travel',
    ]);

    await fabric.search.upsert(
      sourceProductId: 'super_garage',
      id: 'v1',
      title: 'Toyota Corolla',
      subtitle: 'Brake maintenance due',
    );
    await fabric.search.upsert(
      sourceProductId: 'super_finance',
      id: 'e1',
      title: 'Brake repair expense',
    );
    final hits = await fabric.search.search('brake');
    expect(hits, isNotEmpty);
    expect(
      hits.map((h) => h.sourceProductId).toSet(),
      contains('super_garage'),
    );

    await fabric.events.emit(
      type: AfterEventTypes.garageMaintenanceCompleted,
      sourceProductId: 'super_garage',
      afterId: aid,
    );
    await fabric.notifications.post(
      AfterEcosystemNotification(
        id: 'n1',
        title: 'Service done',
        body: 'Invoice ready',
        sourceProductId: 'super_garage',
        createdAt: DateTime.utc(2026, 7, 19),
        afterId: aid,
      ),
    );
    await fabric.plus.upsert(
      const AfterPlusSubscription(
        afterId: aid,
        plan: AfterUserPlan.superPlan,
        active: true,
        features: {AfterPlanFeature.aiUnlimited, AfterPlanFeature.familyShare},
      ),
    );

    final ctx = await fabric.aiContextBuilder.build(
      afterId: aid,
      activeProductId: 'super_garage',
      moduleHints: {
        'super_garage': '2 vehicles',
        'super_finance': 'budget healthy',
      },
    );
    expect(ctx.toPromptBlock(), contains('After ecosystem context'));
    expect(ctx.toPromptBlock(), contains('super_garage'));
    expect(ctx.upcomingCalendar, hasLength(2));
    expect(ctx.openNotifications, hasLength(1));

    final block = ctx.toContextBlock();
    expect(block.text, contains('afterId: aid_ctx'));
    expect(block.metadata['afterId'], 'aid_ctx');
    expect(block.metadata['activeProductId'], 'super_garage');

    await fabric.events.emit(
      type: AfterEventTypes.financeExpenseRecorded,
      sourceProductId: 'super_finance',
      afterId: aid,
    );
    final page = fabric.events.historyPage(const PageQuery(limit: 1));
    expect(page.items, hasLength(1));
    expect(page.hasMore, isTrue);
    expect(page.nextCursor, isNotNull);
  });

  test('documents + family + wallet shared across modules', () async {
    const aid = AfterId('aid_share');
    await fabric.documents.upsert(
      const AfterEcosystemDocument(
        id: 'd1',
        title: 'Insurance PDF',
        sourceProductId: 'super_garage',
        afterId: aid,
        sharedWithFamily: true,
      ),
    );
    expect(await fabric.documents.listFor(aid), hasLength(1));

    await fabric.family.upsert(
      const AfterFamilySpace(
        id: 'fam1',
        name: 'Uzundal Home',
        members: [
          AfterFamilyMember(afterId: aid, displayName: 'Ayhan', role: 'owner'),
        ],
      ),
    );
    expect((await fabric.family.spaceFor(aid))?.name, 'Uzundal Home');

    await fabric.wallet.record(
      AfterWalletLedgerEntry(
        id: 'w1',
        afterId: aid,
        amount: -420,
        currency: 'TRY',
        label: 'Brake service',
        at: DateTime.utc(2026, 7, 19),
        sourceProductId: 'super_garage',
      ),
    );
    expect(await fabric.wallet.history(aid), hasLength(1));
  });
}
