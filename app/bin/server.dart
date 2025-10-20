import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'src/middleware/auth.dart';
import 'src/middleware/rate_limit.dart';
import 'src/middleware/logging.dart';
import 'src/controllers/notes_controller.dart';
import 'src/services/feature_flags.dart';

void main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;

  final router = Router();

  // Healthcheck
  router.get('/health', (Request req) async {
    return Response.ok('ok', headers: {'content-type': 'text/plain'});
  });

  // Feature flags
  router.get('/v1/feature-flags', FeatureFlagsService.handleGet);

  // Notes CRUD
  final notes = NotesController();
  router.mount('/v1/notes', notes.router);

  // Pipeline
  final handler = const Pipeline()
      .addMiddleware(logRequestsCustom())
      .addMiddleware(authMiddleware())
      .addMiddleware(rateLimitMiddleware())
      .addHandler(router);

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('🚀 Server listening on port ${server.port}');
}
