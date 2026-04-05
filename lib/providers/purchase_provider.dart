import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../config/constants.dart';
import 'preferences_provider.dart';

class PurchaseState {
  final bool isAvailable;
  final bool isPurchasing;
  final ProductDetails? proProduct;
  final String? error;

  const PurchaseState({
    this.isAvailable = false,
    this.isPurchasing = false,
    this.proProduct,
    this.error,
  });

  PurchaseState copyWith({
    bool? isAvailable,
    bool? isPurchasing,
    ProductDetails? proProduct,
    String? error,
  }) {
    return PurchaseState(
      isAvailable: isAvailable ?? this.isAvailable,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      proProduct: proProduct ?? this.proProduct,
      error: error,
    );
  }
}

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final Ref _ref;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  PurchaseNotifier(this._ref) : super(const PurchaseState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final iap = InAppPurchase.instance;
      final available = await iap.isAvailable();

      if (!available) {
        state = state.copyWith(isAvailable: false);
        return;
      }
    } catch (_) {
      state = state.copyWith(isAvailable: false);
      return;
    }

    state = state.copyWith(isAvailable: true);

    // Listen for purchase updates
    _subscription = iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {
        state = state.copyWith(error: 'Purchase error occurred');
      },
    );

    // Load product details
    final response = await iap.queryProductDetails({AppConstants.proProductId});
    if (response.productDetails.isNotEmpty) {
      state = state.copyWith(proProduct: response.productDetails.first);
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID == AppConstants.proProductId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          _ref.read(proStatusProvider.notifier).setPro(true);
          state = state.copyWith(isPurchasing: false);
        } else if (purchase.status == PurchaseStatus.error) {
          state = state.copyWith(
            isPurchasing: false,
            error: 'Purchase failed. Please try again.',
          );
        } else if (purchase.status == PurchaseStatus.pending) {
          state = state.copyWith(isPurchasing: true);
        }
      }

      if (purchase.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  Future<void> buyPro() async {
    final product = state.proProduct;
    if (product == null) {
      state = state.copyWith(error: 'Product not available');
      return;
    }

    state = state.copyWith(isPurchasing: true, error: null);

    final purchaseParam = PurchaseParam(productDetails: product);
    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final purchaseProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(ref),
);
