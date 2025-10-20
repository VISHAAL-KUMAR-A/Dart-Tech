import 'dart:collection';
import 'dart:io';
import 'package:shelf/shelf.dart';

class _Bucket {
  int remaining;
  DateTime windowStart;
  _Bucket(this.remaining, this.windowStart);
}

final _buckets = HashMap<String, _Bucket>();

Middleware rateLimitMiddleware() {
  final max = int.tryParse(Platform.environment['RATE_LIMIT_MAX'] ?? '60') ?? 60;
  final windowSec = int.tryParse(Platform.environment['RATE_LIMIT_WINDOW_SEC'] ?? '60') ?? 60;

  return (Handler inner) {
    return (Request req) async {
      if (req.url.path == 'health') return inner(req);

      final key = (req.context['apiKey'] as String?) ?? 'anonymous';
      final now = DateTime.now();
      final bucket = _buckets.putIfAbsent(key, () => _Bucket(max, now));

      // reset window if needed
      if (now.difference(bucket.windowStart).inSeconds >= windowSec) {
        bucket.remaining = max;
        bucket.windowStart = now;
      }

      if (bucket.remaining <= 0) {
        final retryAfter = windowSec - now.difference(bucket.windowStart).inSeconds;
        return Response(429, headers: {'Retry-After': '$retryAfter'}, body: 'Rate limit exceeded');
      }

      bucket.remaining -= 1;
      return inner(req);
    };
  };
}
