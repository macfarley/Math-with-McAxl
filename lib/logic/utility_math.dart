import 'dart:math' as math;

/// Utility math calculations for everyday use.
class UtilityMath {
  // ── Tips ─────────────────────────────────────────────────────────────────

  /// Calculate tip amount.
  static double tipAmount(double bill, double tipPercent) => bill * tipPercent / 100;

  /// Calculate total including tip.
  static double totalWithTip(double bill, double tipPercent) => bill + tipAmount(bill, tipPercent);

  /// Split bill (with tip) among [people].
  static double splitBill(double bill, double tipPercent, int people) {
    if (people <= 0) throw ArgumentError('people must be > 0');
    return totalWithTip(bill, tipPercent) / people;
  }

  // ── Tax ──────────────────────────────────────────────────────────────────

  /// Calculate tax amount.
  static double taxAmount(double price, double taxPercent) => price * taxPercent / 100;

  /// Price after tax.
  static double priceAfterTax(double price, double taxPercent) => price + taxAmount(price, taxPercent);

  // ── Discounts ────────────────────────────────────────────────────────────

  /// Discount amount.
  static double discountAmount(double price, double discountPercent) => price * discountPercent / 100;

  /// Price after discount.
  static double priceAfterDiscount(double price, double discountPercent) =>
      price - discountAmount(price, discountPercent);

  // ── Interest ─────────────────────────────────────────────────────────────

  /// Simple interest: I = P × r × t
  static double simpleInterest(double principal, double ratePercent, double timeYears) =>
      principal * ratePercent / 100 * timeYears;

  /// Total amount after simple interest.
  static double simpleInterestTotal(double principal, double ratePercent, double timeYears) =>
      principal + simpleInterest(principal, ratePercent, timeYears);

  /// Compound interest total: A = P(1 + r/n)^(nt)
  static double compoundInterestTotal(
    double principal,
    double ratePercent,
    double timeYears, {
    int compoundsPerYear = 1,
  }) {
    final r = ratePercent / 100;
    final n = compoundsPerYear.toDouble();
    return principal * math.pow(1 + r / n, n * timeYears).toDouble();
  }

  // ── Percent change ───────────────────────────────────────────────────────

  /// Percent change from [oldValue] to [newValue].
  static double percentChange(double oldValue, double newValue) {
    if (oldValue == 0) throw ArgumentError('oldValue cannot be zero');
    return (newValue - oldValue) / oldValue * 100;
  }

  /// Percent of [part] in [whole].
  static double percentOf(double part, double whole) {
    if (whole == 0) throw ArgumentError('whole cannot be zero');
    return part / whole * 100;
  }
}
