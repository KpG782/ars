import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arsapplication/core/providers/core_providers.dart';
import 'package:arsapplication/features/mechanic/earnings/domain/models/earnings.dart';
import 'package:arsapplication/features/mechanic/earnings/domain/repositories/earnings_repository.dart';
import 'package:arsapplication/features/mechanic/earnings/presentation/providers/earnings_providers.dart';
import 'package:arsapplication/features/mechanic/dashboard/domain/models/service_request.dart';

/// In-memory fake so the controller can be tested without Firebase.
class FakeEarningsRepository implements EarningsRepository {
  FakeEarningsRepository(this.summaryByPeriod);

  final Map<EarningsPeriod, EarningsSummary> summaryByPeriod;
  EarningsPeriod? lastSummaryPeriod;
  final List<Map<String, Object?>> submittedWithdrawals = [];
  Object? throwOnSummary;

  @override
  Future<EarningsSummary> getEarningsSummary({
    required String mechanicId,
    required EarningsPeriod period,
  }) async {
    if (throwOnSummary != null) throw throwOnSummary!;
    lastSummaryPeriod = period;
    return summaryByPeriod[period]!;
  }

  @override
  Future<List<ServiceRequest>> getCompletedServices({
    required String mechanicId,
    required EarningsPeriod period,
  }) async => const [];

  @override
  Future<WithdrawalRequest> submitWithdrawalRequest({
    required String mechanicId,
    required double amount,
    required String paymentMethod,
    String? accountDetails,
  }) async {
    submittedWithdrawals
        .add({'mechanicId': mechanicId, 'amount': amount, 'method': paymentMethod});
    return WithdrawalRequest(
      id: 'w1',
      mechanicId: mechanicId,
      amount: amount,
      paymentMethod: paymentMethod,
      requestDate: DateTime(2026),
      status: WithdrawalStatus.pending,
    );
  }

  @override
  Future<List<WithdrawalRequest>> getWithdrawalHistory({
    required String mechanicId,
    int limit = 20,
  }) async => const [];

  @override
  Future<List<WithdrawalRequest>> getPendingWithdrawals(String mechanicId) async =>
      const [];

  @override
  Future<void> cancelWithdrawal(String withdrawalId) async {}
}

EarningsSummary _summary(double total) => EarningsSummary(
  totalEarnings: total,
  totalTips: 0,
  totalServices: 1,
  averageRating: 5,
  platformFees: 0,
  netEarnings: total,
  periodStart: DateTime(2026),
  periodEnd: DateTime(2026, 2),
);

void main() {
  late FakeEarningsRepository repo;

  ProviderContainer makeContainer({String? uid = 'mech-1'}) {
    final container = ProviderContainer(
      overrides: [
        earningsRepositoryProvider.overrideWithValue(repo),
        currentUserIdProvider.overrideWithValue(uid),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    repo = FakeEarningsRepository({
      EarningsPeriod.weekly: _summary(500),
      EarningsPeriod.monthly: _summary(2000),
    });
  });

  test('load populates the summary for the current mechanic', () async {
    final container = makeContainer();

    await container.read(earningsControllerProvider.notifier).load();

    final state = container.read(earningsControllerProvider);
    expect(state.totalEarnings, 500);
    expect(state.isLoading, false);
    expect(state.errorMessage, isNull);
  });

  test('load with no authenticated user skips the repository', () async {
    final container = makeContainer(uid: null);

    await container.read(earningsControllerProvider.notifier).load();

    final state = container.read(earningsControllerProvider);
    expect(state.summary, isNull);
    expect(state.isLoading, false);
    expect(repo.lastSummaryPeriod, isNull);
  });

  test('selectPeriod switches the period and reloads with it', () async {
    final container = makeContainer();

    await container
        .read(earningsControllerProvider.notifier)
        .selectPeriod(EarningsPeriod.monthly);

    final state = container.read(earningsControllerProvider);
    expect(state.period, EarningsPeriod.monthly);
    expect(state.totalEarnings, 2000);
    expect(repo.lastSummaryPeriod, EarningsPeriod.monthly);
  });

  test('submitWithdrawal forwards to the repository and reports success', () async {
    final container = makeContainer();

    final ok = await container
        .read(earningsControllerProvider.notifier)
        .submitWithdrawal(amount: 300, paymentMethod: 'gcash');

    expect(ok, true);
    expect(repo.submittedWithdrawals.single['amount'], 300);
    expect(repo.submittedWithdrawals.single['method'], 'gcash');
  });

  test('load surfaces repository errors as errorMessage', () async {
    repo.throwOnSummary =
        EarningsException('boom', EarningsErrorCode.networkError);
    final container = makeContainer();

    await container.read(earningsControllerProvider.notifier).load();

    final state = container.read(earningsControllerProvider);
    expect(state.isLoading, false);
    expect(state.errorMessage, contains('boom'));
  });
}
