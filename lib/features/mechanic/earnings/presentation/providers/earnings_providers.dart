import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../domain/models/earnings.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../../../dashboard/domain/models/service_request.dart';

/// Immutable UI state for the earnings screen.
class EarningsState {
  final EarningsPeriod period;
  final EarningsSummary? summary;
  final List<ServiceRequest> completedServices;
  final bool isLoading;
  final String? errorMessage;

  const EarningsState({
    this.period = EarningsPeriod.weekly,
    this.summary,
    this.completedServices = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  EarningsState copyWith({
    EarningsPeriod? period,
    EarningsSummary? summary,
    List<ServiceRequest>? completedServices,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EarningsState(
      period: period ?? this.period,
      summary: summary ?? this.summary,
      completedServices: completedServices ?? this.completedServices,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  double get totalEarnings => summary?.totalEarnings ?? 0;
  double get totalTips => summary?.totalTips ?? 0;
  int get totalServices => summary?.totalServices ?? 0;
  double get averageRating => summary?.averageRating ?? 0;
}

/// Owns the earnings screen's async data + selected period.
/// Repository and current user are injected via providers, so this is fully
/// testable with a fake repository (no Firebase needed).
final earningsControllerProvider =
    NotifierProvider<EarningsController, EarningsState>(EarningsController.new);

class EarningsController extends Notifier<EarningsState> {
  @override
  EarningsState build() => const EarningsState(isLoading: true);

  EarningsRepository get _repo => ref.read(earningsRepositoryProvider);
  String? get _mechanicId => ref.read(currentUserIdProvider);

  /// Loads the summary + completed services for the current period.
  Future<void> load() async {
    final id = _mechanicId;
    if (id == null || id.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final summary =
          await _repo.getEarningsSummary(mechanicId: id, period: state.period);
      final services = await _repo.getCompletedServices(
        mechanicId: id,
        period: state.period,
      );
      state = state.copyWith(
        summary: summary,
        completedServices: services,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Switches the active period and reloads.
  Future<void> selectPeriod(EarningsPeriod period) async {
    if (period == state.period) return;
    state = state.copyWith(period: period);
    await load();
  }

  /// Submits a withdrawal and refreshes. Returns true on success.
  Future<bool> submitWithdrawal({
    required double amount,
    required String paymentMethod,
    String? accountDetails,
  }) async {
    final id = _mechanicId;
    if (id == null || id.isEmpty) return false;
    try {
      await _repo.submitWithdrawalRequest(
        mechanicId: id,
        amount: amount,
        paymentMethod: paymentMethod,
        accountDetails: accountDetails,
      );
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}
