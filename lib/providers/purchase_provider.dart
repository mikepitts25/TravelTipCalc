import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences_provider.dart';

class PurchaseState {
  final bool isAvailable;
  final bool isPurchasing;
  final String? error;

  const PurchaseState({
    this.isAvailable = false,
    this.isPurchasing = false,
    this.error,
  });

  PurchaseState copyWith({
    bool? isAvailable,
    bool? isPurchasing,
    String? error,
  }) {
    return PurchaseState(
      isAvailable: isAvailable ?? this.isAvailable,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      error: error,
    );
  }
}

/// Stubbed purchase notifier until in_app_purchase is configured.
/// To enable IAP:
/// 1. Uncomment in_app_purchase in pubspec.yaml
/// 2. Configure StoreKit in Xcode for iOS
/// 3. Restore the full implementation from git history
class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final Ref _ref;

  PurchaseNotifier(this._ref) : super(const PurchaseState());

  Future<void> buyPro() async {
    state = state.copyWith(
      error: 'In-app purchases are not yet configured.',
    );
  }

  Future<void> restorePurchases() async {
    // No-op until IAP is configured
  }
}

final purchaseProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(ref),
);
