import '../config/api_config.dart';

class Membre {
  final int? id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance; // format AAAA-MM-JJ
  final String parente;
  final String? image; // chemin relatif renvoyé par l'API

  Membre({
    this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.image,
  });

  factory Membre.fromJson(Map<String, dynamic> j) => Membre(
        id: int.tryParse(j['id'].toString()),
        nom: j['nom']?.toString() ?? '',
        postnom: j['postnom']?.toString() ?? '',
        prenom: j['prenom']?.toString() ?? '',
        lieuNaissance: j['lieu_naissance']?.toString() ?? '',
        dateNaissance: j['date_naissance']?.toString() ?? '',
        parente: j['parente']?.toString() ?? '',
        image: j['image']?.toString(),
      );

  /// Champs envoyés à l'API (création / modification).
  Map<String, String> toFields() => {
        'nom': nom,
        'postnom': postnom,
        'prenom': prenom,
        'lieu_naissance': lieuNaissance,
        'date_naissance': dateNaissance,
        'parente': parente,
      };

  /// URL complète de l'image, reconstruite avec l'hôte configuré
  /// (évite le problème "localhost" sur émulateur / téléphone).
  String? get imageUrl =>
      (image == null || image!.isEmpty) ? null : '${ApiConfig.baseUrl}/$image';

  String get nomComplet => '$prenom $nom $postnom';
}
