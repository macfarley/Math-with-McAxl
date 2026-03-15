/// Static currency exchange rates (USD base) with a reference date.
/// Users are shown the date so they know rates may be stale.
class CurrencyConverter {
  static const String rateDate = '2025-01-01';

  /// Exchange rates relative to USD (1 USD = X units of currency)
  static const Map<String, double> ratesFromUSD = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 149.50,
    'CAD': 1.36,
    'AUD': 1.53,
    'CHF': 0.89,
    'CNY': 7.24,
    'INR': 83.12,
    'MXN': 17.15,
    'BRL': 4.97,
    'KRW': 1325.0,
    'SEK': 10.42,
    'NOK': 10.56,
    'DKK': 6.89,
    'NZD': 1.63,
    'SGD': 1.34,
    'HKD': 7.82,
    'ZAR': 18.63,
    'RUB': 92.50,
  };

  /// Convert [amount] from [fromCurrency] to [toCurrency].
  static double convert(String fromCurrency, String toCurrency, double amount) {
    final from = ratesFromUSD[fromCurrency];
    final to = ratesFromUSD[toCurrency];
    if (from == null) throw ArgumentError('Unknown currency: $fromCurrency');
    if (to == null) throw ArgumentError('Unknown currency: $toCurrency');
    // Convert to USD first, then to target currency
    return amount / from * to;
  }

  static List<String> get currencies => ratesFromUSD.keys.toList();
}
