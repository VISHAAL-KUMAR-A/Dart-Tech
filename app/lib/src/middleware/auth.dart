import 'dart:io';
import 'package:shelf/shelf.dart';

// Reads X-API-Key header and validates against env API_KEYS (colon-separated).
Middleware authMiddleware() {
  return (Handler inner) {
    return (Request req) async {
      // Allow health without auth
      if (req.url.path == 'health') return inner(req);

      final key = req.headers['x-api-key'];
      final keys = Platform.environment['API_KEYS'] ?? '';
      final envKeys = (keys.isEmpty ? <String>{} : keys.split(':').toSet());

      if (envKeys.isEmpty) {
        // Allow if not configured (for local dev); candidates can change if desired.
        return inner(req);
      }
      if (key == null || !envKeys.contains(key)) {
        return Response(401, body: 'Unauthorized: missing or invalid API key');
      }
      // Attach key to context
      final ctx = {'apiKey': key};
      return inner(req.change(context: ctx));
    };
  };
}
