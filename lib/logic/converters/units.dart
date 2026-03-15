/// Hardcoded unit conversion factors.
/// All conversions go through a canonical SI base unit.
/// Factor = "how many SI units is 1 of this unit?"

enum UnitCategory { length, mass, volume, temperature, speed, pressure, energy }

class UnitDef {
  final String name;
  final String symbol;
  // For linear units: value in SI base unit
  final double factor;
  // For temperature, use special-case logic
  final bool isTemperature;

  const UnitDef(this.name, this.symbol, this.factor, {this.isTemperature = false});
}

class UnitConverter {
  static const Map<UnitCategory, List<UnitDef>> units = {
    UnitCategory.length: [
      UnitDef('Meter', 'm', 1.0),
      UnitDef('Kilometer', 'km', 1000.0),
      UnitDef('Centimeter', 'cm', 0.01),
      UnitDef('Millimeter', 'mm', 0.001),
      UnitDef('Inch', 'in', 0.0254),
      UnitDef('Foot', 'ft', 0.3048),
      UnitDef('Yard', 'yd', 0.9144),
      UnitDef('Mile', 'mi', 1609.344),
      UnitDef('Nautical Mile', 'nmi', 1852.0),
      UnitDef('Light Year', 'ly', 9.461e15),
    ],
    UnitCategory.mass: [
      UnitDef('Kilogram', 'kg', 1.0),
      UnitDef('Gram', 'g', 0.001),
      UnitDef('Milligram', 'mg', 1e-6),
      UnitDef('Metric Ton', 't', 1000.0),
      UnitDef('Pound', 'lb', 0.45359237),
      UnitDef('Ounce', 'oz', 0.028349523125),
      UnitDef('Stone', 'st', 6.35029318),
      UnitDef('Short Ton', 'ton', 907.18474),
    ],
    UnitCategory.volume: [
      UnitDef('Liter', 'L', 1.0),
      UnitDef('Milliliter', 'mL', 0.001),
      UnitDef('Cubic Meter', 'm³', 1000.0),
      UnitDef('Cubic Centimeter', 'cm³', 0.001),
      UnitDef('Gallon (US)', 'gal', 3.785411784),
      UnitDef('Quart (US)', 'qt', 0.946352946),
      UnitDef('Pint (US)', 'pt', 0.473176473),
      UnitDef('Cup (US)', 'cup', 0.2365882365),
      UnitDef('Fluid Ounce (US)', 'fl oz', 0.0295735296),
      UnitDef('Tablespoon', 'tbsp', 0.01478676478),
      UnitDef('Teaspoon', 'tsp', 0.00492892159),
    ],
    UnitCategory.temperature: [
      UnitDef('Celsius', '°C', 0, isTemperature: true),
      UnitDef('Fahrenheit', '°F', 0, isTemperature: true),
      UnitDef('Kelvin', 'K', 0, isTemperature: true),
    ],
    UnitCategory.speed: [
      UnitDef('Meter/second', 'm/s', 1.0),
      UnitDef('Kilometer/hour', 'km/h', 1.0 / 3.6),
      UnitDef('Mile/hour', 'mph', 0.44704),
      UnitDef('Knot', 'kn', 0.514444),
      UnitDef('Foot/second', 'ft/s', 0.3048),
    ],
    UnitCategory.pressure: [
      UnitDef('Pascal', 'Pa', 1.0),
      UnitDef('Kilopascal', 'kPa', 1000.0),
      UnitDef('Megapascal', 'MPa', 1e6),
      UnitDef('Bar', 'bar', 1e5),
      UnitDef('Atmosphere', 'atm', 101325.0),
      UnitDef('PSI', 'psi', 6894.757),
      UnitDef('mmHg / Torr', 'mmHg', 133.322),
    ],
    UnitCategory.energy: [
      UnitDef('Joule', 'J', 1.0),
      UnitDef('Kilojoule', 'kJ', 1000.0),
      UnitDef('Calorie', 'cal', 4.184),
      UnitDef('Kilocalorie', 'kcal', 4184.0),
      UnitDef('Watt-hour', 'Wh', 3600.0),
      UnitDef('Kilowatt-hour', 'kWh', 3.6e6),
      UnitDef('BTU', 'BTU', 1055.06),
      UnitDef('Electron Volt', 'eV', 1.60218e-19),
      UnitDef('Foot-pound', 'ft·lbf', 1.35582),
    ],
  };

  /// Convert [value] from [from] to [to] within [category].
  static double convert(UnitCategory category, String from, String to, double value) {
    if (category == UnitCategory.temperature) {
      return _convertTemperature(from, to, value);
    }
    final list = units[category]!;
    final fromDef = list.firstWhere((u) => u.name == from || u.symbol == from);
    final toDef = list.firstWhere((u) => u.name == to || u.symbol == to);
    return value * fromDef.factor / toDef.factor;
  }

  static double _convertTemperature(String from, String to, double value) {
    // Convert to Celsius first
    double celsius;
    switch (from) {
      case 'Celsius':
      case '°C':
        celsius = value;
        break;
      case 'Fahrenheit':
      case '°F':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
      case 'K':
        celsius = value - 273.15;
        break;
      default:
        throw ArgumentError('Unknown temperature unit: $from');
    }
    // Convert from Celsius to target
    switch (to) {
      case 'Celsius':
      case '°C':
        return celsius;
      case 'Fahrenheit':
      case '°F':
        return celsius * 9 / 5 + 32;
      case 'Kelvin':
      case 'K':
        return celsius + 273.15;
      default:
        throw ArgumentError('Unknown temperature unit: $to');
    }
  }
}
