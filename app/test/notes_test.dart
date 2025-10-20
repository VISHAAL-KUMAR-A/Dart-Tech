import 'dart:convert';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:dart_backend_tech_test/src/controllers/notes_controller.dart';

void main() {
  test('Notes CRUD basic create/list', () async {
    final notes = NotesController();
    final app = Router()..mount('/v1/notes', notes.router);
    final server = await io.serve(app, 'localhost', 0);
    final port = server.port;

    // create
    final client = HttpClient();
    final req = await client.post('localhost', port, '/v1/notes');
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode({'title': 'Hello', 'content': 'World'}));
    final res = await req.close();
    expect(res.statusCode, 201);

    // list
    final req2 = await client.get('localhost', port, '/v1/notes');
    final res2 = await req2.close();
    expect(res2.statusCode, 200);
    final body = await utf8.decodeStream(res2);
    final data = jsonDecode(body);
    expect(data['total'], 1);

    await server.close(force: true);
  });
}
