import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AfterEntitlementEngine', () {
    test('picks highest active tier', () {
      final plan = AfterEntitlementEngine.effectivePlan(
        stored: AfterUserPlan.free,
        remotePlan: AfterUserPlan.premium,
        remoteActive: true,
        trialPlan: AfterUserPlan.superPlan,
      );
      expect(plan, AfterUserPlan.superPlan);
    });

    test('ignores inactive remote', () {
      final plan = AfterEntitlementEngine.effectivePlan(
        stored: AfterUserPlan.premium,
        remotePlan: AfterUserPlan.business,
        remoteActive: false,
      );
      expect(plan, AfterUserPlan.premium);
    });

    test('product key mapping', () {
      expect(AfterEntitlementEngine.planForProductKey('super'), AfterUserPlan.superPlan);
      expect(AfterEntitlementEngine.productKeyForPlan(AfterUserPlan.premium), 'premium');
    });
  });

  group('AfterDefaultPlanMatrix', () {
    test('super plan includes aiUnlimited', () {
      expect(
        AfterDefaultPlanMatrix.hasFeature(
          AfterUserPlan.superPlan,
          AfterPlanFeature.aiUnlimited,
        ),
        isTrue,
      );
    });

    test('free plan does not include adFree', () {
      expect(
        AfterDefaultPlanMatrix.hasFeature(
          AfterUserPlan.free,
          AfterPlanFeature.adFree,
        ),
        isFalse,
      );
    });
  });

  group('AfterUtils', () {
    test('email validation', () {
      expect(AfterUtils.isValidEmail('a@b.co'), isTrue);
      expect(AfterUtils.isValidEmail('bad'), isFalse);
      expect(AfterUtils.nullIfBlank('  '), isNull);
    });

    test('scrub extras removes secrets', () {
      final scrubbed = AfterUtils.scrubExtras({
        'feature': 'ai',
        'token': 'secret',
        'apiKey': 'x',
      });
      expect(scrubbed.containsKey('feature'), isTrue);
      expect(scrubbed.containsKey('token'), isFalse);
      expect(scrubbed.containsKey('apiKey'), isFalse);
    });
  });

  group('AfterResult', () {
    test('fold success/failure', () {
      const ok = AfterSuccess<int>(2);
      const fail = AfterFailure<int>('x');
      expect(ok.fold(onSuccess: (v) => v * 2, onFailure: (e, st) => -1), 4);
      expect(fail.fold(onSuccess: (v) => v, onFailure: (e, st) => -1), -1);
    });
  });

  group('AfterAiProviderKind', () {
    test('defaults', () {
      expect(AfterAiProviderKind.openai.protocol, AfterAiProtocol.openAiCompatible);
      expect(AfterAiProviderKind.claude.protocol, AfterAiProtocol.anthropic);
      expect(AfterAiProviderKind.openai.defaultBaseUrl, contains('openai'));
    });
  });

  group('SimpleAfterAiOrchestrator', () {
    test('local fallback without client', () async {
      final orch = SimpleAfterAiOrchestrator(
        client: null,
        localFallback: (m) => 'local:$m',
      );
      final result = await orch.handle(userMessage: 'hi');
      expect(result.text, 'local:hi');
    });
  });
}
