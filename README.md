# CV Flutter — Mbusa Vinyatsi Japhet (TP2)

Application mobile Flutter présentant mon CV, ma famille et mes coordonnées.
Le **TP2** ajoute une **authentification réelle** et la **gestion dynamique des membres de ma famille** via une **API REST** (données enregistrées en base MySQL).

## 🎥 Démonstration

<!-- ▶ Remplacer la ligne ci-dessous par la vidéo (voir « Ajouter la vidéo » plus bas) -->
https://github.com/<utilisateur>/<depot>/assets/<id>/demo-tp2.mp4

> Vidéo de démonstration : inscription → connexion → liste des membres → ajout (avec photo) → modification → suppression → déconnexion.

## Fonctionnalités

| Module | Détail |
| --- | --- |
| Authentification | Création de compte et connexion via `POST /accounts/register` et `POST /accounts/login` (plus aucune simulation). La session est conservée (`shared_preferences`) et l'utilisateur peut se déconnecter. |
| Famille — consulter | `GET /famille-membres` : liste avec photo, parenté, date et lieu de naissance. Rafraîchissement par glissement. |
| Famille — ajouter | `POST /famille-membres` (JSON, ou multipart si une photo est choisie). |
| Famille — modifier | `PUT /famille-membres/{id}` (JSON) ; `POST /famille-membres/{id}` (multipart) si la photo change. |
| Famille — supprimer | `DELETE /famille-membres/{id}` avec confirmation. |
| TP1 | Pages CV, contact et accueil conservées. |

Validation des formulaires côté application (champs obligatoires, longueurs max, email valide, mot de passe ≥ 6 caractères, date non future) et affichage des erreurs renvoyées par l'API (401, 409, 422…).

## Architecture

```
lib/
├── config/api_config.dart        # URL de base de l'API
├── models/membre.dart            # Modèle Membre (fromJson / toFields)
├── services/
│   ├── api_service.dart          # Appels HTTP (comptes + membres) et gestion d'erreurs
│   └── session.dart              # Session locale (utilisateur connecté)
└── pages/
    ├── login_page.dart           # Connexion / inscription
    ├── famille_page.dart         # Liste + suppression
    └── membre_form_page.dart     # Ajout / modification (avec photo)
```

## Installation et lancement

### 1. Lancer l'API ([espoirbaraka/api-test](https://github.com/espoirbaraka/api-test))

1. Placer l'API dans `C:\xampp\htdocs\api-test`, démarrer **Apache** et **MySQL** (XAMPP).
2. Créer la base `api` et importer `api.sql`.
3. Copier `.env.example` vers `.env`.
4. Vérifier dans le navigateur : `http://localhost/api-test/public/famille-membres` doit répondre en JSON.

### 2. Configurer l'application

Dans `lib/config/api_config.dart`, adapter `host` :

| Cas | Valeur |
| --- | --- |
| Chrome (web) / Windows | `localhost` (automatique sur le web) |
| Émulateur Android | `10.0.2.2` (automatique hors web) |
| Téléphone réel (même Wi-Fi que le PC) | IP du PC, ex. `192.168.1.10` (pare-feu Windows : autoriser Apache) |

### 3. Dépendances et exécution

```bash
flutter pub add http shared_preferences image_picker
flutter pub get
```

Lancer dans **Chrome** ou **Edge** (sans émulateur) :

```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
# ou
flutter run -d edge --web-browser-flag "--disable-web-security"
```

> L'option `--disable-web-security` désactive le blocage CORS du navigateur, uniquement pour le développement local (l'API de test n'envoie pas d'en-têtes CORS). Elle n'est pas nécessaire sur Android.

Lancer sur un émulateur ou un téléphone Android : `flutter run`.

**Android** — dans `android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application
    android:usesCleartextTraffic="true"
    ... >
```

(`usesCleartextTraffic` est nécessaire car l'API locale est en `http`, pas `https`.)

**iOS** — ajouter dans `ios/Runner/Info.plist` la clé `NSPhotoLibraryUsageDescription` (accès aux photos) et autoriser le HTTP local (`NSAppTransportSecurity`).

## Ajouter la vidéo de démonstration

1. Enregistrer l'écran de l'émulateur/du téléphone (< 100 Mo) :
   - Android : `adb shell screenrecord /sdcard/demo.mp4` (Ctrl+C pour arrêter), puis `adb pull /sdcard/demo.mp4`, ou l'enregistreur d'écran du téléphone.
   - Émulateur : bouton **Record** dans le panneau latéral.
2. Sur GitHub, ouvrir `README.md` → ✏️ *Edit* → **glisser-déposer** la vidéo dans l'éditeur : GitHub insère un lien `https://github.com/.../assets/...mp4`.
3. Remplacer la ligne de la section « Démonstration » par ce lien, puis *Commit changes*.

Alternative : mettre la vidéo dans `docs/demo-tp2.mp4` et écrire `[▶ Voir la démo](docs/demo-tp2.mp4)`.

## Auteur

Mbusa Vinyatsi Japhet — L3 Informatique de Gestion, ISIG-Goma.
