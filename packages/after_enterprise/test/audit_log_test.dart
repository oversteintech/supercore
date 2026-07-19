import 'package:after_enterprise/after_enterprise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('append + query filters by tenant and actor', () async {
    final repo = InMemoryAuditLogRepository();
    await repo.append(
      organizationId: 'org1',
      actorId: 'u1',
      action: 'patient.admit',
      subject: 'patient_1',
    );
    await repo.append(
      organizationId: 'org1',
      actorId: 'u2',
      action: 'patient.discharge',
      subject: 'patient_1',
    );
    await repo.append(
      organizationId: 'org2',
      actorId: 'u1',
      action: 'patient.admit',
      subject: 'patient_9',
    );

    final org1 = await repo.query(organizationId: 'org1');
    expect(org1, hasLength(2));

    final byU1 = await repo.query(actorId: 'u1');
    expect(byU1, hasLength(2));

    final admits = await repo.query(action: 'patient.admit');
    expect(admits, hasLength(2));
  });
}
