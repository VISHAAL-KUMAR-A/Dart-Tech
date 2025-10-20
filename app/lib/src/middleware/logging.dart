import 'dart:convert';
import 'package:shelf/shelf.dart';

Middleware logRequestsCustom() {
  return (Handler innerHandler) {
    return (Request request) async {
      final start = DateTime.now().microsecondsSinceEpoch;
      final response = await innerHandler(request).catchError((e, st) {
        final body = jsonEncode({'error': e.toString()});
        return Response.internalServerError(body: body, headers: {'content-type': 'application/json'});
      });
      final end = DateTime.now().microsecondsSinceEpoch;
      final durationMs = ((end - start) / 1000).toStringAsFixed(2);

      print(jsonEncode({
        'method': request.method,
        'path': request.requestedUri.path,
        'status': response.statusCode,
        'duration_ms': durationMs,
      }));
      return response;
    };
  };
}
