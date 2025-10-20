import 'package:shelf/shelf.dart';

// Reads X-API-Key header and validates against env API_KEYS (colon-separated).
Middleware authMiddleware() {
  final raw = const String.fromEnvironment('API_KEYS', defaultValue: '');
  return (Handler inner) {
    return (Request req) async {
      // Allow health without auth
      if (req.url.path == 'health') return inner(req);

      final key = req.headers['X-API-Key'];
      final keys = (const bool.hasEnvironment ? String.fromEnvironment('API_KEYS') : raw);
      final envKeys = (keys.isEmpty ? (const []) : keys.split(':')).toSet();

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
