# Math with McAxl

**TI-8x Killer Lite** — A tiny, offline-first, dignity-first tool for math, time, and life management.

Built with Flutter & Dart. No accounts. No cloud. No tracking.

---

## Features (v1 MVP)

### 🧮 Calculator
- Algebra 2-capable expression evaluator (custom recursive-descent parser)
- Supports: `+`, `-`, `*`, `/`, `^`, `%`, parentheses, unary minus
- Functions: `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `sqrt`, `abs`, `log`/`ln`, `log2`, `log10`, `exp`, `ceil`, `floor`, `round`
- Constants: `pi`, `e`
- Live evaluation as you type

### 📈 Graphing
- Plot any single-variable function of `x`
- Pinch-zoom and pan
- Tap-to-trace with coordinate display
- Auto-scaling axes with grid lines and tick labels

### 🔄 Unit Converter
- **Length** · **Mass** · **Volume** · **Temperature** · **Speed** · **Pressure** · **Energy**
- Metric ↔ Imperial, instant O(1) conversion
- **Currency** conversion (static rates, clearly date-stamped)

### 🛠️ Utility Tools
- **Tip / Tax / Discount** calculator with bill splitting
- **Percent change** calculator
- **Simple interest** calculator
- **Calendar math**: days between, add/subtract days, weekday finder, count weekdays, weeks between
- **Time math**: add times (HH:MM), minutes → hours & minutes, duration formatting

---

## Architecture

```
lib/
  main.dart                    # App entry point + nav shell
  screens/
    calculator_screen.dart     # Calculator UI + state
    graph_screen.dart          # Graphing UI + pan/zoom/trace
    converter_screen.dart      # Unit & currency converter UI
    utility_panel.dart         # Tip, interest, calendar, time tools
  widgets/
    keypad.dart                # Calculator keypad buttons
    display.dart               # Expression + result display
    graph_canvas.dart          # CustomPainter graph renderer
  logic/
    evaluator.dart             # Custom recursive-descent expression parser
    graph_engine.dart          # Function sampler + coordinate mapper
    utility_math.dart          # Tip, tax, discount, interest helpers
    converters/
      units.dart               # Hardcoded unit conversion factors
      currency.dart            # Static currency exchange rates
      time_math.dart           # Time arithmetic helpers
      calendar_math.dart       # Calendar/date helpers
test/
  logic_test.dart              # Unit tests for all logic modules
```

## State Management

- `StatelessWidget` for most UI components
- `StatefulWidget` + `setState()` only — no Provider/Bloc/Riverpod in v1

---

## Performance Targets

| Metric | Target |
|--------|--------|
| Cold start | < 500ms |
| Expression evaluation | < 50ms |
| Graph render | < 100ms |
| Memory footprint | < 10MB |
| APK size | < 20MB |

---

## Getting Started

```bash
flutter pub get
flutter run
```

Run tests:

```bash
flutter test
```

---

## Philosophy

- **Offline-first**: No accounts, no cloud, no tracking
- **Instant-load**: Opens in under 0.5 seconds
- **Tiny footprint**: Minimal dependencies, small APK
- **Dignity-first**: No shame, no gamification, no manipulation
- **Tool, not platform**: Simple, predictable, reliable

> *"TI-8x Killer Lite is the first brick of the Temple: a universal, offline, dignity-first tool that helps people understand math, time, and themselves."*
