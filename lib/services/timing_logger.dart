// lib/services/timing_logger.dart
//
// Utility per raccogliere e loggare timing precisi delle operazioni crittografiche.
// Produce output formattato per estrazione CSV e boxplot.
//
// Output nei log Flutter (debugPrint / print):
//   TIMING_CRYPTO|<operazione>|<size_label>|<time_ms>
//
// Per estrarre i dati dal log del dispositivo:
//   flutter logs | grep "TIMING_CRYPTO" > crypto_timings.txt

class TimingLogger {
  // Accumulatore in memoria per la sessione corrente
  static final List<_TimingEntry> _entries = [];

  // Esegue [fn] per [iterations] volte (con 2 warm-up) e logga ogni misurazione.
  static Future<List<double>> benchmark(
    String operation,
    String sizeLabel,
    Future<void> Function() fn, {
    int iterations = 20,
  }) async {
    final times = <double>[];

    // warm-up: 2 iterazioni non conteggiate
    for (int i = 0; i < 2; i++) {
      await fn();
    }

    for (int i = 0; i < iterations; i++) {
      final t0 = DateTime.now().microsecondsSinceEpoch;
      await fn();
      final t1 = DateTime.now().microsecondsSinceEpoch;
      final ms = (t1 - t0) / 1000.0; // microsecondi → millisecondi
      times.add(ms);
      _log(operation, sizeLabel, ms);
    }

    _printSummary(operation, sizeLabel, times);
    return times;
  }

  // Versione sincrona per operazioni non-async (es. hashing)
  static List<double> benchmarkSync(
    String operation,
    String sizeLabel,
    void Function() fn, {
    int iterations = 20,
  }) {
    final times = <double>[];

    // warm-up
    for (int i = 0; i < 2; i++) {
      fn();
    }

    for (int i = 0; i < iterations; i++) {
      final t0 = DateTime.now().microsecondsSinceEpoch;
      fn();
      final t1 = DateTime.now().microsecondsSinceEpoch;
      final ms = (t1 - t0) / 1000.0;
      times.add(ms);
      _log(operation, sizeLabel, ms);
    }

    _printSummary(operation, sizeLabel, times);
    return times;
  }

  static void _log(String operation, String sizeLabel, double ms) {
    // Formato riconoscibile per grep/filtro
    // ignore: avoid_print
    print('TIMING_CRYPTO|$operation|$sizeLabel|${ms.toStringAsFixed(4)}');
    _entries.add(_TimingEntry(
      operation: operation,
      sizeLabel: sizeLabel,
      timeMs: ms,
    ));
  }

  static void _printSummary(
      String operation, String sizeLabel, List<double> times) {
    if (times.isEmpty) return;
    final sorted = List<double>.from(times)..sort();
    final mean = times.reduce((a, b) => a + b) / times.length;
    final variance =
        times.map((t) => (t - mean) * (t - mean)).reduce((a, b) => a + b) /
            times.length;
    final std = _sqrt(variance);
    final p50 = sorted[times.length ~/ 2];
    final p95 = sorted[(times.length * 0.95).floor().clamp(0, times.length - 1)];

    // ignore: avoid_print
    print(
      'TIMING_SUMMARY|$operation|$sizeLabel'
      '|n=${times.length}'
      '|mean=${mean.toStringAsFixed(3)}ms'
      '|std=${std.toStringAsFixed(3)}ms'
      '|min=${sorted.first.toStringAsFixed(3)}ms'
      '|p50=${p50.toStringAsFixed(3)}ms'
      '|p95=${p95.toStringAsFixed(3)}ms'
      '|max=${sorted.last.toStringAsFixed(3)}ms',
    );
  }

  // CSV di tutti i timing raccolti (header: operation,input_size,time_ms)
  static String toCsv() {
    final buf = StringBuffer();
    buf.writeln('operation,input_size,time_ms');
    for (final e in _entries) {
      buf.writeln('${e.operation},${e.sizeLabel},${e.timeMs.toStringAsFixed(4)}');
    }
    return buf.toString();
  }

  static void printCsv() {
    // ignore: avoid_print
    print('TIMING_CSV_START');
    // ignore: avoid_print
    print(toCsv());
    // ignore: avoid_print
    print('TIMING_CSV_END');
  }

  static void clear() => _entries.clear();

  static List<_TimingEntry> get entries => List.unmodifiable(_entries);

  // sqrt integer Newton (evita import dart:math in contesti restrittivi)
  static double _sqrt(double x) {
    if (x <= 0) return 0;
    double z = x / 2;
    for (int i = 0; i < 50; i++) {
      z = (z + x / z) / 2;
    }
    return z;
  }
}

class _TimingEntry {
  final String operation;
  final String sizeLabel;
  final double timeMs;

  const _TimingEntry({
    required this.operation,
    required this.sizeLabel,
    required this.timeMs,
  });
}
