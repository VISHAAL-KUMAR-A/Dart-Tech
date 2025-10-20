import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';

enum Tier { Sandbox, Standard, Enhanced, Enterprise }

Tier _tierForKey(String? apiKey) {
  // naive mapping by suffix; candidates can implement env mapping
  if (apiKey == null) return Tier.Sandbox;
  if (apiKey.contains('enterprise')) return Tier.Enterprise;
  if (apiKey.contains('enhanced')) return Tier.Enhanced;
  if (apiKey.contains('standard')) return Tier.Standard;
  return Tier.Sandbox;
}

class FeatureFlagsService {
  static Future<Response> handleGet(Request req) async {
    final apiKey = req.context['apiKey'] as String?;
    final tier = _tierForKey(apiKey);

    final flags = switch (tier) {
      Tier.Sandbox => {
        'tier': 'Sandbox',
        'features': {
          'notesCrud': true,
          'oauth': false,
          'advancedReports': false,
        }
      },
      Tier.Standard => {
        'tier': 'Standard',
        'features': {
          'notesCrud': true,
          'oauth': true,
          'advancedReports': false,
        }
      },
      Tier.Enhanced => {
        'tier': 'Enhanced',
        'features': {
          'notesCrud': true,
          'oauth': true,
          'advancedReports': true,
        }
      },
      Tier.Enterprise => {
        'tier': 'Enterprise',
        'features': {
          'notesCrud': true,
          'oauth': true,
          'advancedReports': true,
          'ssoSaml': true,
        }
      },
    };

    return Response.ok(jsonEncode(flags), headers: {'content-type': 'application/json'});
  }
}
