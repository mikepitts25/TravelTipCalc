/// Thin wrapper around InAppPurchase for testability.
/// Currently stubbed - re-enable once in_app_purchase is added back to pubspec.yaml.
class PurchaseService {
  Future<bool> isAvailable() async => false;

  Future<void> restorePurchases() async {
    // No-op
  }
}
