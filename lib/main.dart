import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pages/famille_page.dart';
import 'pages/login_page.dart';
import 'services/session.dart';

void main() => runApp(const CvApp());

class CvApp extends StatelessWidget {
  const CvApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CV Japhet',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: const Color.fromARGB(255, 30, 56, 204), useMaterial3: true),
    home: const AuthGate(),
  );
}

// ---------- Choix de l'écran : connexion réelle (API) ou application ----------
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _logged; // null = vérification en cours

  @override
  void initState() {
    super.initState();
    Session.isLoggedIn().then((v) {
      if (mounted) setState(() => _logged = v);
    });
  }

  Future<void> _logout() async {
    await Session.clear();
    if (mounted) setState(() => _logged = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_logged == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_logged!) return HomeShell(onLogout: _logout);
    return LoginPage(onLoggedIn: () => setState(() => _logged = true));
  }
}

// ---------- Widget photo (icône de secours si l'image manque) ----------
class Avatar extends StatelessWidget {
  final String path;
  final double size;
  const Avatar(this.path, {super.key, this.size = 56});

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: Colors.indigo.shade100,
        child: Icon(Icons.person, size: size * 0.6),
      ),
    ),
  );
}

// ---------- Navigation (barre du bas) ----------
class HomeShell extends StatefulWidget {
  final VoidCallback onLogout;
  const HomeShell({super.key, required this.onLogout});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const _titles = ['Accueil', 'Famille', 'Contact'];
  static const _pages = [HomePage(), FamillePage(), ContactPage()];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_titles[_index]),
      actions: [
        IconButton(
          tooltip: 'Déconnexion',
          icon: const Icon(Icons.logout),
          onPressed: widget.onLogout,
        ),
      ],
    ),
    body: IndexedStack(index: _index, children: _pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Accueil'),
        NavigationDestination(icon: Icon(Icons.family_restroom), label: 'Famille'),
        NavigationDestination(icon: Icon(Icons.contact_mail), label: 'Contact'),
      ],
    ),
  );
}

// ---------- Page 2 : Accueil (CV) ----------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

    Widget _section(String title, IconData icon, List<String> items,
          {Color color = Colors.indigo}) =>
      Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ),
              ]),
              Divider(color: color),
              for (final s in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text('• $s'),
                ),
            ],
          ),
        ),
      );
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF101957), Color.fromARGB(255, 152, 191, 229)],
      ),
    ),
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 1, 5, 29),
              shape: BoxShape.circle,
            ),
            child: const Avatar('assets/images/moi.jpg', size: 120),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text('Mbusa Vinyatsi Japhet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        const Center(
          child: Text(
            'Étudiant en L3 Informatique de Gestion – ISIG-Goma',
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        _section('Profil', Icons.person, [
          "Étudiant en dernière année de Licence en Informatique de Gestion des Entreprises, avec une expérience de terrain en logistique humanitaire, gestion de bases de données logistiques et sécurité.",
          "Motivé par l'intelligence artificielle, la cybersécurité et la conception de systèmes d'information.",
        ]),
        _section('Formation', Icons.school, [
          "2024 – 2027 : Licence en Informatique de Gestion des Entreprises (L3, LMD) – ISIG-Goma",
          "2022 – 2023 : Licence en Sciences Commerciales et Financières, option Comptabilité – ISC Bunia (mention Distinction)",
          "2021 – 2022 : Diplôme d'État des Humanités, option Technique Sociale – Institut Diangienda, Bunia (mention Satisfaction)",
        ]),
        _section('Expériences', Icons.work, [
          "Juil. 2023 – nov. 2024 : Magasinier, World Vision International (Butembo)",
          "Juil. 2022 – juin 2023 : Assistant magasinier et gestionnaire de base de données logistiques, VIGLOJ ASBL (Goma)",
          "2021 – 2024 : Agent de sécurité, GCO Sécurité (Bunia)",
          "Stage : installation, télécommunication et maintenance réseau, MD Engineering SARL",
          "Projet : JaphetShop Stores, boutique en ligne WordPress / WooCommerce (Goma)",
        ]),
        _section('Formations complémentaires', Icons.workspace_premium, [
          "Logistique humanitaire",
          "Approvisionnement, achats et transport – SYJEPRO, Goma",
          "Eau, hygiène et assainissement (WASH) – SYJEPRO, Goma",
          "Sécurité – GCO Security, Bunia",
          "Packing, labelling et palettisation – DHL Academy of Humanitarian Logistics",
        ]),
        _section('Compétences techniques', Icons.code, [
          "Bases de données relationnelles, SQL / SQL Server (notions)",
          "HTML, CSS, JavaScript, Python (notions)",
          "Word, Excel, PowerPoint, Access, Outlook",
          "Gestion informatisée de stock",
          "Installation et maintenance de base d'équipements informatiques",
          "WordPress / WooCommerce, Flutter (en apprentissage)",
        ]),
        _section('Langues', Icons.language, [
          'Français : C2',
          'Swahili : natif',
          'Lingala : C1',
          'Anglais : B1',
        ]),
        _section("Centres d'intérêt", Icons.favorite, [
          'Intelligence artificielle',
          'Cybersécurité',
          "Systèmes d'information",
          'Travail en mode projet',
        ]),
      ],
    ),
  );
}

// ---------- Page 4 : Contact ----------
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Widget _tile(IconData icon, String titre, String valeur, {String? url}) => Card(
    child: ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 5, 13, 163)),
      title: Text(titre),
      subtitle: Text(valeur),
      trailing: url == null ? null : const Icon(Icons.open_in_new),
      onTap: url == null
          ? null
          : () => launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication),
    ),
  );

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      _tile(Icons.phone, 'Téléphone', '+243 976 519 877',
          url: 'tel:+243976519877'),
      _tile(Icons.phone_android, 'Téléphone 2', '+243 803 118 480',
          url: 'tel:+243803118480'),
      _tile(Icons.email, 'E-mail', 'vinyatsijaphet@gmail.com',
          url: 'mailto:vinyatsijaphet@gmail.com'),
      _tile(Icons.location_on, 'Adresse', 'Goma, Nord-Kivu, RDC'),
      _tile(Icons.code, 'GitHub', 'github.com/vinyatsijaphet-gif',
          url: 'https://github.com/vinyatsijaphet-gif'),
    ],
  );
}
