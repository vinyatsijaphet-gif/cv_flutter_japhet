import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/membre.dart';

class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  ApiException(this.message, {this.errors});

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.join('\n');
    }
    return message;
  }
}

/// Image choisie par l'utilisateur, en octets : fonctionne sur Chrome, Windows et Android.
class ImageData {
  final Uint8List bytes;
  final String filename;
  ImageData(this.bytes, this.filename);
}

class ApiService {
  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  static const _timeout = Duration(seconds: 15);

  static Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  // ---------- utilitaires ----------

  static Future<http.Response> _send(Future<http.Response> request) async {
    try {
      return await request.timeout(_timeout);
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre.');
    } on http.ClientException {
      throw ApiException(
          "Impossible de joindre le serveur. Vérifiez que XAMPP (Apache + MySQL) tourne et que l'adresse de l'API est correcte.");
    }
  }

  static Map<String, dynamic> _decode(http.Response r) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Réponse invalide du serveur (code ${r.statusCode}).');
    }
    if (r.statusCode >= 200 && r.statusCode < 300 && body['success'] == true) {
      return body;
    }
    throw ApiException(
      body['message']?.toString() ?? 'Erreur ${r.statusCode}',
      errors: body['errors'] is Map
          ? Map<String, dynamic>.from(body['errors'] as Map)
          : null,
    );
  }

  // ---------- comptes ----------

  static Future<Map<String, dynamic>> register(
      String email, String password) async {
    final r = await _send(http.post(
      _uri('/accounts/register'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    ));
    return _decode(r)['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final r = await _send(http.post(
      _uri('/accounts/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    ));
    return _decode(r)['data'] as Map<String, dynamic>;
  }

  // ---------- membres de famille ----------

  static Future<List<Membre>> getMembres() async {
    final r = await _send(http.get(_uri('/famille-membres'),
        headers: {'Accept': 'application/json'}));
    final data = _decode(r)['data'];
    final list = data is List ? data : <dynamic>[];
    return list
        .map((e) => Membre.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Création. Sans image -> JSON ; avec image -> multipart/form-data.
  static Future<Membre> createMembre(Membre m, {ImageData? image}) async {
    http.Response r;
    if (image == null) {
      r = await _send(http.post(_uri('/famille-membres'),
          headers: _jsonHeaders, body: jsonEncode(m.toFields())));
    } else {
      r = await _send(_multipart('/famille-membres', m, image));
    }
    return Membre.fromJson(
        Map<String, dynamic>.from(_decode(r)['data'] as Map));
  }

  /// Modification. Sans nouvelle image -> PUT JSON (l'image est conservée) ;
  /// avec nouvelle image -> POST multipart sur /famille-membres/{id}.
  static Future<Membre> updateMembre(int id, Membre m,
      {ImageData? image}) async {
    http.Response r;
    if (image == null) {
      r = await _send(http.put(_uri('/famille-membres/$id'),
          headers: _jsonHeaders, body: jsonEncode(m.toFields())));
    } else {
      r = await _send(_multipart('/famille-membres/$id', m, image));
    }
    return Membre.fromJson(
        Map<String, dynamic>.from(_decode(r)['data'] as Map));
  }

  static Future<void> deleteMembre(int id) async {
    final r = await _send(http.delete(_uri('/famille-membres/$id'),
        headers: {'Accept': 'application/json'}));
    _decode(r);
  }

  static Future<http.Response> _multipart(
      String path, Membre m, ImageData image) async {
    final req = http.MultipartRequest('POST', _uri(path))
      ..headers['Accept'] = 'application/json'
      ..fields.addAll(m.toFields())
      ..files.add(http.MultipartFile.fromBytes('image', image.bytes,
          filename: image.filename));
    final streamed = await req.send();
    return http.Response.fromStream(streamed);
  }
}
