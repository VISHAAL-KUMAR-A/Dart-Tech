import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

class NotesController {
  final _uuid = const Uuid();
  final Map<String, Note> _db = {};

  Router get router {
    final r = Router();

    r.get('/', _list);
    r.post('/', _create);
    r.get('/<id>', _get);
    r.put('/<id>', _update);
    r.delete('/<id>', _delete);

    return r;
  }

  Future<Response> _list(Request req) async {
    final q = req.requestedUri.queryParameters;
    final page = int.tryParse(q['page'] ?? '1') ?? 1;
    final limit = int.tryParse(q['limit'] ?? '20') ?? 20;
    final items = _db.values.toList();
    final start = (page - 1) * limit;
    final slice = items.skip(start).take(limit).map((n) => _toJson(n)).toList();

    return Response.ok(jsonEncode({
      'page': page,
      'limit': limit,
      'total': items.length,
      'items': slice,
    }), headers: {'content-type': 'application/json'});
  }

  Future<Response> _create(Request req) async {
    final body = jsonDecode(await req.readAsString()) as Map;
    final title = (body['title'] ?? '').toString().trim();
    final content = (body['content'] ?? '').toString();

    if (title.isEmpty || title.length > 120) {
      return Response(400, body: 'Invalid title');
    }
    if (content.length > 10000) {
      return Response(400, body: 'Content too long');
    }

    final id = _uuid.v4();
    final note = Note(id: id, title: title, content: content);
    _db[id] = note;
    return Response(201, body: jsonEncode(_toJson(note)), headers: {'content-type': 'application/json'});
  }

  Future<Response> _get(Request req, String id) async {
    final note = _db[id];
    if (note == null) return Response(404, body: 'Not found');
    return Response.ok(jsonEncode(_toJson(note)), headers: {'content-type': 'application/json'});
  }

  Future<Response> _update(Request req, String id) async {
    final note = _db[id];
    if (note == null) return Response(404, body: 'Not found');

    final body = jsonDecode(await req.readAsString()) as Map;
    final title = (body['title'] ?? note.title).toString().trim();
    final content = (body['content'] ?? note.content).toString();

    if (title.isEmpty || title.length > 120) {
      return Response(400, body: 'Invalid title');
    }
    if (content.length > 10000) {
      return Response(400, body: 'Content too long');
    }

    note.title = title;
    note.content = content;
    note.updatedAt = DateTime.now();

    return Response.ok(jsonEncode(_toJson(note)), headers: {'content-type': 'application/json'});
  }

  Future<Response> _delete(Request req, String id) async {
    final existed = _db.remove(id) != null;
    if (!existed) return Response(404, body: 'Not found');
    return Response(204);
  }

  Map<String, dynamic> _toJson(Note n) => {
        'id': n.id,
        'title': n.title,
        'content': n.content,
        'createdAt': n.createdAt.toIso8601String(),
        'updatedAt': n.updatedAt.toIso8601String(),
      };
}
