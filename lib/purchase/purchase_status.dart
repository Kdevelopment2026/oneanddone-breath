import 'package:flutter/foundation.dart';

/// The single gate for the app's one and only purchase. There is no
/// per-feature gating anywhere else in the app — either the whole thing is
/// unlocked, or it isn't (see CLAUDE.md, golden rule 1: this app either
/// takes one payment or none, never a subscription).
///
/// v1 ships with this hard-coded unlocked so the whole app is usable and
/// testable before the real one-time purchase is wired up. Wiring it up
/// means adding the `in_app_purchase` package and replacing [isUnlocked]
/// with a real StoreKit/Play Billing entitlement check — do not add that
/// package until that decision is made (see CLAUDE.md, golden rule 8).
class PurchaseStatus extends ChangeNotifier {
  PurchaseStatus._();
  static final PurchaseStatus shared = PurchaseStatus._();

  bool _isUnlocked = true;
  bool get isUnlocked => _isUnlocked;
}
