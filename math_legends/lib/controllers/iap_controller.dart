import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:math_legends/controllers/pet_controller.dart';
import 'package:math_legends/services/sound_service.dart';

class IapController extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Observable list of products fetched from Play Store
  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxBool isAvailable = false.obs;

  // IMPORTANT: These IDs MUST perfectly match the Product IDs you create in your Google Play Console!
  final Set<String> _kIds = {
    'coin_pack_10',
    'coin_pack_25',
    'coin_pack_100',
    'coin_pack_250'
  };

  @override
  void onInit() {
    super.onInit();
    _initializeIAP();
  }

  void _initializeIAP() async {
    isAvailable.value = await _iap.isAvailable();
    if (isAvailable.value) {
      // 1. Fetch available products from the store
      final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
      
      // Sort them by price so they appear in order
      var fetchedProducts = response.productDetails;
      fetchedProducts.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      products.assignAll(fetchedProducts);

      // 2. Listen to the purchase stream (Transaction updates)
      _subscription = _iap.purchaseStream.listen(
        (purchaseDetailsList) => _listenToPurchaseUpdated(purchaseDetailsList),
        onDone: () => _subscription.cancel(),
        onError: (error) {
          Get.snackbar('Connection Error', 'Could not connect to the store.');
        },
      );
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  /// Triggers the Play Store bottom sheet to buy the product
  void buyCoins(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    // Auto-consume is required for coins so the user can buy them again later
    _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
  }

  /// Handles the transaction callbacks from Google Play
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        // You could show a loading overlay here if you wanted
      } else {
        if (purchase.status == PurchaseStatus.error) {
          // TRANSACTION FAILED OR CANCELLED
          SoundService.playSfx('sounds/error_sound.mp3');
          Get.snackbar(
            'Transaction Failed',
            purchase.error?.message ?? 'The purchase was cancelled or failed.',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        } else if (purchase.status == PurchaseStatus.purchased ||
                   purchase.status == PurchaseStatus.restored) {
          // TRANSACTION SUCCESSFUL
          _deliverCoins(purchase.productID);
        }

        // Must tell the store the purchase is complete, otherwise it will refund the user
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    }
  }

  /// Adds coins to the database ONLY if the transaction was successful
  Future<void> _deliverCoins(String productId) async {
    final petCtrl = Get.find<PetController>();
    final user = petCtrl.user.value!;
    int coinsToAdd = 0;

    switch (productId) {
      case 'coin_pack_10': coinsToAdd = 10; break;
      case 'coin_pack_25': coinsToAdd = 25; break;
      case 'coin_pack_100': coinsToAdd = 100; break;
      case 'coin_pack_250': coinsToAdd = 250; break;
    }

    if (coinsToAdd > 0) {
      user.coins = user.coins! + coinsToAdd;
      await petCtrl.firestore.updateUser(user);
      petCtrl.user.refresh();

      SoundService.playSfx('sounds/purchase.mp3');
      Get.snackbar(
        'Payment Successful!',
        'You bought $coinsToAdd coins. Thank you!',
        backgroundColor: Colors.greenAccent,
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}