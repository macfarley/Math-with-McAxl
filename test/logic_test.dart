import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:math_with_mcaxl/logic/evaluator.dart';
import 'package:math_with_mcaxl/logic/graph_engine.dart';
import 'package:math_with_mcaxl/logic/converters/units.dart';
import 'package:math_with_mcaxl/logic/converters/currency.dart';
import 'package:math_with_mcaxl/logic/converters/calendar_math.dart';
import 'package:math_with_mcaxl/logic/converters/time_math.dart';
import 'package:math_with_mcaxl/logic/utility_math.dart';

void main() {
  // ── Evaluator ──────────────────────────────────────────────────────────────
  group('Evaluator', () {
    final e = Evaluator();

    test('basic arithmetic', () {
      expect(e.evaluate('2 + 3'), equals(5.0));
      expect(e.evaluate('10 - 4'), equals(6.0));
      expect(e.evaluate('3 * 4'), equals(12.0));
      expect(e.evaluate('15 / 3'), equals(5.0));
    });

    test('operator precedence', () {
      expect(e.evaluate('2 + 3 * 4'), equals(14.0));
      expect(e.evaluate('(2 + 3) * 4'), equals(20.0));
    });

    test('exponentiation', () {
      expect(e.evaluate('2^10'), equals(1024.0));
      expect(e.evaluate('4^0.5'), closeTo(2.0, 1e-9));
    });

    test('unary minus', () {
      expect(e.evaluate('-5'), equals(-5.0));
      expect(e.evaluate('3 + -2'), equals(1.0));
      expect(e.evaluate('-(3 + 2)'), equals(-5.0));
    });

    test('constants', () {
      expect(e.evaluate('pi'), closeTo(math.pi, 1e-9));
      expect(e.evaluate('e'), closeTo(math.e, 1e-9));
    });

    test('trig functions', () {
      expect(e.evaluate('sin(0)'), closeTo(0.0, 1e-9));
      expect(e.evaluate('cos(0)'), closeTo(1.0, 1e-9));
      expect(e.evaluate('sin(pi / 2)'), closeTo(1.0, 1e-9));
      expect(e.evaluate('tan(pi / 4)'), closeTo(1.0, 1e-9));
    });

    test('sqrt', () {
      expect(e.evaluate('sqrt(9)'), closeTo(3.0, 1e-9));
      expect(e.evaluate('sqrt(2)'), closeTo(math.sqrt2, 1e-9));
    });

    test('log functions', () {
      expect(e.evaluate('log(e)'), closeTo(1.0, 1e-9));
      expect(e.evaluate('log10(100)'), closeTo(2.0, 1e-9));
      expect(e.evaluate('log2(8)'), closeTo(3.0, 1e-9));
    });

    test('abs and rounding', () {
      expect(e.evaluate('abs(-7)'), closeTo(7.0, 1e-9));
      expect(e.evaluate('ceil(1.2)'), equals(2.0));
      expect(e.evaluate('floor(1.9)'), equals(1.0));
      expect(e.evaluate('round(1.5)'), equals(2.0));
    });

    test('complex expression', () {
      // Pythagorean: sqrt(3^2 + 4^2) = 5
      expect(e.evaluate('sqrt(3^2 + 4^2)'), closeTo(5.0, 1e-9));
    });

    test('division by zero throws', () {
      expect(() => e.evaluate('1 / 0'), throwsFormatException);
    });

    test('sqrt of negative throws', () {
      expect(() => e.evaluate('sqrt(-1)'), throwsFormatException);
    });

    test('unknown function throws', () {
      expect(() => e.evaluate('foo(1)'), throwsFormatException);
    });

    test('whitespace is ignored', () {
      expect(e.evaluate('  2  +  3  '), equals(5.0));
    });
  });

  // ── GraphEngine ────────────────────────────────────────────────────────────
  group('GraphEngine', () {
    final engine = GraphEngine();

    test('samples sin(x) correctly', () {
      final data = engine.sample('sin(x)', xMin: 0, xMax: 2 * math.pi, steps: 100);
      expect(data.points, isNotEmpty);
      // At x=0, sin(0)=0
      final first = data.points.first;
      expect(first.y, closeTo(0.0, 0.01));
    });

    test('returns finite range', () {
      final data = engine.sample('x^2', xMin: -5, xMax: 5, steps: 100);
      expect(data.yMin, greaterThanOrEqualTo(0));
      expect(data.yMax, closeTo(25.0, 0.1));
    });

    test('traceX finds closest point', () {
      final data = engine.sample('x', xMin: 0, xMax: 10, steps: 100);
      final pt = GraphEngine.traceX(data, 5.0);
      expect(pt, isNotNull);
      expect(pt!.x, closeTo(5.0, 0.2));
      expect(pt.y, closeTo(5.0, 0.2));
    });

    test('niceTicks returns ordered values', () {
      final ticks = GraphEngine.niceTicks(-10, 10);
      expect(ticks, isNotEmpty);
      for (int i = 1; i < ticks.length; i++) {
        expect(ticks[i], greaterThan(ticks[i - 1]));
      }
    });
  });

  // ── UnitConverter ──────────────────────────────────────────────────────────
  group('UnitConverter', () {
    test('length: meters to feet', () {
      final r = UnitConverter.convert(UnitCategory.length, 'Meter', 'Foot', 1.0);
      expect(r, closeTo(3.28084, 0.001));
    });

    test('length: km to miles', () {
      final r = UnitConverter.convert(UnitCategory.length, 'Kilometer', 'Mile', 1.0);
      expect(r, closeTo(0.621371, 0.001));
    });

    test('mass: kg to pounds', () {
      final r = UnitConverter.convert(UnitCategory.mass, 'Kilogram', 'Pound', 1.0);
      expect(r, closeTo(2.20462, 0.001));
    });

    test('temperature: C to F', () {
      final r = UnitConverter.convert(UnitCategory.temperature, 'Celsius', 'Fahrenheit', 0.0);
      expect(r, closeTo(32.0, 0.001));
    });

    test('temperature: C to K', () {
      final r = UnitConverter.convert(UnitCategory.temperature, 'Celsius', 'Kelvin', 0.0);
      expect(r, closeTo(273.15, 0.001));
    });

    test('temperature: F to C', () {
      final r = UnitConverter.convert(UnitCategory.temperature, 'Fahrenheit', 'Celsius', 212.0);
      expect(r, closeTo(100.0, 0.001));
    });

    test('volume: liters to gallons', () {
      final r = UnitConverter.convert(UnitCategory.volume, 'Liter', 'Gallon (US)', 3.785411784);
      expect(r, closeTo(1.0, 0.001));
    });

    test('speed: mph to m/s', () {
      final r = UnitConverter.convert(UnitCategory.speed, 'Mile/hour', 'Meter/second', 1.0);
      expect(r, closeTo(0.44704, 0.001));
    });

    test('energy: kcal to joules', () {
      final r = UnitConverter.convert(UnitCategory.energy, 'Kilocalorie', 'Joule', 1.0);
      expect(r, closeTo(4184.0, 1.0));
    });
  });

  // ── CurrencyConverter ──────────────────────────────────────────────────────
  group('CurrencyConverter', () {
    test('USD to USD is identity', () {
      expect(CurrencyConverter.convert('USD', 'USD', 100), closeTo(100.0, 0.001));
    });

    test('USD to EUR', () {
      final r = CurrencyConverter.convert('USD', 'EUR', 100);
      expect(r, closeTo(92.0, 0.1));
    });

    test('unknown currency throws', () {
      expect(() => CurrencyConverter.convert('XYZ', 'USD', 1), throwsArgumentError);
    });
  });

  // ── CalendarMath ───────────────────────────────────────────────────────────
  group('CalendarMath', () {
    test('daysBetween positive', () {
      final a = DateTime(2024, 1, 1);
      final b = DateTime(2024, 1, 11);
      expect(CalendarMath.daysBetween(a, b), equals(10));
    });

    test('daysBetween negative (a after b)', () {
      final a = DateTime(2024, 1, 11);
      final b = DateTime(2024, 1, 1);
      expect(CalendarMath.daysBetween(a, b), equals(-10));
    });

    test('addDays', () {
      final d = DateTime(2024, 1, 1);
      expect(CalendarMath.addDays(d, 5), equals(DateTime(2024, 1, 6)));
    });

    test('weekdayName', () {
      // 2024-01-01 is a Monday
      expect(CalendarMath.weekdayName(DateTime(2024, 1, 1)), equals('Monday'));
    });

    test('countWeekday', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);
      // There are 5 Mondays in Jan 2024
      expect(CalendarMath.countWeekday(start, end, 1), equals(5));
    });

    test('weeksBetween', () {
      final a = DateTime(2024, 1, 1);
      final b = DateTime(2024, 1, 22);
      expect(CalendarMath.weeksBetween(a, b), equals(3));
    });

    test('nextWeekday', () {
      // 2024-01-01 Monday; next Wednesday is 2024-01-03
      final d = DateTime(2024, 1, 1);
      final next = CalendarMath.nextWeekday(d, 3); // 3 = Wednesday
      expect(next, equals(DateTime(2024, 1, 3)));
    });
  });

  // ── TimeMath ───────────────────────────────────────────────────────────────
  group('TimeMath', () {
    test('addTimes', () {
      expect(TimeMath.addTimes('01:30', '02:45'), equals('04:15'));
    });

    test('addTimes crossing midnight', () {
      expect(TimeMath.addTimes('23:00', '01:30'), equals('24:30'));
    });

    test('minutesToHoursMinutes', () {
      expect(TimeMath.minutesToHoursMinutes(90), equals((1, 30)));
      expect(TimeMath.minutesToHoursMinutes(60), equals((1, 0)));
      expect(TimeMath.minutesToHoursMinutes(0), equals((0, 0)));
    });

    test('formatDuration', () {
      expect(TimeMath.formatDuration(const Duration(hours: 2, minutes: 30, seconds: 15)),
          equals('2h 30m 15s'));
      expect(TimeMath.formatDuration(const Duration(seconds: 45)), equals('45s'));
    });

    test('difference', () {
      final a = DateTime(2024, 1, 1, 10, 0);
      final b = DateTime(2024, 1, 1, 12, 30);
      final diff = TimeMath.difference(a, b);
      expect(diff.inMinutes, equals(150));
    });
  });

  // ── UtilityMath ────────────────────────────────────────────────────────────
  group('UtilityMath', () {
    test('tipAmount', () {
      expect(UtilityMath.tipAmount(100, 18), closeTo(18.0, 0.001));
    });

    test('totalWithTip', () {
      expect(UtilityMath.totalWithTip(50, 20), closeTo(60.0, 0.001));
    });

    test('splitBill', () {
      expect(UtilityMath.splitBill(100, 20, 4), closeTo(30.0, 0.001));
    });

    test('taxAmount', () {
      expect(UtilityMath.taxAmount(200, 8), closeTo(16.0, 0.001));
    });

    test('priceAfterTax', () {
      expect(UtilityMath.priceAfterTax(100, 10), closeTo(110.0, 0.001));
    });

    test('discountAmount', () {
      expect(UtilityMath.discountAmount(80, 25), closeTo(20.0, 0.001));
    });

    test('priceAfterDiscount', () {
      expect(UtilityMath.priceAfterDiscount(80, 25), closeTo(60.0, 0.001));
    });

    test('simpleInterest', () {
      expect(UtilityMath.simpleInterest(1000, 5, 3), closeTo(150.0, 0.001));
    });

    test('simpleInterestTotal', () {
      expect(UtilityMath.simpleInterestTotal(1000, 5, 3), closeTo(1150.0, 0.001));
    });

    test('percentChange increase', () {
      expect(UtilityMath.percentChange(80, 100), closeTo(25.0, 0.001));
    });

    test('percentChange decrease', () {
      expect(UtilityMath.percentChange(100, 75), closeTo(-25.0, 0.001));
    });

    test('percentOf', () {
      expect(UtilityMath.percentOf(25, 200), closeTo(12.5, 0.001));
    });

    test('splitBill with zero people throws', () {
      expect(() => UtilityMath.splitBill(100, 20, 0), throwsArgumentError);
    });
  });
}
