import 'package:flutter/material.dart';

import '../models/membre.dart';
import '../services/api_service.dart';
import 'membre_form_page.dart';

/// Liste des membres de la famille (données lues depuis l'API / base de données).
/// La liste se met à jour immédiatement après un ajout, une modification ou une suppression.
class FamillePage extends StatefulWidget {
  const FamillePage({super.key});

  @override
  State<FamillePage> createState() => _FamillePageState();
}

class _FamillePageState extends State<FamillePage> {
  List<Membre> _membres = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Charge la liste depuis l'API. [silent] = sans spinner ni message d'erreur
  /// (utilisé pour resynchroniser en arrière-plan).
  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await ApiService.getMembres();
      if (!mounted) return;
      setState(() {
        _membres = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!silent) _error = e.toString();
      });
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red.shade700 : null,
    ));
  }

  Future<void> _openForm([Membre? membre]) async {
    final saved = await Navigator.push<Membre>(
      context,
      MaterialPageRoute(builder: (_) => MembreFormPage(membre: membre)),
    );
    if (saved == null) return;

    // Mise à jour immédiate de l'écran.
    setState(() {
      final i = _membres.indexWhere((x) => x.id == saved.id);
      if (i >= 0) {
        _membres[i] = saved;
      } else {
        _membres.add(saved);
      }
    });
    // Resynchronisation discrète avec la base de données.
    _load(silent: true);
  }

  Future<void> _delete(Membre m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce membre ?'),
        content: Text('${m.nomComplet} sera supprimé définitivement.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true || m.id == null) return;

    // Disparition immédiate de la liste.
    final index = _membres.indexWhere((x) => x.id == m.id);
    setState(() => _membres.removeWhere((x) => x.id == m.id));
    try {
      await ApiService.deleteMembre(m.id!);
      _snack('Membre supprimé');
    } catch (e) {
      // Échec : on remet le membre à sa place.
      if (!mounted) return;
      setState(() => _membres.insert(index < 0 ? 0 : index.clamp(0, _membres.length), m));
      _snack(e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pas d'AppBar ici : la barre du haut est déjà celle de HomeShell (main.dart).
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(children: [
        const SizedBox(height: 120),
        Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade600),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
        Center(
          child: OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
        ),
      ]);
    }
    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: _membres.isEmpty
          ? ListView(children: const [
              SizedBox(height: 160),
              Center(child: Text('Aucun membre. Appuyez sur « Ajouter ».')),
            ])
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: _membres.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = _membres[i];
                return ListTile(
                  key: ValueKey(m.id),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage:
                        m.imageUrl != null ? NetworkImage(m.imageUrl!) : null,
                    child: m.imageUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(m.nomComplet),
                  subtitle: Text('${m.parente} • né(e) le ${m.dateNaissance} à ${m.lieuNaissance}'),
                  onTap: () => _openForm(m),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Modifier',
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openForm(m),
                      ),
                      IconButton(
                        tooltip: 'Supprimer',
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(m),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
