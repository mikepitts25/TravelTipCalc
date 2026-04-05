import 'package:in_app_purchase/in_app_purchase.dart';

import '../config/constants.dart';

/// Thin wrapper around InAppPurchase for testability.
class PurchaseService {
  final InAppPurchase _iap;

  PurchaseService({InAppPurchase? iap})
      : _iap = iap ?? InAppPurchase.instance;

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<ProductDetails?> getProProduct() async {
    final response = await _iap.queryProductDetails(
      {AppConstants.proProductId},
    );
    if (response.productDetails.isEmpty) return null;
    return response.productDetails.first;
  }

  Future<bool> buyPro(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;
}
